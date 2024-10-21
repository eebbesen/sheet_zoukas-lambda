# rubocop:disable RSpec/ExampleLength
# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/sheet_zoukas/lambda/error_handler'
require_relative '../../../lib/sheet_zoukas/lambda'

RSpec.describe SheetZoukas::Lambda::ErrorHandler do
  describe '.build_http_error' do
    it 'returns a hash with the status code and error message' do
      result = described_class.send(:build_http_error, 500, StandardError.new('Something went wrong').detailed_message)
      expected_result = {
        statusCode: 500,
        body: { error: 'Something went wrong (StandardError)' }
      }

      expect(result).to eq(expected_result)
    end
  end

  describe '.extrapolate_and_build_error' do
    describe 'returns 400' do
      it 'when required parameters present but rejected by google' do
        expected_result = {
          statusCode: 400,
          body: { error: "google rejected sheet_id and/or tab_name\nGoogle::Apis::ClientError" }
        }

        expect(described_class.extrapolate_and_build_error(Google::Apis::ClientError.new('')))
          .to eq(expected_result)
      end

      it 'when missing required parameters' do
        expected_result = {
          statusCode: 400,
          body: { error: "populated sheet_id and tab_name are required\n" \
                         'SheetZoukas::Lambda::InvalidArgumentError (SheetZoukas::Lambda::InvalidArgumentError)' }
        }

        expect(described_class.extrapolate_and_build_error(SheetZoukas::Lambda::InvalidArgumentError.new))
          .to eq(expected_result)
      end
    end

    it 'returns 403 when server fails to authenticate with google' do
      expected_result = {
        statusCode: 403,
        body: { error: "server failed to authenticate with google\nAuthorization failed. (Signet::AuthorizationError)" }
      }

      expect(described_class.extrapolate_and_build_error(Signet::AuthorizationError.new('Authorization failed.')))
        .to eq(expected_result)
    end

    it 'raises error if not a known error type' do
      expect { described_class.extrapolate_and_build_error(StandardError.new) }
        .to raise_error(StandardError)
    end
  end
end

# rubocop:enable RSpec/ExampleLength
