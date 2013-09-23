module Game::AttackHelper

	def attack_queue(attack)
		combat = false #if remains false, combat should not have carried out, and false will be published to attacker
		atk_id = nil
		def_id = nil
		res_id = nil

		unit = nil
		target = nil
		resource = nil
		tmp = nil

		result = Hash.new
		result[session[:player]] = Hash.new
		result[session[:player]]["destroyed"] = Array.new
		result[session[:player]]["scouted"] = Array.new
		result[fetch_opponent] = Hash.new
		result[fetch_opponent]["destroyed"] = Array.new
		result[fetch_opponent]["powered_down"] = Array.new

		server = Game::Server.where("key = ?", params[:key]).first

		attack.each_with_index do |a, i|
			unit = nil
			target = nil
			resource = nil
			
			if !a["unit"].nil?
				#get the attacking card
				server.state[session[:player]]["placed"].each_with_index do |c, index|
					if c["alias"].to_i == a["unit"].to_i
						unit = server.state[session[:player]]["placed"].fetch(index)
						atk_id = index
					end
				end

				if !a["target"].nil?
					#get the defending card
					server.state[fetch_opponent]["placed"].each_with_index do |c, index|
						if c["alias"].to_i == a["target"].to_i
							target = server.state[fetch_opponent]["placed"].fetch(index)
							def_id = index
						end
					end
				end

				if !a["resource"].nil?
					#get the defending resource card
					server.state[fetch_opponent]["deployed"].each_with_index do |c, index|
						if c["alias"].to_i == a["resource"].to_i
							resource = server.state[fetch_opponent]["deployed"].fetch(index)
							res_id = index
						end
					end
				end

				coward = false
				defector = false
				immortal = false

				if !target.blank?
					if !target["scout"].nil? && !target["scout"]["effect"].nil?
						if target["state"]["flipped"] == false && target["scout"]["effect"] == "coward"
							coward = true

							#the defending card was scouted
							target["state"]["flipped"] = true
							result[session[:player]]["scouted"].push(target)

							combat = true
						elsif target["state"]["flipped"] == false && target["scout"]["effect"] == "defector"
							defector = true
							unit["atk"] += target["atk"]

							#the defending card was scouted
							target["state"]["flipped"] = true
							result[session[:player]]["scouted"].push(target)

							combat = true
						end
					end
				end

				if !unit.blank? && !atk_id.nil? && !target.blank? && (!coward || a["resource"].nil?) && (!defector || a["resource"].nil?) && unit["state"]["flipped"] == true
					t_def = target["def"].to_i

					#if target is not flipped there might be a scout effect, this handles some of them
					if target["state"]["flipped"] == false && !target["scout"].nil? && !target["scout"]["effect"].nil?
						case target["scout"]["effect"]
							when "draw"
								server.state = effect_draw(server, fetch_opponent, session[:player], target["scout"]["amount"])
							when "def"
								if target["scout"]["amount"] == 100
									t_def = target["def"].to_i * 2
								elsif target["scout"]["amount"] == 50
									t_def = target["def"].to_i / 2
								else
									server.state[fetch_opponent]["placed"][def_id] = update_def(target, "scout")
									t_def = target["def"].to_i
								end
							when "atk"
								if target["scout"]["amount"] == 100
									target["atk"] = target["atk"].to_i * 2
								elsif target["scout"]["amount"] == 50
									target["atk"] = target["atk"].to_i / 2
								else
									server.state[fetch_opponent]["placed"][def_id] = update_atk(target, "scout")
								end
							when "atk_def"
								server.state[fetch_opponent]["placed"][def_id] = update_atk(target, "scout")
								server.state[fetch_opponent]["placed"][def_id] = update_def(target, "scout")
							when "disable"
								server.state[session[:player]]["placed"][atk_id] = reverse_flip(unit, session[:player], fetch_opponent)
								combat = true
							when "return"
								server.state = return_cards(server, session[:player], fetch_opponent, target["scout"]["amount"])
						end

						#if target is immortal combat will take place, but nothing will change except target flip state
						if !target["scout"].nil? && !target["scout"]["effect"].nil? && target["scout"]["effect"] == "immortal" && target["state"]["flipped"] == false && unit["state"]["powered"] == true && unit["state"]["flipped"] == true
							combat = true
							immortal = true
						end

						#the defending card was scouted
						target["state"]["flipped"] = true
						result[session[:player]]["scouted"].push(target)
					end

					if versus(unit["atk"], t_def) == 1 && unit["state"]["powered"] == true && unit["state"]["flipped"] == true && !immortal
						remains = unit["atk"]

						tmp = server.state[fetch_opponent]["placed"].delete_at(def_id)
						tmp["state"]["position"] = "graveyard"

						#remove the upkeep of destroyed card
						server.state[fetch_opponent]["upkeep"] -= tmp["upkeep"].to_i

						server.state[fetch_opponent]["graveyard"].push(target)

						combat = true #combat was carried out and changes were made

						#changes to be published
						result[fetch_opponent]["upkeep"] = server.state[fetch_opponent]["upkeep"]
						result[fetch_opponent]["destroyed"].push(tmp["alias"])

						#remaining damage from first attack, to be tried against the resource if targeted
						remains -= target["def"].to_i

						#if target is a defector, add it's attack to the attacking unit
						if !target["scout"].nil? && !target["scout"]["effect"].nil? && target["scout"]["effect"] == "defector"
							remains += target["atk"]
						end

						if !resource.blank?
							if versus(remains, resource["def"]) == 1
								tmp = server.state[fetch_opponent]["deployed"].delete_at(res_id)
								tmp["state"]["position"] = "graveyard"

								#remove the energy given by resource
								server.state[fetch_opponent]["energy_pool"] -= tmp["energy"].to_i

								server.state[fetch_opponent]["graveyard"].push(resource)

								#changes to be published
								result[fetch_opponent]["destroyed"].push(tmp["alias"])

								combat = true #combat was carried out and changes were made
							elsif versus(remains, resource["def"]) == 3
								tmp = server.state[session[:player]]["placed"].delete_at(atk_id)
								tmp["state"]["position"] = "graveyard"

								#remove the upkeep of destroyed card
								server.state[session[:player]]["upkeep"] -= tmp["upkeep"].to_i

								server.state[session[:player]]["graveyard"].push(unit)

								#changes to be published
								result[session[:player]]["destroyed"].push(tmp["alias"])

								combat = true #combat was carried out and changes were made
							end
						end
					elsif versus(unit["atk"], t_def) == 3 && unit["state"]["powered"] == true && unit["state"]["flipped"] == true
						#if target is unpowered it cannot destroy cards
						unless target["state"]["powered"] == false
							tmp = server.state[session[:player]]["placed"].delete_at(atk_id)
							tmp["state"]["position"] = "graveyard"

							#remove the upkeep of destroyed card
							server.state[session[:player]]["upkeep"] -= tmp["upkeep"].to_i

							server.state[session[:player]]["graveyard"].push(unit)

							#changes to be published
							result[session[:player]]["destroyed"].push(tmp["alias"])

							combat = true #combat was carried out and changes were made
						end

						#if target has hide effect, it will not be flipped by scout
						if !target["scout"].nil? && !target["scout"]["effect"].nil? && target["scout"]["effect"] == "hide"
							target["state"]["flipped"] = false
							result[session[:player]]["scouted"].delete(target)
						end

					elsif versus(unit["atk"], t_def) == 2 && unit["state"]["powered"] == true && unit["state"]["flipped"] == true
						#if target has hide effect, it will not be flipped by scout
						if !target["scout"].nil? && !target["scout"]["effect"].nil? && target["scout"]["effect"] == "hide"
							target["state"]["flipped"] = false
							result[session[:player]]["scouted"].delete(target)
						end

						combat = true #combat was carried out and changes were made
					end
				elsif !unit.blank? && !resource.blank? && unit["state"]["powered"] == true && unit["state"]["flipped"] == true && !immortal
					if versus(unit["atk"], resource["def"]) == 1
						tmp = server.state[fetch_opponent]["deployed"].delete_at(res_id)
						tmp["state"]["position"] = "graveyard"

						#remove the energy given by resource
						server.state[fetch_opponent]["energy_pool"] -= tmp["energy"].to_i

						server.state[fetch_opponent]["graveyard"].push(resource)

						#changes to be published
						result[fetch_opponent]["destroyed"].push(tmp["alias"])

						combat = true #combat was carried out and changes were made
					elsif versus(unit["atk"], resource["def"]) == 3
						tmp = server.state[session[:player]]["placed"].delete_at(atk_id)
						tmp["state"]["position"] = "graveyard"

						#remove the upkeep of destroyed card
						server.state[session[:player]]["upkeep"] -= tmp["upkeep"].to_i

						server.state[session[:player]]["graveyard"].push(unit)

						#changes to be published
						result[session[:player]]["destroyed"].push(tmp["alias"])

						combat = true #combat was carried out and changes were made
					end
				end
			end

			atk_id = nil
			def_id = nil
			res_id = nil
		end

		#in case opponent's energy is lower than upkeep, power some cards down
		upkeep = server.state[fetch_opponent]["upkeep"].to_i
		energy = server.state[fetch_opponent]["energy_pool"].to_i

		pd = Array.new #do not power down the same card twice, store pd cards here

		if upkeep > energy
			powered_down = true

			until upkeep < energy || upkeep == 0
			  	#tmp = server.state[fetch_opponent]["placed"].sample
			  	tmp = server.state[fetch_opponent]["placed"].select{|c| c["state"]["powered"] == true}.max_by{|c| c["upkeep"] }
			  	
			  	if !tmp.nil? && tmp["state"]["powered"] == true && tmp["upkeep"].to_i != 0 && !pd.include?(tmp["alias"])
				  	#remove the upkeep used by card
					server.state[fetch_opponent]["upkeep"] -= tmp["upkeep"].to_i

					tmp["state"]["powered"] = false

					upkeep -= tmp["upkeep"].to_i

					pd.push(tmp["alias"])
					result[fetch_opponent]["powered_down"].push(tmp["alias"])
				end
			end
		else
			powered_down = false
		end

		#player can't have negative upkeep
		if upkeep < 0
			upkeep = 0
		end

		#add new values for upkeep/energy to be published
		result[fetch_opponent]["upkeep"] = upkeep.to_i
		result[fetch_opponent]["energy"] = energy.to_i

		#save new values to db
		server.state[fetch_opponent]["upkeep"] = upkeep.to_i
		server.state[fetch_opponent]["energy_pool"] = energy.to_i

		result[session[:player]]["upkeep"] = server.state[session[:player]]["upkeep"].to_i

		#check if attacker have cards to be powered up
		atk_power_up = power_up(server, session[:player])

		if atk_power_up
			server = atk_power_up[session[:player]]["server"]
			atk_powered_up = atk_power_up[session[:player]]["powered_up"]
		else
			atk_powered_up = false
		end

		#check if defender have cards to be powered up
		def_power_up = power_up(server, fetch_opponent)

		if def_power_up
			server = def_power_up[fetch_opponent]["server"]
			def_powered_up = def_power_up[fetch_opponent]["powered_up"]
		else
			def_powered_up = false
		end

		#commit changes to db
		server.update_attributes(:key => server.key, :state => server.state)

		if energy < 1
			game = true
		else
			game = false
		end

		if combat == true
			PrivatePub.publish_to("/board/" + session[:key] + "/" + session[:player], :combat => true, :result => result, :game => game, :player_power_up => atk_powered_up, :opponent_power_up => def_powered_up)
			PrivatePub.publish_to("/board/" + session[:key] + "/opponent/" + fetch_opponent, :combat => true, :result => result, :game => game, :player_power_up => def_powered_up, :opponent_power_up => atk_powered_up, :powered_down => powered_down)
		else
			PrivatePub.publish_to("/board/" + session[:key] + "/" + session[:player], :combat => false)
		end
	end

	def versus(a, t)
		result = 0

		if a.to_i > t.to_i
			result = 1
		elsif a.to_i == t.to_i
			result = 2
		else
			result = 3
		end

		return result
	end
end