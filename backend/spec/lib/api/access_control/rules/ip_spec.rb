require "rails_helper"

RSpec.describe Api::AccessControl::Rules::Ip do
  describe "#validate" do
    let(:request) { instance_double("Request", headers: {"X-Forwarded-For" => forwarded_ip}, remote_ip: remote_ip) }
    let(:forwarded_ip) { nil }
    let(:remote_ip) { "192.168.1.1" }
    let(:ip_rules) { [] } # Will be overridden in contexts
    subject(:checker) { described_class.new(request, ip_rules, true) }

    context "when IP is allowed" do
      let(:ip_rules) { [{type: "ip", value: remote_ip}] }

      it "returns true" do
        expect(checker.validate).to eq(true)
      end
    end

    context "when IP is not in the allowed list" do
      let(:ip_rules) { [{type: "ip", value: "10.10.10.10"}] }

      it "returns false" do
        expect(checker.validate).to eq(false)
        expect(checker.errors.any? { |item| item[:code] == "IP-ADDRESS-NOT-ALLOWED" }).to be_truthy
      end
    end

    context "when IP comes from allowed forwarded IP" do
      let(:ip_rules) { [{type: "ip", value: "10.10.10.10"}] }
      let(:forwarded_ip) { "10.10.10.10, 20.19.21.21" }

      it "returns true" do
        expect(checker.validate).to eq(true)
      end
    end

    context "when IP comes from not allowed forwarded IP" do
      let(:ip_rules) { [{type: "ip", value: "10.10.10.10"}] }
      let(:forwarded_ip) { "10.10.10.21, 20.19.21.21" }

      it "returns false" do
        expect(checker.validate).to eq(false)
      end
    end

    context "when IP is within an allowed CIDR range" do
      let(:ip_rules) { [{type: "cidr", value: "192.168.1.0/24"}] }

      it "returns true" do
        expect(checker.validate).to eq(true)
      end
    end

    context "when IP is not within any allowed CIDR range" do
      let(:ip_rules) { [{type: "cidr", value: "10.10.10.0/24"}] }

      it "returns false" do
        expect(checker.validate).to eq(false)
        expect(checker.errors.any? { |item| item[:code] == "IP-ADDRESS-NOT-ON-RANGE" }).to be_truthy
      end
    end

    context "when hostname is allowed" do
      let(:ip_rules) { [{type: "hostname", value: "example.com"}] }

      it "returns true" do
        allow(Api::IpHelper).to receive(:belongs_to_hostname_list).and_return(true)
        expect(checker.validate).to eq(true)
      end
    end

    context "when comes from hostname not allowed" do
      let(:ip_rules) { [{type: "hostname", value: "example.com"}] }

      it "returns true" do
        allow(Api::IpHelper).to receive(:belongs_to_hostname_list).and_return(false)
        expect(checker.validate).to eq(false)
        expect(checker.errors.any? { |item| item[:code] == "HOSTNAME-NOT-ALLOWED" }).to be_truthy
      end
    end

    # Add more contexts as needed for other scenarios
  end
end
