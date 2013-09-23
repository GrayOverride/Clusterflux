class Game::Server < ActiveRecord::Base
	belongs_to :user, :class_name => "User::User"
	serialize :state, Hash
  	attr_accessible :name, :publish, :key, :user_id, :username, :ready, :state

  	validates_presence_of :name, :publish, :key, :state, :on => :create
  	validates_presence_of :key, :on => :update
end
