class User::User < ActiveRecord::Base
	has_one :server, :class_name => "Game::Server"
	has_many :decks, :dependent => :destroy
	attr_accessible :email, :username, :password 

	attr_accessor :password
	before_save :encrypt_password

	validates_presence_of :email
	validates_presence_of :username
	validates_presence_of :password, :on => :create

	validates_uniqueness_of :email
	validates_uniqueness_of :username

	validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
	validates_length_of :password, :minimum => 6, :allow_blank => true, :too_short =>" is to short"

	def encrypt_password
		if password.present?
			self.pw_salt = BCrypt::Engine.generate_salt
			self.pw_hash = BCrypt::Engine.hash_secret(password, pw_salt)
		end
	end

	def self.authenticate(creds, password)
		user = where("username = ? OR email = ?", creds, creds).first

		if user && user.pw_hash == BCrypt::Engine.hash_secret(password, user.pw_salt)
			user
		else
			nil
		end
	end
end
