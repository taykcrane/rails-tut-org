class User < ActiveRecord::Base
	before_save :downcase_email
	before_create :create_activation_digest

	validates :name, presence: true, length: { maximum: 50 }
	validates :email, presence: true, length: { maximum: 255 },
					format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
					uniqueness: { case_sensitive: false }
	has_secure_password
	validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

	#this is the token stored in the user's cookie. paired with the remember_digest stored in the DB
	attr_accessor :remember_token, :activation_token

	#returns the hash digest of a given string (for test database purposes)
	def User.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                              		  BCrypt::Engine.cost
    	BCrypt::Password.create(string, cost: cost)
	end

	#returns a random token for remembering users
	def User.new_token
		SecureRandom.urlsafe_base64
	end

	#when called, stores the digest of :remember_token into the database
	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
	end

	#returns true if the given raw token matches the digest in the database
	def authenticated?(attribute, token)
		digest = send("#{attribute}_digest")
		return false if digest.nil?
		BCrypt::Password.new(digest).is_password?(token)
	end

	def forget
		update_attribute(:remember_digest, nil)
	end

	#activates an account
	def activate
		update_attribute(:activated, true)
		update_attribute(:activated_at, Time.zone.now)
	end

	#sends activation email
	def send_activation_email
		UserMailer.account_activation(self).deliver_now
	end

	private
	def downcase_email
		self.email = email.downcase
	end

	def create_activation_digest
		self.activation_token = User.new_token
		self.activation_digest = User.digest(activation_token)
	end
end
