require 'active_record'
require 'fast_jsonapi'
require 'byebug'

Dir[File.dirname(__FILE__) + '/shared/contexts/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/shared/examples/*.rb'].each {|file| require file }
