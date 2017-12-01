require 'fastlane/server/command.rb'
require 'fastlane/server/command_executor.rb'
require 'socket'
require 'json'

module Fastlane
  class SocketServer
    attr_accessor :command_executor
    attr_accessor :return_value_processor

    def initialize(command_executor: nil, return_value_processor: nil)
      if return_value_processor.nil?
        return_value_processor = JSONReturnValueProcessor.new
      end

      @command_executor = command_executor
      @return_value_processor = return_value_processor
    end

    def start
      server = TCPServer.open('localhost', 2000) # Socket to listen on port 2000
      print "Accepting connections from localhost\n"

      # set thread local to ready so we can check it
      Thread.current[:ready] = true
      client = server.accept # Wait for a client to connect
      print "Client connected\n"

      loop do # Servers run forever
        str = client.recv(1_048_576) # 1024 * 1024
        if str == 'done'
          time = Time.new
          UI.verbose("[#{time.usec}]: received done signal, shutting down")
          break
        end
        response_json = process_command(command_json: str)

        time = Time.new
        UI.verbose("[#{time.usec}]: sending #{response_json}")
        client.puts(response_json) # Send some json to the client
      end
    end

    def process_command(command_json: nil)
      time = Time.new
      UI.verbose("[#{time.usec}]: received command:#{command_json}")
      return execute_command(command_json: command_json)
    end

    def execute_command(command_json: nil)
      command = Command.new(json: command_json)
      command_return = @command_executor.execute(command: command, target_object: nil)
      ## probably need to just return Strings, or ready_for_next with object isn't String
      return_object = command_return.return_value
      return_value_type = command_return.return_value_type
      closure_arg = command_return.closure_argument_value

      return_object = return_value_processor.prepare_object(
        return_value: return_object,
        return_value_type: return_value_type
      )

      if closure_arg.nil?
        closure_arg = closure_arg.to_s
      else
        closure_arg = return_value_processor.prepare_object(
          return_value: closure_arg,
          return_value_type: :string # always assume string for closure error_callback
        )
        closure_arg = ', "closure_argument_value": ' + closure_arg
      end

      return '{"payload":{"status":"ready_for_next", "return_object":' + return_object + closure_arg + '}}'
    rescue StandardError => e
      exception_array = []
      exception_array << "#{e.class}:"
      exception_array << e.backtrace

      while e.respond_to?("cause") && (e = e.cause)
        exception_array << "cause: #{e.class}"
        exception_array << backtrace
      end
      return "{\"payload\":{\"status\":\"failure\",\"failure_information\":#{exception_array.flatten}}}"
    end
  end

  class JSONReturnValueProcessor
    def prepare_object(return_value: nil, return_value_type: nil)
      case return_value_type
      when nil
        UI.verbose("return_value_type is nil value: #{return_value}")
        return process_value_as_string(return_value: return_value)
      when :string
        return process_value_as_string(return_value: return_value)
      when :int
        return process_value_as_int(return_value: return_value)
      when :bool
        return process_value_as_bool(return_value: return_value)
      when :array_of_strings
        return process_value_as_array_of_strings(return_value: return_value)
      when :hash_of_strings
        return process_value_as_hash_of_strings(return_value: return_value)
      else
        UI.verbose("Unknown return type defined: #{return_value_type} for value: #{return_value}")
        return process_value_as_string(return_value: return_value)
      end
    end

    def process_value_as_string(return_value: nil)
      if return_value.nil?
        return_value = ""
      end

      return JSON.generate(return_value.to_s)
    end

    def process_value_as_array_of_strings(return_value: nil)
      if return_value.nil?
        return_value = []
      end

      return JSON.generate(return_value)
    end

    def process_value_as_hash_of_strings(return_value: nil)
      if return_value.nil?
        return_value = {}
      end

      return JSON.generate(return_value)
    end

    def process_value_as_bool(return_value: nil)
      if return_value.nil?
        return_value = false
      end

      return JSON.generate(return_value)
    end

    def process_value_as_int(return_value: nil)
      if return_value.nil?
        return_value = 0
      end

      return JSON.generate(return_value)
    end
  end
end
