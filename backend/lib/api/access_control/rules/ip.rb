module Api
  module AccessControl
    module Rules
      class Ip < Api::AccessControl::Checker
        include FieldEnumerable
        ERROR_IDENTIFIER = 1
        attr_reader :request, :ip_address, :rules
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

        field_enum checker: {
          ip: "ip",
          cidr: "cidr",
          hostname: "hostname"
        }, _prefix: false

        def initialize(request, ip_rules, with_errors = false)
          super(with_errors)
          @request = request
          @rules = ip_rules || []
          @ip_address = origin_ip_address
        end

        def error_codes
          {
            ip: {code: "IP-ADDRESS-NOT-ALLOWED", message: "IP address is not allowed"},
            cidr: {code: "IP-ADDRESS-NOT-ON-RANGE", message: "IP address is not on range"},
            hostname: {code: "HOSTNAME-NOT-ALLOWED", message: "hostname is not allowed"}
          }
        end

        def validate
          rules.each do |rule|
            if respond_to?(:"by_#{rule[:type]}", true)
              return false unless send(:"by_#{rule[:type]}", rule[:value])
            end
          end
          true
        end

        private

        def origin_ip_address
          forwarded_ip = @request&.headers&.[]("X-Forwarded-For")
          forwarded_ip ? forwarded_ip.split(",").first.strip : @request&.remote_ip
        end

        def by_ip(ip_addresses)
          check_it :ip do
            Api::IpHelper.belongs_to_ip_list(ip_address, to_array(ip_addresses))
          end
        end

        def by_cidr(cidrs)
          check_it :cidr do
            Api::IpHelper.belongs_to_ip_list(ip_address, to_array(cidrs))
          end
        end

        def by_hostname(hostnames)
          check_it :hostname do
            Api::IpHelper.belongs_to_hostname_list(ip_address, hostnames)
          end
        end
      end
    end
  end
end
