ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specify number of workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures (if any exist under test/fixtures and uncomment the following line)
  # fixtures :all
end
