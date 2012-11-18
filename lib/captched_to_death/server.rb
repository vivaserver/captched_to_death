module CaptchedToDeath
  class Server
    # Current server status
    def self.status
      response = RestClient.get "#{API_URI}/status", :accept => :json
      fail ServiceError unless response.code == 200
      JSON.parse(response) 
    end
  end
end
