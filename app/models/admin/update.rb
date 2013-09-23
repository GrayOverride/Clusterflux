class Admin::Update < ActiveRecord::Base
  attr_accessible :desc, :title
end
