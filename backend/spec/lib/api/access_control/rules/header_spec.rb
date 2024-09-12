# spec/api/access_control/rules/header_spec.rb
require "rails_helper"

RSpec.describe Api::AccessControl::Rules::Header do
  describe "#validate" do
    let(:request) { double(headers: request_headers) }
    let(:header_rules) { [] } # Will be overridden in contexts
    subject(:checker) { described_class.new(request, header_rules, true) }

    context "when header rules are satisfied" do
      let(:request_headers) { {"X-Custom-Header" => "ExpectedValue"} }
      let(:header_rules) { [{name: "X-Custom-Header", value: "ExpectedValue"}] }

      it "returns true" do
        expect(checker.validate).to be true
        expect(checker.errors).to be_empty
      end
    end

    context "when a required header is not present" do
      let(:request_headers) { {} }
      let(:header_rules) { [{name: "X-Required-Header", value: nil}] }

      it "returns false" do
        expect(checker.validate).to be false

        expect(checker.errors.any? { |item| item[:code] == "HEADER-NOT-PRESENT" }).to be_truthy
      end
    end

    context "when a header value does not match the expected value" do
      let(:request_headers) { {"X-Custom-Header" => "WrongValue"} }
      let(:header_rules) { [{name: "X-Custom-Header", value: "ExpectedValue"}] }

      it "returns false" do
        expect(checker.validate).to be false
        expect(checker.errors.any? { |item| item[:code] == "HEADER-VALUE-NOT-VALID" }).to be_truthy
      end
    end
  end
end
