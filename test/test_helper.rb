ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all


  # @return [String]
  def self.generate_random_string(len=8)
    (0..len).map {(65 + rand(26)).chr}.join.downcase
  end


end
