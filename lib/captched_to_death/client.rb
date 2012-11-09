require 'base64'
require 'logger'

module CaptchedToDeath
  class Client
    attr_writer :username, :password, :accept, :verbose

    # sensible defaults that can be overriden by configuration block:
    #
    # client = CaptchedToDeath::Client.new do |c|
    #   c.username = 'username'
    #   c.password = 'password'
    #   c.verbose  = true
    # end
    #
    # client = CaptchedToDeath::Client.new :username, :password
    #
    def initialize(*credentials)
      @accept  = :json
      @verbose = false
      if credentials.size == 2
        @username = credentials[0].to_s
        @password = credentials[1].to_s
      end
      yield self if block_given?

      RestClient.log = Logger.new(STDOUT) if @verbose
    end

    def balance
      fail ArgumentError if @username.nil? || @password.nil?
      response = RestClient.post "#{API_URI}/user", {:username => @username, :password => @password}, :accept => @accept
      fail ServiceError unless response.code == 200
      JSON.parse(response) 
    end

    def captcha(id)
      response = RestClient.get "#{API_URI}/captcha/#{id}", {:accept => @accept}
      JSON.parse(response)
    rescue RestClient::Exception => e
      case e.http_code
      when 404
        fail NotFound 
      #503 (Service Temporarily Unavailable) when our service is overloaded (usually around 3:00–6:00 PM EST)
      when 503  
        # not sure 503 is ever sent, but retry if it is
        sleep Server.status['solved_in']
        retry
      else
        raise e
      end
    end

    def decode(challenge, referer=nil, agent=nil)
      fail RejectedError if @username.nil? || @password.nil?

      file = captcha_file(challenge,referer,agent)
      response = RestClient.post "#{API_URI}/captcha", {:username => @username, :password => @password, :captchafile => file}, :accept => @accept
      resolved = JSON.parse(response) 
      begin
        sleep Server.status['solved_in']
        resolved = captcha(resolved['captcha'])
      end while resolved['text'].empty?
      resolved
    rescue RestClient::Exception => e
      case e.http_code
      #303 (See Other) CAPTCHA successfully uploaded: Location HTTP header will point to the status page
      when 303
        # RestClient: for result code 303 the redirection will be followed and the request transformed into a get
        # (...so it'll be returned as a 200)
      #403 (Forbidden) credentials were rejected, or you don't have enough credits
      when 403
        # TODO: discrimate wrong credentials
        fail NoCreditError
      #400 (Bad Request) if your request was not following the specification or not a valid image
      when 400
        fail RejectedError
      #500 (Internal Server Error)
      #503 (Service Temporarily Unavailable) when our service is overloaded (usually around 3:00–6:00 PM EST)
      when 500, 503  
        fail ServiceError, e.http_body
      else
        raise e
      end
    end

    private

    def captcha_file(challenge, referer, agent)
      file = RestClient.get challenge, {'Referer' => referer, 'User-Agent' => agent}
      if file =~ TYPE_EXIF || file =~ TYPE_JFIF || file =~ TYPE_GIF || file =~ TYPE_PNG 
        'base64:'+Base64.encode64(file)
      else
        raise RejectedError
      end
    rescue RestClient::Exception => e
      raise RejectedError
    end
  end
end
