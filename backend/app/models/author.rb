class Author < ApplicationRecord
  has_and_belongs_to_many :songs, join_table: :song_authors
  # Validations
  validates :name, presence: true, uniqueness: true
  include ReportCacheInvalidation
end
