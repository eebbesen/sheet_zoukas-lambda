# frozen_string_literal: true

module SheetZoukas
  module Lambda
    # generate a hash with the status code and error message
    class ErrorHandler
      def self.build_400_bad_request(error)
        build_http_error(400, error)
      end

      def self.build_403_forbidden(error)
        build_http_error(403, error)
      end

      private_class_method def self.build_http_error(status_code, error)
        {
          statusCode: status_code,
          body: {
            error: error.detailed_message
          }.to_json
        }
      end
    end
  end
end
