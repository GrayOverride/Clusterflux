module Game::BoardHelper
	#sets player as ready and starts game if both are ready
	def set_ready
		@server = Game::Server.where("key = ?", params[:key]).first

		@server.state[session[:player]]["ready"] = true

		op = fetch_opponent

		if !@server.state[op].nil? && @server.state[op]["ready"] == true
			starter = "player_" + rand(1..2).to_s

			if session[:player] == starter
				session[:turn] = true
			else
				session[:turn] = false
			end

			@server.state["begin"] = {"ready" => true, "starter" => starter}
		else
			starter = false
			@server.state["begin"] = {"ready" => false}
		end

		@server.update_attributes(:key => @server.key, :state => @server.state)
		
		session[:ready] = true
		username = fetch_username

		PrivatePub.publish_to("/board/" + session[:key], :ready => true, :username => username, :starter => starter)
	end

	#handles chat messages
	def chat_message
		sender = fetch_username
	  	send_message(fetch_username, params["content"])
	end

	#if user leaves server, add it to server-browser again, remove it or transfer ownership
	def disconnect_player
		@server = Game::Server.where("key = ?", params[:key]).first

		#if the server becomes empty or a player leaves midgame, remove it from db otherwise republish it to server browser
		if((@server.ready == false) || (@server.state["player_1"]["ready"] == true && @server.state["player_2"]["ready"] == true))
			send_message("System", fetch_username + " disconnected")

			PrivatePub.publish_to("/servers/remove", :key => @server.key)
			@server.destroy
		else
			@server.publish = true
			@server.ready = false
			@server.state.delete(session[:player])

			#fails silently, if db is not updated, the server will not appear in server-browser
			if @server.update_attributes(:publish => @server.publish, :ready => @server.ready)
				
			    if @server.user_id.nil?
			      @creator = @server.username
			    else
			      @creator = @server.user.username
			    end

			    send_message("System", fetch_username + " disconnected")

				@url = game_join_path(@server.key)

				PrivatePub.publish_to("/servers/new", :server => @server, :creator => @creator, :url => @url)
			end
		end

		session[:turn] = false
		session[:key] = nil
		session[:player] = nil
		session[:phase] = nil

		return true
	end

	#returns the username of player, either registered or not
	private
	def fetch_username
		if session[:user_id]
			username = @current_user.username
		else
			username = session[:username]
		end
	end

	#fetches the internally assigned opponent identifier
	private
	def fetch_opponent
		if session[:player] == "player_1"
			op = "player_2"
		else
			op = "player_1"
		end

		return op
	end
end
