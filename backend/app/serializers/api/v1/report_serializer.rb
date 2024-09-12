class Api::V1::ReportSerializer < ActiveModel::Serializer
  attributes :lp_name, :artist_name, :song_count, :authors_list
end
