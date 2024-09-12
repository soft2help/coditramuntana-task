require "rails_helper"

RSpec.describe Api::AccessControl::Validator do
  let(:instance) { described_class.instance }
  let(:checker) {
    Api::AccessControl::Permissions.new("Api::V1::Music::Artists::show", "r", {
      "Api::V1::Music::Artists::show" => "r"
    })
  }

  before do
    allow(checker).to receive(:add_validator)
    allow(checker).to receive(:validate)
    instance.add(checker)
  end

  describe "#add" do
    it "adds a checker" do
      expect(instance.checkers).to include(checker)
    end
  end

  describe "#validate" do
    context "when all checkers are valid" do
      before do
        allow(checker).to receive(:validate).and_return(true)
      end

      it "returns true" do
        expect(instance.validate).to eq(true)
      end
    end

    context "when a checker is invalid" do
      before do
        allow(checker).to receive(:validate).and_return(false)
      end

      it "returns false" do
        expect(instance.validate).to eq(false)
      end
    end
  end
end
