# frozen_string_literal: true

module SheetZoukas
  module Lambda
    # very simple class for logging
    class Logger
      # DEBUG logs everything
      def self.log(level, payload)
        # using puts because AWS Lambda uses that for CloudWatch
        puts("#{level}: #{payload}") if log_level == 'DEBUG' || level == log_level
      end

      private_class_method def self.log_level
        ENV.fetch('ZOUKAS_LOG_LEVEL', 'ERROR')
      end
    end
  end
end
