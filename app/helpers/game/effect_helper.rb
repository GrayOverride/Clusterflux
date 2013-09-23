module Game::EffectHelper

	#effect making one of the players draw a card
	def effect_draw(server, player, opponent, amount)

		deck = Array.new
		hand = Array.new

		#make copies for editing
		deck = server.state[player]["deck"]
		hand = server.state[player]["hand"]

		i = 0 #iterator

		#if no cards remain in deck, return nil, otherwise return the card and it's attributes
		until i == amount || deck.empty? || hand.length == 12
			#pop the card from the deck
			card = deck.pop

			card["state"]["position"] = "hand"

			#add the card to the hand
			hand.push(card)

			i += 1 #increment iterator

			PrivatePub.publish_to("/board/" + session[:key] + "/" + player, :draw => true, :card => card)
			PrivatePub.publish_to("/board/" + session[:key] + "/opponent/" + opponent, :draw => true, :card => card["alias"])
		end

		server.state[player]["hand"] = hand
		server.state[player]["deck"] = deck
		
		return server.state
	end

	def update_def(card, type)
		unless card[type]["amount"].to_i == 50 || card[type]["amount"].to_i == 100
			card["def"] += card[type]["amount"].to_i
			if card["def"].to_i < 0
				card["def"] = 0
			end
		end

		return card
	end

	def update_atk(card, type)
		unless card[type]["amount"].to_i == 50 || card[type]["amount"].to_i == 100
			card["atk"] += card[type]["amount"].to_i
			if card["atk"].to_i < 0
				card["atk"] = 0
			end
		end

		return card
	end

	def reverse_flip(card, player, opponent)
		card["state"]["flipped"] = false

		PrivatePub.publish_to("/board/" + session[:key] + "/" + player, :unflip => true, :alias => card["alias"])
		PrivatePub.publish_to("/board/" + session[:key] + "/opponent/" + opponent, :unflip => true, :alias => card["alias"])

		return card
	end

	def return_cards(server, player, opponent, amount)
		unless server.state[player]["hand"].empty?
			i = 0 #iterator
			until i == amount || server.state[player]["hand"].empty?
				#pop the card from the hand
				card = server.state[player]["hand"].pop

				card["state"]["position"] = "deck"

				#add the card to the hand
				server.state[player]["deck"].push(card)

				i += 1 #increment iterator

				PrivatePub.publish_to("/board/" + session[:key] + "/" + player, :returned => true, :alias => card["alias"])
				PrivatePub.publish_to("/board/" + session[:key] + "/opponent/" + opponent, :returned => true, :alias => card["alias"])
			end

			return server.state
		end
	end

	def discard_cards(server, player, opponent, amount)
		unless server.state[player]["hand"].empty?
			i = 0 #iterator
			until i == amount || server.state[player]["hand"].empty?
				#pop the card from the hand
				card = server.state[player]["hand"].pop

				card["state"]["position"] = "graveyard"

				#add the card to the hand
				server.state[session[:player]]["graveyard"].push(card)

				i += 1 #increment iterator

				PrivatePub.publish_to("/board/" + session[:key] + "/" + player, :returned => true, :alias => card["alias"])
				PrivatePub.publish_to("/board/" + session[:key] + "/opponent/" + opponent, :returned => true, :alias => card["alias"])
			end

			return server.state
		end
	end
end