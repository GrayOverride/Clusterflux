class Game::TurnsController < Game::GamesController
	before_filter :auth_turn, :only => [:deploy, :flip, :place, :attack, :end_turn]
	
	#includes helper methods
  	include Game::TurnsHelper
  	include Game::EffectHelper
  	include Game::AttackHelper

  	def start_turn
  		session[:turn] = true #used in before_filter
  		render :nothing => true
  	end

	#validates the action of drawing a card, and updates server state
	def draw
		#this is the first step of a turn, this means it is this player's turn

		phase = Array.new
		session[:phase] = phase #in which phase is the player
		session[:phase].push("draw")

		server = Game::Server.where("key = ?", params[:key]).first

		if params[:draw] == "hq"
			server.state = draw_hq(server, session[:player])
			server.state = draw_hq(server, fetch_opponent)

			server.update_attributes(:key => server.key, :state => server.state)
		elsif params[:draw] == "initial"
			server.state = effect_draw(server, session[:player], fetch_opponent, 7)

			server.state = effect_draw(server, fetch_opponent, session[:player], 7)

			server.update_attributes(:key => server.key, :state => server.state)
		else
			if !draw_card(server)
				PrivatePub.publish_to("/board/" + session[:key] + "/" + session[:player], :draw => true, :card => nil)
				PrivatePub.publish_to("/board/" + session[:key] + "/opponent/" + fetch_opponent, :draw => true, :card => nil)
			end
		end
		
		render :nothing => true
	end

	#validates the action of deploying a card, and updates server state
	def deploy
		unless session[:phase].include?("place") || session[:phase].include?("attack") || session[:phase].include?("flip") || session[:phase].include?("deploy")

			server = Game::Server.where("key = ?", params[:key]).first

			energy = server.state[session[:player]]["energy_pool"]
			upkeep = server.state[session[:player]]["upkeep"]

			card = Hash.new
			
			#get the card from placed
			server.state[session[:player]]["placed"].each_with_index do |c, i|
				if c["alias"].to_i == params[:card].to_i
					card = server.state[session[:player]]["placed"].delete_at(i)
				end
			end

			allowed = true
			powered_up = false

			if !card.empty? && card["state"]["flipped"] == true && card["state"]["powered"] == true
				if card["energy"] > 0
					card["state"]["position"] = "deployed"

					#add card to deployed
					server.state[session[:player]]["deployed"].push(card)

					#add the energy the card gives
					server.state[session[:player]]["energy_pool"] += card["energy"].to_i

					#remove the energy the card uses
					server.state[session[:player]]["upkeep"] -= card["upkeep"].to_i

					result = power_up(server, session[:player])

					if result
						server = result[session[:player]]["server"]
						powered_up = result[session[:player]]["powered_up"]
					else
						powered_up = false
					end

					energy = server.state[session[:player]]["energy_pool"].to_i
					upkeep = server.state[session[:player]]["upkeep"].to_i

					if upkeep < 0
						upkeep = 0
						server.state[session[:player]]["upkeep"] = 0
					end

					if server.update_attributes(:key => server.key, :state => server.state)
						session[:phase].push("deploy")
						allowed = true
					else
						allowed = false
					end
				else
					allowed = false
				end
			else
				allowed = false
			end
		
			if allowed
				PrivatePub.publish_to("/board/" + session[:key] + "/" + session[:player], :deployed => true, :deploy_card => card["alias"], :pos => params[:pos], :energy => energy, :upkeep => upkeep, :player_power_up => powered_up)
				PrivatePub.publish_to("/board/" + session[:key] + "/opponent/" + fetch_opponent, :deployed => true, :pos => params[:pos], :deploy_card => card["alias"], :opponent_power_up => powered_up)
			else
				PrivatePub.publish_to("/board/" + session[:key] + "/" + session[:player], :deployed => false)
			end
		end

		render :nothing => true
	end

	#validates the action of flipping a card, and updates server state
	def flip
		unless session[:phase].include?("place") || session[:phase].include?("attack")

			server = Game::Server.where("key = ?", params[:key]).first

			card = Hash.new
			cid = nil

			#get the card from placed
			server.state[session[:player]]["placed"].each_with_index do |c, i|
				if c["alias"].to_i == params[:card].to_i
					card = server.state[session[:player]]["placed"].fetch(i)
					cid = i
				end
			end

			if !card.nil? && card["state"]["flipped"] == false && card["state"]["powered"] == true
				session[:phase].push("flip")

				#if card is not flipped there might be a flip effect, this handles some of them
				if !card["flip"].nil? && !card["flip"]["effect"].nil?
					case card["flip"]["effect"]
						when "draw"
							server.state = effect_draw(server, session[:player], fetch_opponent, card["flip"]["amount"])
						when "def"
							if card["flip"]["amount"] == 100
								card["def"] = card["def"].to_i * 2
							elsif card["flip"]["amount"] == 50
								card["def"] = card["def"].to_i / 2
							else
								server.state[session[:player]]["placed"][cid] = update_def(card, "flip")
							end
						when "atk"
							if card["flip"]["amount"] == 100
								card["atk"] = card["atk"].to_i * 2
							elsif card["flip"]["amount"] == 50
								card["atk"] = card["atk"].to_i / 2
							else
								server.state[session[:player]]["placed"][cid] = update_atk(card, "flip")
							end
						when "atk_def"
							server.state[session[:player]]["placed"][cid] = update_atk(card, "flip")
							server.state[session[:player]]["placed"][cid] = update_def(card, "flip")
						when "discard"
							server.state = discard_cards(server, session[:player], fetch_opponent, card["flip"]["amount"])
						when "return"
							server.state = return_cards(server, session[:player], fetch_opponent, card["flip"]["amount"])
					end
				end

				card["state"]["flipped"] = true

				server.update_attributes(:key => server.key, :state => server.state)

				PrivatePub.publish_to("/board/" + session[:key] + "/" + session[:player], :flipped => true, :card => card)
				PrivatePub.publish_to("/board/" + session[:key] + "/opponent/" + fetch_opponent, :flipped => true, :card => card)
			end
		end

		render :nothing => true
	end

	#validates the action of placing a card, and updates server state
	def place
		unless session[:phase].include?("attack")
			server = Game::Server.where("key = ?", params[:key]).first

			upkeep = server.state[session[:player]]["upkeep"].to_i
			energy = server.state[session[:player]]["energy_pool"].to_i

			card = Hash.new

			#get the card from hand
			server.state[session[:player]]["hand"].each_with_index do |c, i|
				if c["alias"].to_i == params[:card].to_i
					card = server.state[session[:player]]["hand"].delete_at(i)
				end
			end

			unless card.empty? || card.nil?
				session[:phase].push("place")

				if (upkeep + card["upkeep"].to_i) <= energy
					card["state"]["position"] = "placed"
					card["state"]["powered"] = true

					if params[:flip] == "up"
						flip = true
						card["state"]["flipped"] = true
					else
						flip = false
					end

					#add card to placed
					server.state[session[:player]]["placed"].push(card)

					#increase upkeep
					server.state[session[:player]]["upkeep"] += card["upkeep"].to_i

					upkeep = server.state[session[:player]]["upkeep"]
					energy = server.state[session[:player]]["energy_pool"]

					if server.update_attributes(:key => server.key, :state => server.state)
						allowed = true
					else
						allowed = false
					end
				else
					allowed = false
				end
			else
				allowed = false
			end

			if allowed
				PrivatePub.publish_to("/board/" + session[:key] + "/" + session[:player], :placed => true, :place_card => card["alias"], :pos => params[:pos], :upkeep => upkeep, :energy => energy, :flip => flip)
				if flip
					PrivatePub.publish_to("/board/" + session[:key] + "/opponent/" + fetch_opponent, :placed => true, :pos => params[:pos], :place_card => card, :flip => flip)
				else
					PrivatePub.publish_to("/board/" + session[:key] + "/opponent/" + fetch_opponent, :placed => true, :pos => params[:pos], :place_card => card["alias"], :flip => flip)
				end
			else
				PrivatePub.publish_to("/board/" + session[:key] + "/" + session[:player], :placed => false)
			end
		end

		render :nothing => true
	end

	#validates the action of attacking an opponent's card, and updates server state
	def attack
		unless session[:phase].include?("attack")
			if params[:attack]
				attack = Hash.new
				attack = JSON.parse(params[:attack])
				
				attack_queue(attack)

				session[:phase].push("attack")
			end
		end

		render :nothing => true
	end

	#validates the action of edning the turn, and updates server state
	def end_turn
		unless session[:phase].nil?
			session[:phase].clear
		end

		session[:phase] = nil
		session[:turn] = false

		PrivatePub.publish_to("/board/" + session[:key] + "/" + fetch_opponent, :start_turn => true)
		render :nothing => true
	end
end
