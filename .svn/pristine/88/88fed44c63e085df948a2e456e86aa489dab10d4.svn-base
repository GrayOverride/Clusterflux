class User::MainController < ActionController::Base
	protect_from_forgery
	layout "application"
	before_filter :authenticate
	helper_method :current_user

	private
	def current_user
		@current_user ||= User::User.find(session[:user_id]) if session[:user_id]
	end

	private
	def authenticate
		if(current_user.nil?)
		  redirect_to root_url
		end
	end
end
