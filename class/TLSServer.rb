
require 'ruby-tls'

class TLSServer
    
    def initialize (hostname, port)
        @tls_root = "/sec"
        is_server = true
        callback_obj = self
        options = {
          verify_peer: true,
          private_key: "#{@tls_root}/cert.pem",
          cert_chain: '#{@tls_root}/cert.crt',
          ciphers: 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-RC4-SHA:ECDHE-RSA-AES128-SHA:AES128-GCM-SHA256:RC4:HIGH:!MD5:!aNULL:!EDH:!CAMELLIA:@STRENGTH' # (default)
          # protocols: ["h2", "http/1.1"], # Can be used where OpenSSL >= 1.0.2 (Application Level Protocol negotiation)
          # fallback: "http/1.1" # Optional fallback to a default protocol when either client or server doesn't support ALPN
        }
        @ssl_layer = RubyTls::SSL::Box.new(is_server, callback_obj, options)
    end
    
    def start_tls
        # Start SSL negotiation when you are ready
        @ssl_layer.start
    end

    def send(data)
        @ssl_layer.encrypt(data)
    end
    
end