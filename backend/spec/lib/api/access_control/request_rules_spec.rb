require "rails_helper"

RSpec.describe Api::AccessControl::RequestRules do
  describe "#validate" do
    let(:request) { instance_double("Request", headers: {"X-Forwarded-For" => forwarded_ip}, remote_ip: remote_ip) }
    let(:forwarded_ip) { nil }
    let(:remote_ip) { "192.168.1.1" }
    let(:user_access_control_rules) { {} } # To be overridden in contexts
    subject(:request_rules) { described_class.new(request, user_access_control_rules, true) }

    context "when no rules are provided" do
      it "returns true" do
        expect(request_rules.validate).to be true
      end
    end

    context "when a rule that dont exist is provided" do
      let(:user_access_control_rules) { {non_existent_rule: []} }
      it "returns true" do
        request_rules.validate
        expect(request_rules.checkers.count).to eq(0)
      end
    end

    context "when a single rule is provided and passes" do
      let(:user_access_control_rules) { {ip: [{type: "ip", value: "192.168.1.1"}]} }

      before do
        allow(Api::IpHelper).to receive(:belongs_to_ip_list).and_return(true)
      end

      it "returns true" do
        expect(request_rules.validate).to be true
      end
    end

    context "when a rule fails validation" do
      let(:user_access_control_rules) { {ip: [{type: "ip", value: "192.168.1.1"}]} }

      before do
        allow(Api::IpHelper).to receive(:belongs_to_ip_list).and_return(false)
      end

      it "returns false" do
        expect(request_rules.validate).to be false
      end
    end

    context "when errors are present" do
      let(:user_access_control_rules) { {ip: [{type: "ip", value: "192.168.1.1"}]} }

      before do
        allow(Api::IpHelper).to receive(:belongs_to_ip_list).and_return(false)
      end

      it "aggregates errors from checkers" do
        request_rules.validate
        expect(request_rules.errors.count).to eq(1)
      end
    end

    context "when several checkers are setted, return on first fail" do
      let(:user_access_control_rules) { {ip: [{type: "ip", value: "192.168.1.1"}], header: [{name: "X-Required-Header", value: "XPTO"}]} }

      before do
        allow(Api::IpHelper).to receive(:belongs_to_ip_list).and_return(false)
        allow(Api::IpHelper).to receive(:belongs_to_hostname_list).and_return(false)
      end

      it "return on firt error" do
        request_rules.validate
        expect(request_rules.errors.count).to eq(1)
        expect(request_rules.errors[0][:code]).to eq("IP-ADDRESS-NOT-ALLOWED")
      end
    end
  end
end
