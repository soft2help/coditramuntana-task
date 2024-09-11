class User < ApplicationRecord
  # Use Rails's built-in timestamp support
  has_secure_password  # Adds `password_digest` field and methods like `authenticate`

  # Associations
  has_many :api_keys, as: :bearer

  # Validations
  validate :api_keys_count_within_limit

  validates :email, presence: true, uniqueness: true, format: {with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address"}

  # Roles stored as a serialized array
  serialize :roles, type: Array, coder: YAML

  # Custom validation for strong password
  validate :password_strength

  # Password assignment (handled by `has_secure_password`)
  # def password=(new_password)
  #   super # has_secure_password handles this internally
  # end

  # Authentication (handled by `has_secure_password`)
  # def authenticate(password)
  #   super # has_secure_password handles this internally
  # end

  private

  def password_strength
    return if password.blank? # Skip validation if password is not being updated

    unless password.match?(/\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}\z/)
      errors.add(:password, "must include at least 1 uppercase letter, 1 lowercase letter, 1 digit, and 1 special character (@$!%*?&), and be at least 8 characters long.")
    end
  end

  # Custom validation to check API keys count
  def api_keys_count_within_limit
    if api_keys.count > 4
      errors.add(:api_keys, "exceed the allowed limit of 4")
    end
  end
end
