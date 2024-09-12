require "rails_helper"

RSpec.describe Api::AccessControl::Permissions do
  let(:token_permissions) do
    {
      "Api::V1" => "",
      "Api::V1::Music" => "-r,-w",
      "Api::V1::Music::Artists" => "w",

      "Api::V1::Music::Artists::update" => "-w",
      "Api::V1::Music::Artists::show" => "r",

      "Api::V1::Music::Bands" => "r",
      "Api::V1::Music::Shows" => "-r",
      "Api::V1::Music::Shows::show" => "r",
      "Api::V1::Events" => "w",
      "Api::V1::Music::Albums" => "-r,w"
    }
  end

  describe "Check permissions" do
    context "check" do
      it "specific rule defined for endpoint" do
        expect(described_class.check("Api::V1::Music::Artists::show", "r", token_permissions)).to be_truthy
      end
      it "check in parent rule that will be forbidden" do
        expect(described_class.check("Api::V1::Music::Artists::index", "r", token_permissions)).to be_falsey
      end
      it "check in rule with forbidden operation" do
        expect(described_class.check("Api::V1::Music::Artists::update", "w", token_permissions)).to be_falsey
      end
      it "check the rule in parent that have defined operations that can be allowed different from requested" do
        expect(described_class.check("Api::V1::Music::Artists::send_email", "x", token_permissions)).to be_falsey
      end
      it "check the rule in all parents, that dont have anything defined so should be the default behavior configured " do
        expect(described_class.check("Api::V1::Music::Shows::send_email", "x", token_permissions)).to eq(Api::AccessControl::Permissions::ALLOW_ACTION_IF_NO_PERMISSION_SET)
      end
      it "check the rule in parent, that have different operations allowed from the requested" do
        expect(described_class.check("Api::V1::Music::Albums::send_email", "x", token_permissions)).to be_falsey
      end
      it "[r]check the rule in parent, that only have defined operation of w" do
        expect(described_class.check("Api::V1::Events::Artists::index", "r", token_permissions)).to be_falsey
      end
      it "[w]check the rule in parent, that only have defined operation of w" do
        expect(described_class.check("Api::V1::Events::Artists::create", "w", token_permissions)).to be_truthy
      end
      it "[x]check the rule in parent, that only have defined operation of w" do
        expect(described_class.check("Api::V1::Events::Artists::notification", "x", token_permissions)).to be_falsey
      end
    end
  end
end
