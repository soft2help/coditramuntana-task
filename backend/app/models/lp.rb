class Lp < ApplicationRecord
  belongs_to :artist
  has_many :songs

  validates :name, presence: true
  validates :artist_id, presence: true
  include ReportCacheInvalidation

  after_commit :invalidate_artist_lp_cache

  private

  def invalidate_artist_lp_cache
    artist.invalidate_lp_cache
  end
end
