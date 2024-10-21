# frozen_string_literal: true

require 'json'
require_relative 'lambda/error_handler'
require_relative 'lambda/logger'
require_relative 'lambda/version'
require 'sheet_zoukas'

module SheetZoukas
  # module for interacting with AWS Lambda
  module Lambda
    class Error < StandardError; end
    class InvalidArgumentError < Error; end

    def self.lambda_handler(event:, context:)
      logger('DEBUG', "lambda_handler event: #{event}")
      logger('DEBUG', "lambda_handler context: #{context}")
      logger('DEBUG', "lambda_handler defaults: #{defaults}")

      payload = extract_payload(event)
      call_sheet(payload['sheet_id'], payload['tab_name'], payload['range'])
    end

    private_class_method def self.logger(log_level, log_payload)
      SheetZoukas::Lambda::Logger.log(log_level, log_payload)
    end

    private_class_method def self.call_sheet(sheet_id, tab_name, range = nil)
      SheetZoukas.retrieve_sheet_json(sheet_id, tab_name, range)
    rescue StandardError => e
      logger('ERROR', "call_sheet: sheet_id: #{sheet_id}\ntab_name: #{tab_name}\nrange: #{range}")
      logger('ERROR', "call_sheet:\n #{e}")

      SheetZoukas::Lambda::ErrorHandler.extrapolate_and_build_error(e).to_json
    end

    private_class_method def self.extract_body(event)
      event['body'] ? JSON.parse(event['body']) : nil
    end

    private_class_method def self.extract_query_string_parameters(event)
      event['queryStringParameters'] || nil
    end

    private_class_method def self.extract_payload(event)
      payload = extract_body(event) || extract_query_string_parameters(event) || {}
      logger('DEBUG', "extract_paylaod: #{payload}")
      merge_defaults(event['rawPath'], payload)
    end

    private_class_method def self.merge_defaults(path, payload)
      return payload unless path == '/defaults'

      logger('DEBUG', "merge_defaults -- MERGING: payload: #{payload} path: #{path}")
      defaults.merge(payload)
    end

    private_class_method def self.validate_payload(payload)
      return unless payload['sheet_id'].strip.empty? || payload['tab_name'].strip.empty?

      raise InvalidArgumentError, ''
    end

    private_class_method def self.defaults
      {
        'sheet_id' => ENV.fetch('DEFAULT_SHEET_ID', nil),
        'tab_name' => ENV.fetch('DEFAULT_TAB_NAME', nil),
        'range' => ENV.fetch('DEFAULT_RANGE', nil)
      }.compact
    end
  end
end
