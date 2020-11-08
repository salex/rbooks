ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all


  # Add more helper methods to be used by all tests here...


  module SignInHelper
    def sign_in_as(user)
      post test_signin_users_url(email: user.username, password: 'secret')
    end
  end
   
  class ActionDispatch::IntegrationTest
    include SignInHelper
  end

end
