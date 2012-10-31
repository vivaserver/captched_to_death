require 'json'
require 'rubygems'
require 'bundler/setup'
require 'rest_client'

module CaptchedToDeath
  API_URI = 'http://api.dbcapi.me/api'

  class NoCreditError < StandardError; end
  class RejectedError < StandardError; end
  class ServiceError  < StandardError; end
end

require "captched_to_death/client"
require "captched_to_death/server"
require "captched_to_death/version"
