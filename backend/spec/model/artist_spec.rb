require "rails_helper"

RSpec.describe Artist, type: :model do
  # Setup: Create a valid artist object
  let(:artist) { Artist.new(name: "Test Artist") }

  # Test validation presence of name
  it "is valid with a name" do
    expect(artist).to be_valid
  end

  # Test validation of the presence of the name field
  it "is invalid without a name" do
    artist.name = nil
    expect(artist).to_not be_valid
    expect(artist.errors[:name]).to include("can't be blank")
  end

  # Test validation of the uniqueness of the name field
  it "is invalid with a duplicate name" do
    Artist.create!(name: "Test Artist")
    duplicate_artist = Artist.new(name: "Test Artist")

    expect(duplicate_artist).to_not be_valid
    expect(duplicate_artist.errors[:name]).to include("has already been taken")
  end
end
