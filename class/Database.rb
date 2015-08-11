
require 'sqlite3'

class Database 
   
   def initialize (dbname)
        @db = SQLite3::Database.new "./db/#{dbname}.db"
   end
   
    def check_username (username)
        c = @db.execute( "SELECT COUNT(*) FROM `user` WHERE username = '#{username}'")[0][0]
        return (c > 0)
    end
    
    def check_password (username, passwd)
        c = @db.execute( "SELECT COUNT(*) FROM `user` WHERE username = '#{username}' AND passwd = '#{passwd}'")[0][0]
        return (c > 0)
    end
    
end