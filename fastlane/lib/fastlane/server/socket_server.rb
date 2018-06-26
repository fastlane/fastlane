require 'fastlane/server/command_executor.rb'
require 'fastlane/server/command_parser.rb'
require 'fastlane/server/json_return_value_processor.rb'
require 'socket'
require 'json'

module Fastlane
  class SocketServer
    COMMAND_EXECUTION_STATE = {
      ready: :ready,
      already_shutdown: :already_shutdown,
      error: :error
    }

    attr_accessor :command_executor
    attr_accessor :return_value_processor

    def initialize(
      command_executor: nil,
      return_value_processor: nil,
      connection_timeout: 5,
      stay_alive: false,
      port: 2000
    )
      if return_value_processor.nil?
        return_value_processor = JSONReturnValueProcessor.new
      end

      @command_executor = command_executor
      @return_value_processor = return_value_processor
      @connection_timeout = connection_timeout.to_i
      @stay_alive = stay_alive
      @port = port.to_i
    end

    # this is the public API, don't call anything else
    def start
      listen

      while @stay_alive
        UI.important("stay_alive is set to true, restarting server")
        listen
      end
    end

    private

    def receive_and_process_commands
      loop do # no idea how many commands are coming, so we loop until an error or the done command is sent
        execution_state = COMMAND_EXECUTION_STATE[:ready]

        command_string = nil
        begin
          command_string = @client.recv(1_048_576) # 1024 * 1024
        rescue Errno::ECONNRESET => e
          UI.verbose(e)
          execution_state = COMMAND_EXECUTION_STATE[:error]
        end

        if execution_state == COMMAND_EXECUTION_STATE[:ready]
          # Ok, all is good, let's see what command we have
          execution_state = parse_and_execute_command(command_string: command_string)
        end

        case execution_state
        when COMMAND_EXECUTION_STATE[:ready]
          # command executed successfully, let's setup for the next command
          next
        when COMMAND_EXECUTION_STATE[:already_shutdown]
          # we shutdown in response to a command, nothing left to do but exit
          break
        when COMMAND_EXECUTION_STATE[:error]
          # we got an error somewhere, let's shutdown and exit
          handle_disconnect(error: true, exit_reason: :error)
          break
        end
      end
    end

    def parse_and_execute_command(command_string: nil)
      command = CommandParser.parse(json: command_string)
      case command
      when ControlCommand
        return handle_control_command(command)
      when ActionCommand
        return handle_action_command(command)
      end

      # catch all
      raise "Command #{command} not supported"
    end

    # we got a server control command from the client to do something like shutdown
    def handle_control_command(command)
      exit_reason = nil
      if command.cancel_signal?
        UI.verbose("received cancel signal shutting down, reason: #{command.reason}")

        # send an ack to the client to let it know we're shutting down
        cancel_response = '{"payload":{"status":"cancelled"}}'
        send_response(cancel_response)

        exit_reason = :cancelled
      elsif command.done_signal?
        UI.verbose("received done signal shutting down")

        # client is already in the process of shutting down, no need to ack
        exit_reason = :done
      end

      # if the command came in with a user-facing message, display it
      if command.user_message
        UI.important(command.user_message)
      end

      # currently all control commands should trigger a disconnect and shutdown
      handle_disconnect(error: false, exit_reason: exit_reason)
      return COMMAND_EXECUTION_STATE[:already_shutdown]
    end

    # execute and send back response to client
    def handle_action_command(command)
      response_json = process_action_command(command: command)
      return send_response(response_json)
    end

    # send json back to client
    def send_response(json)
      UI.verbose("sending #{json}")
      begin
        @client.puts(json) # Send some json to the client
      rescue Errno::EPIPE => e
        UI.verbose(e)
        return COMMAND_EXECUTION_STATE[:error]
      end
      return COMMAND_EXECUTION_STATE[:ready]
    end

    def listen
      @server = TCPServer.open('localhost', @port) # Socket to listen on port 2000
      UI.verbose("Waiting for #{@connection_timeout} seconds for a connection from FastlaneRunner")

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
      UI.verbose("Client connected")

      # this loops forever
      receive_and_process_commands
    end

    def handle_disconnect(error: false, exit_reason: :error)
      Thread.current[:exit_reason] = exit_reason

      UI.important("Client disconnected, a pipe broke, or received malformed data") if exit_reason == :error
      # clean up
      @client.close
      @client = nil

      @server.close
      @server = nil
    end

    # record fastlane action command and then execute it
    def process_action_command(command: nil)
      UI.verbose("received command:#{command.inspect}")
      return execute_action_command(command: command)
    end

    # execute fastlane action command
    def execute_action_command(command: nil)
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
      end

      Thread.current[:exception] = nil

      payload = {
        payload: {
          status: "ready_for_next",
          return_object: return_object,
          closure_argument_value: closure_arg
        }
      }
      return JSON.generate(payload)
    rescue StandardError => e
      Thread.current[:exception] = e

      exception_array = []
      exception_array << "#{e.class}:"
      exception_array << e.backtrace

      while e.respond_to?("cause") && (e = e.cause)
        exception_array << "cause: #{e.class}"
        exception_array << e.backtrace
      end

      payload = {
        payload: {
          status: "failure",
          failure_information: exception_array.flatten
        }
      }
      return JSON.generate(payload)
    end
  end
end
