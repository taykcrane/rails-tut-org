class User < ActiveRecord::Base
	before_save { email.downcase! }
	validates :name, presence: true, length: { maximum: 50 }
	validates :email, presence: true, length: { maximum: 255 },
					format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
					uniqueness: { case_sensitive: false }
	has_secure_password
	validates :password, presence: true, length: { minimum: 6 }

	#this is the token stored in the user's cookie. paired with the remember_digest stored in the DB
	attr_accessor :remember_token

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
	def authenticated?(remember_token)
		return false if remember_digest.nil?
		BCrypt::Password.new(remember_digest).is_password?(remember_token)
	end

	def forget
		update_attribute(:remember_digest, nil)
	end
end
