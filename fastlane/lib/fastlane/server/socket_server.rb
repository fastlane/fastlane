require 'fastlane/server/command.rb'
require 'fastlane/server/command_executor.rb'
require 'socket'
require 'json'

module Fastlane
  class SocketServer
    attr_accessor :command_executor
    attr_accessor :return_value_processor

    def initialize(
      command_executor: nil,
      return_value_processor: nil,
      connection_timeout: 5,
      stay_alive: false
    )
      if return_value_processor.nil?
        return_value_processor = JSONReturnValueProcessor.new
      end

      @command_executor = command_executor
      @return_value_processor = return_value_processor
      @connection_timeout = connection_timeout.to_i
      @stay_alive = stay_alive
    end

    # This is the public API, don't call anything else
    def start
      while listen
        # Loop for-ev-er
      end
    end

    private

    def receive_and_process_commands
      # We'll break out of the infinite loop somehow, either error or 'done' message
      ended_loop_due_to_error = true

      loop do # No idea how many commands are coming, so we loop until an error or the done command is sent
        str = nil

        begin
          str = @client.recv(1_048_576) # 1024 * 1024
        rescue Errno::ECONNRESET => e
          UI.verbose(e)
          break
        end

        if str == 'done'
          time = Time.new
          UI.verbose("[#{time.usec}]: received done signal, shutting down")
          ended_loop_due_to_error = false
          break
        end
        response_json = process_command(command_json: str)

        time = Time.new
        UI.verbose("[#{time.usec}]: sending #{response_json}")
        begin
          @client.puts(response_json) # Send some json to the client
        rescue Errno::EPIPE => e
          UI.verbose(e)
          break
        end
      end

      return handle_disconnect(error: ended_loop_due_to_error)
    end

    def listen
      @server = TCPServer.open('localhost', 2000) # Socket to listen on port 2000
      UI.message("Waiting for #{@connection_timeout} seconds for a connection from FastlaneRunner")

      # set thread local to ready so we can check it
      Thread.current[:ready] = true
      @client = nil
      begin
        Timeout.timeout(@connection_timeout) do
          @client = @server.accept # Wait for a client to connect
        end
      rescue Timeout::Error
        UI.user_error!("fastlane failed to receive a connection from the FastlaneRunner binary after #{@connection_timeout} seconds, shutting down")
      rescue StandardError => e
        UI.user_error!("Something went wrong while waiting for a connection from the FastlaneRunner binary, shutting down\n#{e}")
      end
      UI.message("Client connected")

      receive_and_process_commands
    end

    def handle_disconnect(error: false)
      UI.important("Client disconnected, or a pipe broke") if error
      if @stay_alive
        UI.important("stay_alive is set to true, restarting server")
        # clean up before restart
        @client.close
        @client = nil

        @server.close
        @server = nil
        return true # Restart server
      end
      return false # Don't restart server
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

      # quirks_mode because sometimes the build-in library is used for some folks and that needs quirks_mode: true
      return JSON.generate(return_value.to_s, quirks_mode: true)
    end

    def process_value_as_array_of_strings(return_value: nil)
      if return_value.nil?
        return_value = []
      end

      # quirks_mode shouldn't be required for real objects
      return JSON.generate(return_value)
    end

    def process_value_as_hash_of_strings(return_value: nil)
      if return_value.nil?
        return_value = {}
      end

      # quirks_mode shouldn't be required for real objects
      return JSON.generate(return_value)
    end

    def process_value_as_bool(return_value: nil)
      if return_value.nil?
        return_value = false
      end

      # quirks_mode because sometimes the build-in library is used for some folks and that needs quirks_mode: true
      return JSON.generate(return_value.to_s, quirks_mode: true)
    end

    def process_value_as_int(return_value: nil)
      if return_value.nil?
        return_value = 0
      end

      # quirks_mode because sometimes the build-in library is used for some folks and that needs quirks_mode: true
      return JSON.generate(return_value.to_s, quirks_mode: true)
    end
  end
end
