class Game::GamesController < ActionController::Base
	protect_from_forgery
	before_filter :is_logged_in?
	helper_method :current_user

	private
	def current_user
		@current_user ||= User::User.find(session[:user_id]) if session[:user_id]
	end

	private
	def is_logged_in?
		if(current_user.nil? && session[:username].nil?)
		  session[:user_id] = nil
		  session[:username] = "Random#" + rand(1000..9999).to_s
		end
	end

	def checkPlayer
		if params["player"] 
			if session[:player] != params["player"]
				params["player"] = session[:player]
			end
		end
	end

	#publish message to channel
	def send_message(sender, content)
		message = Hash.new
	    message["content"] = content
	    message["sender"] = sender
	    PrivatePub.publish_to "/board/" + session[:key], :message => message
	end
end
