ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock/minitest'
require 'droplet_kit'
require 'request_stub_helpers'

class ActiveSupport::TestCase

  include RequestStubHelpers

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # WebMock.after_request do |request_signature, response|
  #   p request_signature
  #   p response
  # end


  # @return [String]
  def self.generate_random_string(len=8)
    (0..len).map {(65 + rand(26)).chr}.join.downcase
  end


end
