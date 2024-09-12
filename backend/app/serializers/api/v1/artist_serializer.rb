class Api::V1::ArtistSerializer < ActiveModel::Serializer
  attributes :name, :description, :created_at, :updated_at

  def initialize(object, options = {})
    super
    @with_lp_count = options[:with_lp_count]
  end

  def attributes(*args)
    hash = super
    if @with_lp_count
      hash[:lp_count] = object.cached_lp_count
    end

    hash
  end
end
