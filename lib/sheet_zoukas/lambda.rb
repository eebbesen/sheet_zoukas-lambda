# frozen_string_literal: true

require_relative 'lambda/version'
require_relative 'lambda/logger'
require 'json'
require 'sheet_zoukas'

module SheetZoukas
  # module for interacting with AWS Lambda
  module Lambda
    class Error < StandardError; end

    def self.lambda_handler(event:, context:)
      SheetZoukas::Lambda::Logger.log('DEBUG', "event: #{event}")
      SheetZoukas::Lambda::Logger.log('DEBUG', "context: #{context}")

      payload = extract_payload(event)
      call_sheet(payload['sheet_id'], payload['tab_name'], payload['range'])
    end

    private_class_method def self.call_sheet(sheet_id, tab_name, range = nil)
      SheetZoukas.retrieve_sheet_json(sheet_id, tab_name, range)
    rescue StandardError => e
      SheetZoukas::Lambda::Logger.log('DEBUG', "sheet_id: #{sheet_id}\ntab_name: #{tab_name}\nrange: #{range}")
      SheetZoukas::Lambda::Logger.log('ERROR', "call_sheet:\n #{e}")
      raise e
    end

    private_class_method def self.extract_body(event)
      event['body'] || ''
    end

    private_class_method def self.extract_query_string_parameters(event)
      event['queryStringParameters'] || ''
    end

    private_class_method def self.extract_payload(event)
      if event['body']
        extract_body(event)
      elsif event['queryStringParameters']
        extract_query_string_parameters(event)
      else
        raise Error, 'event does not contain body or queryStringParameters'
      end
    rescue StandardError => e
      SheetZoukas::Lambda::Logger.log('ERROR', "extract_payload:\n #{e}")
      raise Error, e
    end
  end
end
