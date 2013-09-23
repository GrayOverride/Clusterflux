class HomeController < ApplicationController
  def index
    @admin_updates = Admin::Update.order("created_at DESC").limit(1)
    @current_user = current_user
  end

  def tutorial
  	@current_user = current_user
  end
end
