require 'json'
require 'rubygems'
require 'bundler/setup'
require 'rest_client'

module CaptchedToDeath
  # The base URI for the new DeathByCaptcha API. See DeathByCaptcha.txt
  API_URI = 'http://api.dbcapi.me/api'

  # Exception for insufficient user credits
  class NoCreditError < StandardError; end

  # Exception for unexisting CAPTCHA on status retreiving
  class NotFound < StandardError; end

  # Exception for missing/wrong user credentials; invalid captcha challenge
  class RejectedError < StandardError; end

  # Exception for server overloaded outage
  class ServiceError < StandardError; end

  # RegExps stolen from http://github.com/dim/ruby-imagespec
  # see related blog post at http://boonedocks.net/mike/archives/162-Determining-Image-File-Types-in-Ruby.html
  #
  TYPE_EXIF = /^\xff\xd8\xff\xe1(.*){2}Exif/
  TYPE_JFIF = /^\xff\xd8\xff\xe0\x00\x10JFIF/
  TYPE_GIF  = /^GIF8/
  TYPE_PNG  = /^\x89PNG/
end

require "captched_to_death/client"
require "captched_to_death/server"
require "captched_to_death/version"
