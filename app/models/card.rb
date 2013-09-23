class Card < ActiveRecord::Base
	belongs_to :faction
	belongs_to :type
	belongs_to :scout, :class_name => 'Effect', :foreign_key => 'scout_id'
  	belongs_to :flip, :class_name => 'Effect', :foreign_key => 'flip_id'
  	belongs_to :deploy, :class_name => 'Effect', :foreign_key => 'deploy_id'
  	belongs_to :passive, :class_name => 'Effect', :foreign_key => 'passive_id'

	validates_presence_of :name
  	attr_accessible :name, :atk, :def, :energy, :upkeep, :gank, :created_at, :updated_at, :type_id, :faction_id, :publish, :avatar, :scout_id, :flip_id, :deploy_id, :passive_id
  	mount_uploader :avatar, AvatarUploader
end
