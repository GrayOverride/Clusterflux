class User::Deck < ActiveRecord::Base
	serialize :cards, Array
	belongs_to :user
  	attr_accessible :name, :hq, :created_at, :updated_at, :cards, :user_id
  	attr_accessor :validate_user

  	validates_presence_of :user_id, :on => :create, :if => :should_validate_user?
  	validates_presence_of :name, :hq, :cards

  	def should_validate_user?
  		validate_user
  	end
end
