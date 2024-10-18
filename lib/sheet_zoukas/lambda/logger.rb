# frozen_string_literal: true

module SheetZoukas
  module Lambda
    # class for logging
    class Logger
      def self.log(level, payload)
        # using puts because AWS Lambda uses that for CloudWatch
        puts("#{level}: #{payload}")
      end
    end
  end
end
