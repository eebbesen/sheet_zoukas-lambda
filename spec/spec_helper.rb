# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  enable_coverage :branch
  add_filter 'spec/'
end

require 'byebug'
require 'sheet_zoukas/lambda'
require 'vcr'
require 'webmock/rspec'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# initialize required environment variables to test values
# will need to comment this out when recording cassettes
ENV.store('GOOGLE_ACCOUNT_TYPE', 'service_account')
ENV.store('GOOGLE_API_KEY', 'fake_google_api_key')
ENV.store('GOOGLE_CLIENT_EMAIL', 'sheet@zoukas.zoukas')
ENV.store('GOOGLE_CLIENT_ID', 'fake_google_client_id')
ENV.store('GOOGLE_PRIVATE_KEY', "----BEGIN PRIVATE KEY-----\nfake_google_private_key==\n-----END PRIVATE KEY-----\n")

module SheetZoukas
  # for testing don't try to authenticate with Google
  # will need to remove when recording new VCR cassettes
  class GoogleSheets
    Authorizer = Struct.new(:scope)

    private

    def init_authorizer(scope)
      scopes = scope.is_a?(Array) ? scope : [scope]
      @authorizer = Authorizer.new(scopes)
    end
  end
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
end
