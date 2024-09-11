class RedisConfig
  include Singleton

  # Your methods and logic here

  def read
    @config ||= YAML.load_file("#{Rails.root}/config/redis.yml")[Rails.env].symbolize_keys
  end
end
