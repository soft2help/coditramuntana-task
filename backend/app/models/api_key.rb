class ApiKey < ApplicationRecord
  serialize :access_control_rules, type: Hash, coder: YAML
  serialize :permissions, type: Hash, coder: YAML
  # Constants
  HMAC_SECRET_KEY = Rails.application.config.api_key_hmac_secret_key
  TOKEN_NAMESPACE = "disc"

  # Associations
  belongs_to :bearer, polymorphic: true

  # Virtual Attributes (not stored in the database)
  attr_accessor :raw_token, :random_token_prefix

  # Validations
  validates_uniqueness_of :encrypted_random_token_prefix, scope: [:bearer_id, :bearer_type]

  # Callbacks
  before_validation :set_common_token_prefix, on: :create
  before_validation :generate_random_token_prefix, on: :create
  before_validation :generate_raw_token, on: :create
  before_validation :generate_token_digest, on: :create

  # Class Methods

  def self.check(raw_token)
    where(revoked_at: nil)
      .where("expires_in IS NULL OR expires_in > ?", Time.now)
      .find_by_token(raw_token)
  end

  def self.find_by_token(token)
    where(token_digest: generate_digest(token)).first
  end

  def self.generate_digest(token)
    OpenSSL::HMAC.hexdigest("SHA256", HMAC_SECRET_KEY, token)
  end

  # Instance Methods

  def token_prefix
    "#{common_token_prefix}#{random_token_prefix}"
  end

  def token_mask(length = 30, mask_caracter = "•")
    set_common_token_prefix
    "#{common_token_prefix}#{mask_caracter * length}"
  end

  private

  # Generates common token subprefix based on the bearer type
  def common_token_subprefix
    bearer_type.underscore
  end

  # Sets common token prefix before creating a new record
  def set_common_token_prefix
    self.common_token_prefix = "#{TOKEN_NAMESPACE}_#{common_token_subprefix}_"
  end

  # Generates a random token prefix and encrypts it
  def generate_random_token_prefix
    self.random_token_prefix = SecureRandom.base58(32)
    encrypt_random_token_prefix
  end

  # Generates the raw token by combining prefixes and a random string
  def generate_raw_token
    self.raw_token = [common_token_prefix, random_token_prefix, SecureRandom.base58(24)].join("")
  end

  # Generates a digest of the raw token for secure storage
  def generate_token_digest
    self.token_digest = self.class.generate_digest(raw_token)
  end

  # Encrypts the random token prefix using AES-256-GCM
  def encrypt_random_token_prefix
    if random_token_prefix.present?
      encryptor = ActiveSupport::MessageEncryptor.new([HMAC_SECRET_KEY].pack("H*"), cipher: "aes-256-gcm")
      self.encrypted_random_token_prefix = encryptor.encrypt_and_sign(random_token_prefix)
    end
  end

  # Decrypts the random token prefix if needed
  def decrypt_random_token_prefix
    if encrypted_random_token_prefix.present?
      encryptor = ActiveSupport::MessageEncryptor.new([Rails.application.credentials.encryption_key].pack("H*"), cipher: "aes-256-gcm")
      self.random_token_prefix = encryptor.decrypt_and_verify(encrypted_random_token_prefix)
    end
  end
end
