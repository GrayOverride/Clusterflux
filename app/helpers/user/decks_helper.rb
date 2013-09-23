module User::DecksHelper
	def effect_builder(effect)
		unless effect.nil?
			if !effect.etype.nil? && effect.etype == "scout"
				whose = "opponent's"
			else
				whose = "your"
			end

			if !effect.amount.nil? && effect.amount == 100
				amount = "+100%"
			elsif !effect.amount.nil? && effect.amount == 50
				amount = "-50%"
			elsif !effect.amount.nil? && effect.amount > 0
				amount = "+" + effect["amount"].to_s
			elsif !effect.amount.nil? && effect.amount < 0
				amount = effect["amount"].to_s
			end
		
			case effect.effect
				when "def"
				  	return "<b>" + effect.name + ":</b> It has a " + amount + " modifier in defence."
				when "atk"
					return "<b>" + effect.name + ":</b> It has a " + amount + " modifier in attack."
				when "atk_def"
					return "<b>" + effect.name + ":</b> It has a " + amount + " modifier in attack and defence."
				when "draw"
					return "<b>" + effect.name + ":</b> It gives " + effect.amount.to_s + " cards."
				when "disable"
					return "<b>" + effect.name + ":</b> Disables an opposing card."
				when "hide"
					return "<b>" + effect.name + ":</b> This card is immune to probe actions."
				when "immortal"
					return "<b>" + effect.name + ":</b> This card is immortal when probed"
				when "coward"
					return "<b>" + effect.name + ":</b> This card will not fight when probed and an entrenched unit is targeted."
				when "defector"
					return "<b>" + effect.name + ":</b> This card will assist opponent's attack."
				when "discard"
					return "<b>" + effect.name + ":</b> This card will kill " + effect.amount.to_s + " of " + whose + " cards in hand.";
				when "return"
					return "<b>" + effect.name + ":</b> Returns " + effect.amount.to_s + " of " + whose + " cards from" + whose + " hand to the deck"
				else
					return "None"
			end
		else
			return "None"
		end
	end
end
