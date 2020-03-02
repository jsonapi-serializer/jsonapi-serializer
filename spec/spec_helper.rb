require 'simplecov'

SimpleCov.start do
  add_group 'Lib', 'lib'
  add_group 'Tests', 'spec'
end
SimpleCov.minimum_coverage 90

require 'active_record'
require 'fast_jsonapi'
require 'byebug'

Dir[File.dirname(__FILE__) + '/shared/contexts/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/shared/examples/*.rb'].each {|file| require file }
