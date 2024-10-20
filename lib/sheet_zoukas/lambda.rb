# frozen_string_literal: true

require_relative 'lambda/version'
require_relative 'lambda/logger'
require 'json'
require 'sheet_zoukas'

module SheetZoukas
  # module for interacting with AWS Lambda
  module Lambda
    class Error < StandardError; end
    class InvalidArgumentError < Error; end

    def self.lambda_handler(event:, context:)
      SheetZoukas::Lambda::Logger.log('DEBUG', "lambda_handler event: #{event}")
      SheetZoukas::Lambda::Logger.log('DEBUG', "lambda_handler context: #{context}")
      SheetZoukas::Lambda::Logger.log('DEBUG', "lambda_handler defaults: #{defaults}")

      payload = extract_payload(event)
      call_sheet(payload['sheet_id'], payload['tab_name'], payload['range'])
    end

    private_class_method def self.call_sheet(sheet_id, tab_name, range = nil)
      SheetZoukas.retrieve_sheet_json(sheet_id, tab_name, range)
    rescue StandardError => e
      SheetZoukas::Lambda::Logger.log('ERROR',
                                      "call_sheet: sheet_id: #{sheet_id}\ntab_name: #{tab_name}\nrange: #{range}")
      SheetZoukas::Lambda::Logger.log('ERROR', "call_sheet:\n #{e}")
      raise e
    end

    private_class_method def self.extract_body(event)
      event['body'] ? JSON.parse(event['body']) : nil
    end

    private_class_method def self.extract_query_string_parameters(event)
      event['queryStringParameters'] || nil
    end

    private_class_method def self.extract_payload(event)
      payload = extract_body(event) || extract_query_string_parameters(event) || {}
      SheetZoukas::Lambda::Logger.log('DEBUG', "extract_paylaod: #{payload}")
      merge_defaults(event['rawPath'], payload)
    end

    private_class_method def self.merge_defaults(path, payload)
      return payload unless path == '/defaults'

      SheetZoukas::Lambda::Logger.log('DEBUG', "merge_defaults -- MERGING: payload: #{payload} path: #{path}")
      defaults.merge(payload)
    end

    private_class_method def self.validate_payload(payload)
      return unless payload['sheet_id'].strip.empty? || payload['tab_name'].strip.empty?

      raise InvalidArgumentError, "populated sheet_id and tab_name are required\npayload: #{payload}"
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
