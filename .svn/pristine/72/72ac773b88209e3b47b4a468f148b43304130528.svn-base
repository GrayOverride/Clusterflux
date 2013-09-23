class Admin::MainController < ActionController::Base
	protect_from_forgery
	layout "admin"
	before_filter :authenticate
	helper_method :current_user

	private
	def current_user
		@current_user ||= Admin::User.find(session[:admin_id]) if session[:admin_id]
	end

	private
	def authenticate
		if(current_user.nil?)
		  redirect_to admin_log_in_path
		end
	end
end
