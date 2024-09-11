require "rails_helper"

RSpec.describe User, type: :model do
  it "is valid with a valid email" do
    user = User.new(email: "valid@example.com", password: "Strong2024*")
    expect(user).to be_valid
  end

  it "is invalid with an invalid email" do
    user = User.new(email: "invalid-email")
    expect(user).to_not be_valid
    expect(user.errors[:email]).to include("must be a valid email address")
  end

  it "is invalid without an email" do
    user = User.new(email: nil)
    expect(user).to_not be_valid
    expect(user.errors[:email]).to include("can't be blank")
  end

  it "is invalid with a duplicate email" do
    User.create!(email: "test@example.com", password: "Strong2024*")
    duplicate_user = User.new(email: "test@example.com")
    expect(duplicate_user).to_not be_valid
    expect(duplicate_user.errors[:email]).to include("has already been taken")
  end

  it "invalid password" do
    user = User.new(email: "test@example.com", password: "123")

    expect(user).to_not be_valid
    expect(user.errors[:password]).to include("must include at least 1 uppercase letter, 1 lowercase letter, 1 digit, and 1 special character (@$!%*?&), and be at least 8 characters long.")
  end
end
