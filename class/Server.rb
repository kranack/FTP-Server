#
#	File : Server.rb
#	@author Damien Calesse, Pierre Leroy 
#



require 'socket'
require 'optparse'
require 'ostruct'

require_relative 'CommandHandler'


class Server

	#
	# Initialize FTP Server
	# @param hostname [String] hostname of the server (default is `localhost`)
	# @param port [Int] port of the server (default is 2121)
	#
	def initialize(hostname, port)
		puts "Server starting up ..."

		@params = OpenStruct.new
		@params.host = hostname
		@params.port = port
		@params.root = "#{Dir.pwd}/Docs"
        #@params.root = "/home/pierre/Documents/MasterS2/CAR/TP1/Docs"

		# start
		@server = TCPServer.new(@params.host, @params.port)

		# change dir to root
		Dir.chdir(@params.root)
	end


	#
	# Start loop
	#
	def run
        puts "My body is ready"
		@threads = []

		loop do
			session = @server.accept
			@threads << new_c_thread(session)
		end
	end

	# create new thread
	def new_c_thread(session)
		Thread.new(session) do |session|
			thread[:session] = session
			thread[:mode] = :binary

			response "220 Connection Established"

			# listen for command
			while !session.nil? and !session.closed?
				puts "Command start"
				request = session.gets
				puts "#{request}"
				reply = handler(request)
				puts reply
				response reply
			end

		end
	end

	# return response to client for commands
	def handler(request)
		if (request.to_s == '')
			return
		end

		begin
			command = request[0,4].downcase.strip
			rqarray = request.split(' ')
			message = rqarray.length>2 ? rqarray[1..rqarray.length].join(' ') : rqarray[1]

			case command
				when *COMMANDS
					__send__ command, message
				else
					bad_command command, message
			end
		rescue Errno::EACCES, Errno::EPERM
			"553 Permission denied"
		rescue Errno::ENOENT
			"553 File doesn't exist"
		rescue Exception => e
			"500 Server Error: #{e.class} : #{e.message} -\n\t#{e.backtrace[0]}"
		end
	end

	# send data to client
	def response(msg)
		session = thread[:session]
		if (!msg.nil? && !session.nil?)
			session.print msg << "\r\n"
		else
			session.print "500 Server Error"
		end
	end

	def bad_command(name,*params)
		"502 Command not implemented"
	end

	# return current thread
	def thread
		Thread.current
	end

	# send data to a connection
	def send_data(data)
		bytes = 0
		begin
			data.each do |line|
				if thread[:mode] == :binary
					puts line
					thread[:datasocket].syswrite(line)
				else
					puts line
					thread[:datasocket].send(line,0)
				end
				bytes += line.length
			end
		rescue Errno::EPIPE
			return quit
		else
			#do nothing
		ensure
			thread[:datasocket].close
			thread[:datasocket] = nil
		end
		bytes
	end

	# functions module
	include(FTPServerFunctions)

end
