module Game::TurnsHelper
	def draw_card(server)
		#if no cards remain in deck, return nil, otherwise return the card and it's attributes
		if server.state[session[:player]]["deck"].empty? || server.state[session[:player]]["hand"].length == 12
			card = nil 
			return false
		else
			#pop the card from the deck
			card = server.state[session[:player]]["deck"].pop

			card["state"]["position"] = "hand"

			#add the card to the hand
			server.state[session[:player]]["hand"].push(card)
			
			server.update_attributes(:key => server.key, :state => server.state)

			PrivatePub.publish_to("/board/" + session[:key] + "/" + session[:player], :draw => true, :card => card)
			PrivatePub.publish_to("/board/" + session[:key] + "/opponent/" + fetch_opponent, :draw => true, :card => card["alias"])
			
			return true
		end
	end

	def draw_hq(server, player)
		#pop the hq from the deck
		card = server.state[player]["deck"].shift

		card["state"]["position"] = "deployed"
		card["state"]["powered"] = true

		#add hq to deployed directly
		server.state[player]["deployed"].push(card)

		server.state[player]["energy_pool"] = card["energy"]
		server.state[player]["upkeep"] = 0

		if player == "player_1"
			opponent = "player_2"
		else
			opponent = "player_1"
		end

		PrivatePub.publish_to("/board/" + session[:key] + "/" + player, :hq => card, :energy => card["energy"])
		PrivatePub.publish_to("/board/" + session[:key] + "/opponent/" + opponent, :hq => card)

		return server.state
	end

	#if new energy is added see about powering up cards
	def power_up(server, player)

		#in case opponent's energy is lower than upkeep, power some cards down
		upkeep = server.state[player]["upkeep"].to_i
		energy = server.state[player]["energy_pool"].to_i

		if upkeep < energy
			result = Hash.new
			result[player] = Hash.new		
			result[player]["powered_up"] = Array.new

			server.state[player]["placed"].each_with_index do |c, index|
				unless c["state"]["position"] == "graveyard"
					if c["state"]["powered"] == false && ((c["upkeep"].to_i + upkeep) <= energy)
					  	#add the upkeep used by card if there's room and power it up
					  	upkeep += c["upkeep"].to_i
						server.state[player]["upkeep"] += c["upkeep"].to_i
						c["state"]["powered"] = true

						result[player]["powered_up"].push(c["alias"])
					end
				end
			end

			if !result[player]["powered_up"].nil? && !server.nil?
				result[player]["server"] = server

				return result
			else
				return false
			end
		else
			return false
		end
	end

	private
	def auth_turn
		if session[:turn] != true
		    PrivatePub.publish_to("/board/" + session[:key] + "/" + session[:player], :notice => true)

			render :nothing => true
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
