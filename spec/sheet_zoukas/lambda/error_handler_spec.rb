# rubocop:disable RSpec/ExampleLength
# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/sheet_zoukas/lambda/error_handler'
require_relative '../../../lib/sheet_zoukas/lambda'

RSpec.describe SheetZoukas::Lambda::ErrorHandler do
  describe '.build_http_error' do
    it 'returns a hash with the status code and error message' do
      result = described_class.send(:build_http_error, 500, StandardError.new('Something went wrong'))
      expected_result = {
        statusCode: 500,
        body: { error: 'Something went wrong (StandardError)' }.to_json
      }

      expect(result).to eq(expected_result)
    end
  end

  describe '.build_403_forbiden' do
    after { ENV.store('USE_REAL_AUTHORIZER', '') }

    it 'returns a hash with the status code 400 and error message' do
      error_message = 'Method doesn\'t allow unregistered callers (callers without established identity). ' \
                      'Please use API Key or other form of API consumer identity to call this API.'
      expected_result = {
        statusCode: 403,
        body: { error: "#{error_message} (StandardError)" }.to_json
      }

      expect(described_class.build_403_forbidden(StandardError.new(error_message)))
        .to eq(expected_result)
    end
  end

  describe '.build_400_bad_request' do
    it 'hides stack trace and shows error message & exception class' do
      exception = SheetZoukas::Lambda::InvalidArgumentError
                  .new("populated sheet_id and tab_name are required\npayload: {\"sheet_id\"=>\"\"}")
      expected_result = {
        statusCode: 400,
        body: { error: 'populated sheet_id and tab_name are required (SheetZoukas::Lambda::InvalidArgumentError)' \
                       "\npayload: {\"sheet_id\"=>\"\"}" }.to_json
      }

      expect(described_class.build_400_bad_request(exception)).to eq(expected_result)
    end
  end
end

# rubocop:enable RSpec/ExampleLength
