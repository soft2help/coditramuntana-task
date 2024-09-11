require "rails_helper"

RSpec.describe Artist, type: :model do
  describe "deleting an artist and associated records" do
    let!(:artist) { Artist.create(name: "Metallica") }
    let!(:lp) { artist.lps.create(name: "Master of Puppets") }
    let!(:song1) { lp.songs.create(title: "Battery") }
    let!(:song2) { lp.songs.create(title: "Master of Puppets") }

    context "when an artist is destroyed" do
      it "deletes all associated LPs and sets lp_id to NULL for songs" do
        # Ensure the artist, LP, and songs exist before deletion
        expect(Artist.exists?(artist.id)).to be_truthy
        expect(Lp.exists?(lp.id)).to be_truthy
        expect(Song.exists?(song1.id)).to be_truthy
        expect(Song.exists?(song2.id)).to be_truthy

        # Destroy the artist
        artist.destroy

        # Verify LPs are deleted
        expect(Lp.exists?(lp.id)).to be_falsey

        # Verify Songs remain and lp_id is set to NULL
        expect(song1.reload.lp_id).to be_nil
        expect(song2.reload.lp_id).to be_nil

        # Ensure songs are still present in the database
        expect(Song.exists?(song1.id)).to be_truthy
        expect(Song.exists?(song2.id)).to be_truthy
      end
    end
  end
end
