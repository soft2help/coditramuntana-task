module Api
  module AccessControl
    module Rules
      class Header < Api::AccessControl::Checker
        attr_reader :request_headers, :rules
        #   {
        #     ip: [
        #       {type: "ip", value: "192.168.1.1"},
        #       {type: "cidr", value: "192.168.0.0/24"},
        #       {type: "hostname", value: "example.com"}
        #     ],
        #     header: [
        #       {name: "X-Custom-Header", value: "ExpectedValue"},
        #       {name: "X-Required-Header", value: nil} # Presence check only
        #     ]
        #   }
        def initialize(request, header_rules, with_errors = false)
          super(with_errors)
          @request_headers = request&.headers || []
          @rules = header_rules || []
        end

        def error_codes
          {
            header_not_present: {code: "HEADER-NOT-PRESENT", message: "Header is not present"},
            header_value_invalid: {code: "HEADER-VALUE-NOT-VALID", message: "Header value is invalid"}
          }
        end

        def validate
          rules.each do |rule|
            return false unless check_header(rule[:name], rule[:value])
          end
          true
        end

        private

        def check_header(header_name, header_value)
          if header_value.nil?
            add_error :header_not_present if with_errors
            return request_headers[header_name].present?
          end

          is_valid = (request_headers[header_name] == header_value)

          add_error :header_value_invalid if with_errors && !is_valid
          is_valid
        end
      end
    end
  end
end
