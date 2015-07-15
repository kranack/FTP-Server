module FTPServerFunctions

    COMMANDS = %w[user pass syst pwd list type feat cwd pasv mkd rmd dele cwd stor retr mode quit port site rnfr rnto cdup nlst size]

    # USER
    def user(msg)
        thread[:user] = msg
        "331 Username correct"
    end

    # PASS
    def pass(msg)
        thread[:pass] = msg
        "230 Logged in successfull"
    end

    # SYST
    def syst(msg)
        #"215 What a beautiful FTP server"
        "215 Unix Type: #{thread[:mode]}"
    end

    # LIST
    def list(msg)
        response "150 Directory listing"
        send_data([`ls -l`.split("\n").join("\r\n") << "\r\n"])
        "226 Tranfer complete"
    end

    # PWD
    def pwd(msg)
        "257 \"" + Dir.pwd + "\""
    end

    # CWD
    #def cwd(msg)
    #    Dir.chdir(msg)
    #end

    # FEAT
    def feat(msg)
        response "211 Features:\n"
        COMMANDS.each do |cmd|
            response "#{cmd}"
        end
        "211 End"
    end

    # TYPE
    def type(msg)
        if (msg=='A')
            thread[:mode] = :ascii
            "200 Type set to ascii"
        elsif (msg=='I')
            thread[:mode] = :binary
            "200 Type set to binary"
        end
    end

    # PASV
    def pasv(msg)
        "227 Entering Passive Mode #{msg}"
    end

    # QUIT
    def quit(msg)
        thread[:session].close
        thread[:session] = nil
        "221 Logged out successfull"
    end

    # MODE
    def mode(msg)
        "202 Only accept stream"
    end

    # RETR
    def retr(msg)
        response "125 Data transfer starting"
        bytes = send_data(File.new(msg,'r'))
        "226 Closing data connection, sent #{bytes} bytes"
    end
    
    # STOR
    def stor(msg)
        file = File.open(msg,'w')
        response "125 Data transfer starting"
        bytes = 0
        while (data = thread[:datasocket].recv(1024))
            if (data.nil? or data.empty? or data=="")
                file.close
                return "226 Closing data connection, sent #{bytes} bytes"
            else
                bytes += file.write data
            end
        end
    end

    # CWD
    def cwd(msg)
        begin
            Dir.chdir(msg)
        rescue Errno::ENOENT
            "550 Directory not found"
        else
            "250 Directory changed to " << Dir.pwd
        end
    end

    # DELE
    def dele(msg)
        rmd(msg)
    end

	# RMD
    def rmd(msg)
        if File.directory? msg
			FileUtils.rmdir msg, :verbose => true
        elsif File.file? msg
            File::delete msg
        end
        "250 command successful"
    end

    # MKD
    def mkd(msg)
        Dir.mkdir(msg)
        "257 #{msg} created"
    end

    # PORT
    def port(msg)
        nums = msg.split(',')
        port = nums[4].to_i * 256 + nums[5].to_i
        host = nums[0..3].join('.')
        if thread[:datasocket]
            thread[:datasocket].close
            thread[:datasocket] = nil
        end
        thread[:datasocket] = TCPSocket.new(host,port)
        "200 Passive connection established (#{port})"
    end
    
    # SITE
    def site(msg)
        cmd = msg.split(' ')
        `#{cmd[0].downcase} #{cmd[1..cmd.length].join(' ')} `
        "200 #{cmd[0].downcase} #{cmd[1..cmd.length].join(' ')} OK"
    end
    
    # NRFR
    def rnfr(msg)
        thread[:rnfr] = msg
        "200 #{msg} to rename" 
    end

    # RNTO
    def rnto(msg)
        `mv #{thread[:rnfr]} #{msg}`
        thread[:rnfr] = nil
        "200 successfully renamed into #{msg}"
    end

    def cdup(msg)
	Dir.chdir(@params.root)
	"250 Directory successfully changed"
    end

    # NLST
    def nlst(msg)
        response "150 Directory listing"
        send_data([`ls`.split("\n").join("\r\n") << "\r\n"])
        "226 Tranfer complete"
    end

    # SIZE
    def size(msg)
	"213 #{File.size(msg)}"
    end
end
