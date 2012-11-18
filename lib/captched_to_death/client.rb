require 'base64'
require 'logger'

module CaptchedToDeath
  class Client
    attr_writer :username, :password, :accept, :verbose

    # Sensible defaults that can be overriden by configuration block:
    #
    #   client = CaptchedToDeath::Client.new do |c|
    #     c.username = 'username'
    #     c.password = 'password'
    #     c.verbose  = true
    #   end
    #
    # or just:
    #
    #   client = CaptchedToDeath::Client.new('username','password')
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

    # User credit balance, includes account details.
    #
    def balance
      fail RejectedError if empty_credentials?
      response = RestClient.post "#{API_URI}/user", {:username => @username, :password => @password}, :accept => @accept
      fail ServiceError unless response.code == 200
      JSON.parse(response) 
    end

    # Polls for uploaded CAPTCHA status.
    # You don't have to supply your Death by Captcha credentials this time.
    # Please don't poll for a CAPTCHA status more than once in a couple of seconds.
    # This is considered abusive and might get you banned.
    #
    def captcha(captcha_id)
      response = RestClient.get "#{API_URI}/captcha/#{captcha_id}", {:accept => @accept}
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

    # Solving a CAPTCHA using Death by Captcha HTTP API requires performing at least two steps.
    #
    def decode(challenge_url, referer=nil, agent=nil)
      fail RejectedError if empty_credentials?

      response = RestClient.post "#{API_URI}/captcha", {
        :username    => @username,
        :password    => @password,
        :captchafile => captcha_file(challenge_url,referer,agent)
      }, :accept => @accept
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

    # Reports incorrectly solved CAPTCHAs.
    # If you think your CAPTCHA was solved incorrectly, report it to Death by Captcha to get your money back.
    # You'll get refunded if the CAPTCHA was uploaded less than an hour ago.
    #
    def report(captcha_id)
      fail RejectedError if empty_credentials?

      response = RestClient.post "#{API_URI}/captcha/#{captcha_id}/report", {
        :username => @username,
        :password => @password,
      }, :accept => @accept

      JSON.parse(response) 
    end

    private

    def captcha_file(challenge_url, referer, agent)  #:nodoc:
      file = RestClient.get challenge_url, {'Referer' => referer, 'User-Agent' => agent}
      if file =~ TYPE_EXIF || file =~ TYPE_JFIF || file =~ TYPE_GIF || file =~ TYPE_PNG 
        'base64:'+Base64.encode64(file)
      else
        raise RejectedError
      end
    end

    def empty_credentials?  #:nodoc:
      return true if @username.to_s.empty? || @password.to_s.empty?
      false
    end
  end
end
