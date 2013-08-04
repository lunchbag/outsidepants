class User
  include Mongoid::Document
  attr_accessible :email, :password, :password_confirmation
  attr_accessor :password

  field :email, type: String
  field :password_hash, type: String
  field :password_salt, type: String
  field :admin, type: Boolean

  validates_presence_of :email
  validates_confirmation_of :password

  before_save :email_to_lowercase
  before_save :encrypt_password

  def self.authenticate(email, password)
  	user = User.where(email: email).first
  	if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
  		user
  	else
  		nil
  	end
  end

  def email_to_lowercase
  	email.downcase!
  end

  def encrypt_password
  	if password.present?
  		self.password_salt = BCrypt::Engine.generate_salt
  		self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
  	end
  end

  def toggle!(field)
	  send "#{field}=", !self.send("#{field}?")
	  save :validation => false
	end
end
