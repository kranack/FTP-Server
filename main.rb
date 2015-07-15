# File : main.rb

require 'getoptlong'

require_relative './class/Server'
#require_relative './class/Client'

hostname = "localhost"
port = 21

opts = GetoptLong.new(
	[ '--hostname', '-H', GetoptLong::REQUIRED_ARGUMENT],
	[ '--port', '-p', GetoptLong::REQUIRED_ARGUMENT],
	[ '--help', '-h', GetoptLong::NO_ARGUMENT]	
)


def usage
	puts "[main] usage : ruby main.rb -H hostname -p port"
        puts "-h, --help : show this help"
        puts "-H, --hostname : set hostname"
        puts "-p, --port : set port"
end


unless ARGV.length >= 4
	usage
	exit
end

opts.each do |opt, arg|
	case opt
		when '--help'
			puts "[main] usage : ruby main.rb -H hostname -p port"
			puts "-h, --help : show this help"
			puts "-H, --hostname : set hostname"
			puts "-p, --port : set port"
		when '--hostname'
			if arg != ''
				hostname = arg
			end
		when '--port'
			if arg != ''
				port = arg
			end
	end
end

server = Server.new hostname, port
server.run
