require 'base64'
require 'logger'

module CaptchedToDeath
  class Client
    attr_writer :username, :password, :accept, :pause, :verbose

    # sensible defaults that can be overriden by configuration block:
    #
    # client = CaptchedToDeath::Client.new do |c|
    #   c.username = 'vivab0rg'
    #   c.password = 'deathargon'
    #   c.verbose  = true
    # end
    #
    # client = CaptchedToDeath::Client.new('vivab0rg','deathargon')
    #
    def initialize(*credentials)
      @accept  = :json
      @pause   = 15  # in seconds
      @verbose = false
      if credentials.size == 2
        @username = credentials[0]
        @password = credentials[1]
      end
      yield self if block_given?

      RestClient.log = Logger.new(STDOUT) if @verbose
    end

    def balance
      fail ArgumentError if @username.nil? || @password.nil?
      response = RestClient.post API_URI+"/user", {:username => @username, :password => @password}, :accept => @accept
      fail ServiceError unless response.code == 200
      JSON.parse(response) 
    end

    def captcha(id)
      response = RestClient.get API_URI+"/captcha/#{id}", {:accept => @accept}
      fail ServiceError unless response.code == 200
      JSON.parse(response)
    end

    def decode(challenge, referer=nil, agent=nil)
      fail ArgumentError if @username.nil? || @password.nil?

      captchafile = RestClient.get challenge, {'Referer' => referer, 'User-Agent' => agent}

      RestClient.post API_URI+"/captcha", {:username => @username, :password => @password, :captchafile => 'base64:'+Base64.encode64(captchafile)}, :accept => @accept do |response, request, result, &block|
        case response.code
        when 303  # (See Other) CAPTCHA successfully uploaded: Location HTTP header will point to the status page
          # RestClient: for result code 303 the redirection will be followed and the request transformed into a get
          decoded = JSON.parse(response) 
          while decoded['text'].empty?  # (empty string if not solved yet)
            sleep @pause
            decoded = captcha(decoded['captcha']) 
          end
          decoded
        when 403  # (Forbidden) credentials were rejected, or you don't have enough credits
          # TODO: should discrimate RejectedError
          raise NoCreditError
        when 400  # (Bad Request) if your request was not following the specification or not a valid image
        when 500  # (Internal Server Error)
        when 503  # (Service Temporarily Unavailable) when our service is overloaded (usually around 3:00–6:00 PM EST)
        else
          response.return!(request, result, &block)
        end
      end
    end
  end
end
