REDIS_CONFIG = RedisConfig.instance.read
def get_redis instance = :default
  load_instance = REDIS_CONFIG.has_key?(instance.to_sym) ? instance.to_sym : "default"
  Redis.new REDIS_CONFIG[load_instance.to_sym].symbolize_keys
end
