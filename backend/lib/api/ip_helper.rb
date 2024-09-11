module Api
  class IpHelper
    def self.belongs_to_ip_list(ip_to_check, cidrs_and_ips)
      cidr_objects = to_array(cidrs_and_ips).map { |cidr_or_ip| IPAddr.new(cidr_or_ip) }
      cidr_objects.any? { |cidr| cidr.include?(ip_to_check) }
    end

    def self.belongs_to_hostname_list(ip_to_check, hostnames)
      hostnames = to_array(hostnames)
      hostnames.any? { |hostname| Resolv.getaddresses(hostname).include?(ip_to_check) }
    rescue Resolv::ResolvError
      false
    end
  end
end
