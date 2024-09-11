class Setting < ApplicationRecord
  # Constants
  PREFIX_SETTINGS = Rails.application.config.prefix_settings

  # Validations
  validates :key, uniqueness: true, presence: true
  validates :value, presence: true
  validates :group, presence: true

  # Class Methods

  # Get the value of a setting by group and key
  def self.get(group, key)
    Rails.cache.fetch("#{PREFIX_SETTINGS}#{group}")[key.to_sym]
  rescue
    begin
      by_group(group)[key.to_sym]
    rescue
      nil
    end
  end

  # Set or update a setting
  def self.set(group, key, value)
    setting = find_or_initialize_by(group: group, key: key)
    setting.value = value
    Rails.cache.delete("#{PREFIX_SETTINGS}#{group}") if setting.save
  end

  # Fetch all settings by group and cache the result
  def self.by_group(group)
    Rails.cache.fetch("#{PREFIX_SETTINGS}#{group}", expires_in: 10.minutes) do
      where(group: group).pluck(:key, :value).to_h.transform_keys(&:to_sym)
    end
  end
end
