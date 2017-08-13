require 'socket' # Provides TCPServer and TCPSocket classes
require 'cgi'

module Snapshot
	class CommandListener

        attr_accessor :server
		def initialize
			@server = TCPServer.new('localhost', 2345)
			UI.message("CommandListener started on 2345")

			Thread.new do
				loop do
					socket = server.accept
					request = socket.gets

					query = /GET \/(\w*)\??(\S*) /.match(request)
					command = query[1]
					args = query[2] ? CGI::parse(query[2]) : ""

					yield(command, args)

					response = "OK\n"
					socket.print "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n Content-Length: #{response.bytesize}\r\nConnection: close\r\n"
					socket.print "\r\n"
					socket.print response
					socket.close
				end
			end
		end

		def close
			@server.close
		end
	end
end
