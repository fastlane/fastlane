require 'fastlane/server/command.rb'
require 'fastlane/server/command_executor.rb'
require 'socket'

module Fastlane
  class SocketServer
    attr_accessor :command_executor

    def initialize(command_executor: nil)
      @command_executor = command_executor
    end

    def start
      server = TCPServer.open('localhost', 2000) # Socket to listen on port 2000
      print "Accepting connections\n"

      # set thread local to ready so we can check it
      Thread.current[:ready] = true
      client = server.accept # Wait for a client to connect
      print "Client connected\n"

      loop do # Servers run forever
        str = client.recv(1_048_576) # 1024 * 1024
        if str == 'done'
          time = Time.new
          print "[#{time.usec}]: received done signal, shutting down\n"

          print "Done! Byeeeee\n"
          break
        end
        response_json = process_command(command_json: str)

        time = Time.new
        print "[#{time.usec}]: sending #{response_json}\n"
        client.puts(response_json) # Send some json to the client
      end
    end

    def process_command(command_json: nil)
      time = Time.new
      print "[#{time.usec}]: received command:#{command_json}\n"
      command = Command.new(json: command_json)

      return execute_command(command: command)
    end

    def execute_command(command: nil)
      return_object = @command_executor.execute(command: command, target_object: nil)
      ## probably need to just return Strings, or ready_for_next with object isn't String
      print "returning: #{return_object}\n"
      return '{"payload":{"status":"ready_for_next", "return_object":"' + return_object.to_s + '"}}'
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
end
