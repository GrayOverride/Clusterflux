class Effect < ActiveRecord::Base
	has_many :scout, :class_name => 'Card', :foreign_key => 'scout_id'
	has_many :flip, :class_name => 'Card', :foreign_key => 'flip_id'
	has_many :deploy, :class_name => 'Card', :foreign_key => 'deploy_id'
	has_many :passive, :class_name => 'Card', :foreign_key => 'passive_id'

	attr_accessible :amount, :effect, :name, :etype
end
