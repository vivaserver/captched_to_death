require 'json'
require 'rubygems'
require 'bundler/setup'
require 'rest_client'

module CaptchedToDeath
  API_URI = 'http://api.dbcapi.me/api'

  class NoCreditError < StandardError; end
  class NotFound      < StandardError; end
  class RejectedError < StandardError; end
  class ServiceError  < StandardError; end

  # ref. http://github.com/dim/ruby-imagespec
  # see: http://boonedocks.net/mike/archives/162-Determining-Image-File-Types-in-Ruby.html

  TYPE_EXIF = /^\xff\xd8\xff\xe1(.*){2}Exif/
  TYPE_GIF  = /^GIF8/
  TYPE_JFIF = /^\xff\xd8\xff\xe0\x00\x10JFIF/
  TYPE_PNG  = /^\x89PNG/
end

require "captched_to_death/client"
require "captched_to_death/server"
require "captched_to_death/version"
