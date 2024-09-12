require "rails_helper"

RSpec.describe Api::AccessControl::Roles do
  describe "#validate" do
    context "when action_allowed_roles are not set" do
      subject { described_class.new(nil, [:user]) }

      it "returns the value of ALLOW_ACCESS_IF_ROLES_TO_ACTION_NOT_SET and adds an error if false" do
        stub_const("#{described_class}::ALLOW_ACCESS_IF_ROLES_TO_ACTION_NOT_SET", false)
        expect(subject.validate).to eq(false)
        expect(subject.errors).to include(include(code: "ROLES-TO-ACTION-NOT-DEFINED"))
      end
    end

    context "when user_roles are not set" do
      subject { described_class.new([:admin], nil) }

      it "returns the value of ALLOW_ACCESS_IF_USER_DONT_HAVE_ROLES and adds an error if false" do
        stub_const("#{described_class}::ALLOW_ACCESS_IF_USER_DONT_HAVE_ROLES", false)
        expect(subject.validate).to eq(false)
        expect(subject.errors).to include(include(code: "USER-ROLES-NOT-DEFINED"))
      end
      it "returns the value of ALLOW_ACCESS_IF_USER_DONT_HAVE_ROLES AND VALIDATES" do
        stub_const("#{described_class}::ALLOW_ACCESS_IF_USER_DONT_HAVE_ROLES", true)
        expect(subject.validate).to eq(true)
        expect(subject.errors.count).to eq(0)
      end
    end

    context "when user does not have any of the allowed roles" do
      subject { described_class.new([:admin], [:user]) }

      it "returns false and adds a user_dont_have_allowed_roles error" do
        expect(subject.validate).to eq(false)
        expect(subject.errors).to include(include(code: "USER-DONT-HAVE-ROLES-TO-ACTION"))
      end
    end

    context "when user has at least one of the allowed roles" do
      subject { described_class.new([:admin, :user], [:user]) }

      it "returns true" do
        expect(subject.validate).to eq(true)
        expect(subject.errors).to be_empty
      end
    end
  end
end
