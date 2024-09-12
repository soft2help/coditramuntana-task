class Api::V1::LpSerializer < ActiveModel::Serializer
  attributes :name, :description, :artist_id
end
