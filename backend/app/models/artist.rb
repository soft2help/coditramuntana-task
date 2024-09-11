class Artist < ApplicationRecord
  has_many :lps
  validates :name, presence: true, uniqueness: true

  validates :name, length: {minimum: 3, maximum: 50}, presence: true
  include ReportCacheInvalidation

  def cached_lp_count
    Rails.cache.fetch([self, "lp_count"]) do
      lps.count
    end
  end

  def invalidate_lp_cache
    Rails.cache.delete([self, "lp_count"])
  end
end
