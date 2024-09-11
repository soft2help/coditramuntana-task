class Song < ApplicationRecord
  belongs_to :lp, optional: true
  has_and_belongs_to_many :authors, join_table: :song_authors

  # Validations
  validates :title, presence: true
  validates :lp_id, presence: true
  include ReportCacheInvalidation
end
