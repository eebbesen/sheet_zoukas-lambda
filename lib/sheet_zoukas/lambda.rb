# frozen_string_literal: true

require_relative 'lambda/version'
require_relative 'lambda/logger'
require 'sheet_zoukas'

module SheetZoukas
  # module for interacting with AWS Lambda
  module Lambda
    class Error < StandardError; end

    def self.lambda_handler(event:, context:)
      SheetZoukas::Lambda::Logger.log('DEBUG', "event: #{event}")
      SheetZoukas::Lambda::Logger.log('DEBUG', "context: #{context}")

      sheet_id = event['sheet_id']
      tab_name = event['tab_name']
      range = event['range']

      call_sheet(sheet_id, tab_name, range)
    end

    private_class_method def self.call_sheet(sheet_id, tab_name, range = nil)
      SheetZoukas.retrieve_sheet_json(sheet_id, tab_name, range)
    rescue StandardError => e
      SheetZoukas::Lambda::Logger.log('DEBUG', "sheet_id: #{sheet_id}\ntab_name: #{tab_name}\nrange: #{range}")
      SheetZoukas::Lambda::Logger.log('ERROR', "call_sheet:\n #{e}")
      raise e
    end
  end
end
