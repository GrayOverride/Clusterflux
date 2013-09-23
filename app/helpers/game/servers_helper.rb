module Game::ServersHelper
	
	#builds the deck and other possible card containers and saves it in server state
	def fetch_cards(server, deck)
		#cards = ::Card.joins(:type).where("types.name = 'Unit' OR types.name = 'Support'").limit(39)

		#cards = ::Card.find(deck.cards)

		cards = deck.cards.collect {|i| ::Card.find(i) }

		#hq = ::Card.joins(:type).where("types.name = 'Headquarters'").first

		hq = ::Card.find_by_id(deck.hq)

		deck = Array.new
		#card_alias = 1

		card_alias = (1..41).to_a
		card_alias.shuffle!

		cards.each_with_index do |c, i|
			card = build_card(card_alias[i], c)
			deck.push(card)
		end

		deck.shuffle!

		hq = build_card(0, hq)

		deck.unshift(hq)

		server.state[session[:player]]["deck"] = deck

		#create the array for cards on hand
		hand = Array.new
		server.state[session[:player]]["hand"] = hand

		#create the array for deployed cards
		deployed = Array.new
		server.state[session[:player]]["deployed"] = deployed

		#create the array for placed cards
		placed = Array.new
		server.state[session[:player]]["placed"] = placed

		#create the array for dead units
		graveyard = Array.new
		server.state[session[:player]]["graveyard"] = graveyard

		server.update_attributes(:state => server.state)

		return deck
	end

	def build_card(card_alias, c)
		card = Hash.new
		card["alias"] = card_alias
		card["id"] = c.id
		card["name"] = c.name
		card["atk"] = c.atk
		card["def"] = c.def
		card["energy"] = c.energy
		card["upkeep"] = c.upkeep
		card["gank"] = c.gank
		card["type"] = c.type.name
		card["faction"] = c.faction.name
		card["avatar"] = c.avatar.url

		card["scout"] = effect_builder(c.scout)
		card["flip"] = effect_builder(c.flip)

		card["state"] = Hash.new
		card["state"] = {"position" => "deck", "flipped" => false, "powered" => false}

		return card
	end

	def effect_builder(obj)
		effect = Hash.new

		if obj
			effect["name"] = obj.name
			effect["type"] = obj.etype
			effect["effect"] = obj.effect
			effect["amount"] = obj.amount
		else
			effect["name"] = nil
			effect["type"] = nil
			effect["effect"] = nil
			effect["amount"] = nil
		end

		return effect
	end
end
