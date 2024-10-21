# frozen_string_literal: true

module SheetZoukas
  module Lambda
    # generate a hash with the status code and error message
    class ErrorHandler
      # responds to client with faux HTTP response for smoother operation
      # raises error if not a known error type
      def self.extrapolate_and_build_error(error)
        case error
        when Signet::AuthorizationError
          build_http_error(403, "server failed to authenticate with google\n#{error.detailed_message}")
        when Google::Apis::ClientError
          build_http_error(400, "google rejected sheet_id and/or tab_name\n#{error.detailed_message}")
        when InvalidArgumentError
          build_http_error(400, "populated sheet_id and tab_name are required\n#{error.detailed_message}")
        else
          raise error
        end
      end

      private_class_method def self.build_http_error(status_code, message)
        {
          statusCode: status_code,
          body: {
            error: message
          }
        }
      end
    end
  end
end
