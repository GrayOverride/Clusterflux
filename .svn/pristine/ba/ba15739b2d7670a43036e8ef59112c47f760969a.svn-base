function Opponent(key, pid){
	var _self = this;
	this.key = key;
	this.plid = pid;
	this.settings = {
		animation: 0,	// Animation speed
		buttons: {
			confirm: {
				className: null, // Custom class name(s)
				id: 'confirm', // Element ID
				text: 'Ok', // Button text
			}
		},
		input: false, // input dialog
		override: false, // Override browser navigation while Apprise is visible
	};

	PrivatePub.subscribe("/board/" + _self.key + "/opponent/" + _self.plid, function(data, channel){
		//deploy HQ
		if(data.hq){
			console.log("Opponent deployed his hq");
			$('<div class="op-card span pull-left" data-cid="' + data.hq.alias + '"><div class="card-attrib"><ul class="ulpop"><li><h4>  '+ data.hq.name + '</h4></li><li> Attack: '+ data.hq.atk + '</li><li> Defense: '+ data.hq.def +'</li><li> Cost & Upkeep: '+ data.hq.upkeep + '</li><li> Flux Generation: '+ data.hq.energy + '</li></ul></div><img src="' + data.hq.avatar + '" /></div>').appendTo(".op-deployed-slot[data-slot='3']");
		}

		//draw card, add to hand
		if(data.draw){
			if(data.card){
				$("#opponent-hand").append('<div class="op-card span2 pull-left" data-cid="' + data.card + '"><div class="card-attrib"></div><img src="/assets/placeholder.png" /></div>');
			}
			else{
				_self.deck_empty();
			}
		}

		//flip card in unit slot
		if(data.flipped){
			var scout = _self.build_effect(data.card.scout);
			var flip = _self.build_effect(data.card.flip);
			$(".op-card[data-cid='" + data.card.alias + "']").children(".card-attrib").append('<ul class="ulpop"><li><h4>  '+ data.card.name + '</h4></li><li> Attack: '+ data.card.atk + '</li><li> Defense: '+ data.card.def +'</li><li> Cost & Upkeep: '+ data.card.upkeep + '</li><li> Flux Generation: '+ data.card.energy + '</li><li><div class="effectbox"><h6>Probe effect</h6>'+ scout + '</div></li><li><div class="effectbox"><h6>Flip effect</h6>'+ flip + '</div></li></ul>');
			$(".op-card[data-cid='" + data.card.alias + "'] img").attr("src", data.card.avatar);
		}

		//flip card in unit slot
		if(data.unflip){
			$(".op-card[data-cid='" + data.alias + "'] img").attr("src", "/assets/placeholder.png");
			$(".op-card[data-cid='" + data.alias + "'] div.card-attrib").empty();
		}

		//return card in hand to deck (remove it)
		if(data.returned){
			$(".op-card[data-cid='" + data.alias + "']").remove();
		}

		//place card from hand
		if(data.placed){
			if(data.flip){
				var scout = _self.build_effect(data.place_card.scout);
				var flip = _self.build_effect(data.place_card.flip);
				$(".op-card[data-cid='" + data.place_card.alias + "']").children(".card-attrib").append(' <ul class="ulpop"><li><h4>  '+ data.place_card.name + '</h4></li><li> Attack: '+ data.place_card.atk + '</li><li> Defense: '+ data.place_card.def +'</li><li> Cost & Upkeep: '+ data.place_card.upkeep + '</li><li> Flux Generation: '+ data.place_card.energy + '</li><li><div class="effectbox"> Probe effect: '+ scout + '</div></li><li><div class="effectbox"> Flip effect: '+ flip + '</div></li></ul>');
				$(".op-card[data-cid='" + data.place_card.alias + "']").removeClass("span2");
				$(".op-card[data-cid='" + data.place_card.alias + "']").addClass("span");
				$(".op-card[data-cid='" + data.place_card.alias + "'] img").attr("src", data.place_card.avatar);

				$(".op-card[data-cid='" + data.place_card.alias + "']").appendTo(".op-unit-slot[data-slot='" + data.pos + "']");
			}
			else{
				$(".op-card[data-cid='" + data.place_card + "']").removeClass("span2");
				$(".op-card[data-cid='" + data.place_card + "']").addClass("span");
				$(".op-card[data-cid='" + data.place_card + "']").appendTo(".op-unit-slot[data-slot='" + data.pos + "']");
			}
		}

		//deploy card from placed
		if(data.deployed){
			$(".op-card[data-cid='" + data.deploy_card + "']").appendTo(".op-deployed-slot[data-slot='" + data.pos + "']");
		}

		//result of attack
		if(data.combat){
			console.log("You were attacked by your opponent");
			
			//move defending cards to graveyard if destroyed
			var card;
			for(var i = 0; i < data.result[_self.plid]["destroyed"].length; i++){
			   card = data.result[_self.plid]["destroyed"][i];
			   _self.retire_card(card);
			}

			//update player's upkeep and energy
			_self.update_energy(data.result[_self.plid]["upkeep"], data.result[_self.plid]["energy"]);

			var opponent;
			if(_self.plid == "player_1"){
				opponent = "player_2";
			}
			else{
				opponent = "player_1";
			}

			//move attacking cards to graveyard if destroyed
			var op_card;
			for(var i = 0; i < data.result[opponent]["destroyed"].length; i++){
			   op_card = data.result[opponent]["destroyed"][i];
			   _self.retire_op_card(op_card);
			}

			//flip scouted cards
			var scouted;
			for(var i = 0; i < data.result[opponent]["scouted"].length; i++){
			   card = data.result[opponent]["scouted"][i];
			   _self.scout_card(card);
			}

			//power down cards
			if(data.powered_down){
				var ppdc; //Player Powered Down Card
				for(var i = 0; i < data.result[_self.plid]["powered_down"].length; i++){
				   ppdc = data.result[_self.plid]["powered_down"][i];
				   _self.power_down_card(ppdc);
				}
			}

			//if player lost the game
			if(data.game){
				//alert("You lost, better luck next time!");
				var settings = {
					animation: 0,	// Animation speed
					buttons: {
						confirm: {
							action: function() {
								window.location = "/game/servers";
							}, // Callback function
							className: "btn btn-primary", // Custom class name(s)
							id: 'confirm', // Element ID
							text: 'Ok', // Button text
						}
					},
					input: false, // input dialog
					override: true, // Override browser navigation while Apprise is visible
				};
				Apprise('You lost, better luck next time! \nIf you wish to support us in our work, please take the time to answer <a href="https://docs.google.com/forms/d/1-WLtK2rQvIkYO5psA3hzwYs-I6pUUc5mc7mdVpTKBmE/viewform">this survey</a> \n Much appreciated!', settings);
			}
		}

		//power up cards
		if(data.player_power_up){
			var ppuc; //Player Powered Up Card
			for(var i = 0; i < data.player_power_up.length; i++){
			   ppuc = data.player_power_up[i];
			   _self.power_up_card(ppuc);
			}
		}

		//power up opponent cards
		if(data.opponent_power_up){
			var opuc; //Opponent Powered Up Card
			for(var i = 0; i < data.opponent_power_up.length; i++){
			   opuc = data.opponent_power_up[i];
			   _self.power_up_op_card(opuc);
			}
		}
	});

	this.deck_empty = function(card){
		$("div#opponent-deck").css("opacity", "0.6");
	}
	
	//player card was destroyed, move to graveyard
	this.retire_card = function(card){
		$("div#player-graveyard").empty();
		$("#flip-card").remove();
		$(".player-card[data-cid='" + card + "']").removeClass("select-outline");
		$(".player-card[data-cid='" + card + "']").appendTo("div#player-graveyard");
	}

	//opponent card was destroyed, move to graveyard
	this.retire_op_card = function(card){
		$("div#opponent-graveyard").empty();
		$(".op-card[data-cid='" + card + "']").removeClass("enemy-select-outline");
		$(".op-card[data-cid='" + card + "']").appendTo("div#opponent-graveyard");
	}

	//card was scouted
	this.scout_card = function(card){
		var scout = _self.build_effect(card.scout);
		var flip = _self.build_effect(card.flip);
		$(".player-card[data-cid='" + card.alias + "'] .card-attrib ul").remove();
		$(".player-card[data-cid='" + card.alias + "']").children(".card-attrib").append('<ul class="ulpop"><li><h4>'+ card.name + '</h4></li><li> Attack: '+ card.atk + '</li><li> Defense: '+ card.def +'</li><li> Cost & Upkeep: '+ card.upkeep + '</li><li> Flux Generation: '+ card.energy + '</li><li><div class="effectbox"> Probe effect: '+ scout + '</div></li><li><div class="effectbox"> Flip effect: '+ flip + '</div></li></ul>');
		$(".player-card[data-cid='" + card.alias + "']").data('flip', 'y');
		$(".player-card[data-cid='" + card.alias + "']").attr('data-flip', 'y');
		$(".player-card[data-cid='" + card.alias + "'] img").attr("src", card.avatar);
	}

	//unpowered card was powered up
	this.power_up_card = function(card){
		console.log("Unpowered card was powered up");
		$(".player-card[data-cid='" + card + "']").removeClass("unpowered");
	}

	//opponent unpowered card was powered up
	this.power_up_op_card = function(card){
		console.log("Opponent unpowered card was powered up");
		$(".op-card[data-cid='" + card + "']").removeClass("unpowered");
	}

	//card was powered down
	this.power_down_card = function(card){
		console.log("Card was powered down");
		$(".player-card[data-cid='" + card + "']").addClass("unpowered");
	}

	this.update_energy = function(upkeep, energy){
		$('h4#player-energy span').text(upkeep + "/" + energy);
	}

	this.build_effect = function(effect){
		//readable double or half
		if(effect.amount == 100){
			effect.amount = "+100%";
		}
		else if(effect.amount == 50){
			effect.amount = "-50%";
		}

		//get who the effect will affect
		var whose = null;
		if(effect.type == "scout"){
			whose = "opponent's"
		}
		else{
			whose = "your"
		}

		if(effect.amount == 100){
			amount = "+100%";
		}
		else if(effect.amount == 50){
			amount = "-50%";
		}
		else if(effect.amount < 0){
			amount = effect.amount;
		}
		else{
			amount = "+" + effect.amount;
		}

		switch(effect.effect){
			case "def":
			  return "<b>" + effect.name + ":</b> It has a " + amount + " modifier in defence.";
			break;
			case "atk":
			  return "<b>" + effect.name + ":</b> It has a " + amount + " modifier in attack.";
			break;
			case "atk_def":
			  return "<b>" + effect.name + ":</b> It has a " + amount + " modifier in attack and defence.";
			break;
			case "draw":
			  return "<b>" + effect.name + ":</b> It gives " + effect.amount + " cards.";
			break;
			case "disable":
			  return "<b>" + effect.name + ":</b> Disables an opposing card.";
			break;
			case "hide":
			  return "<b>" + effect.name + ":</b> This card is immune to probe actions.";
			break;
			case "immortal":
			  return "<b>" + effect.name + ":</b> This card is immortal when probed";
			break;
			case "coward":
			  return "<b>" + effect.name + ":</b> This card will not fight when probed and an entrenched unit is targeted.";
			break;
			case "defector":
			  return "<b>" + effect.name + ":</b> This card will assist opponent's attack.";
			break;
			case "discard":
			  return "<b>" + effect.name + ":</b> This card will kill " + effect.amount + " of " + whose + " cards in hand.";
			break;
			case "return":
			  return "<b>" + effect.name + ":</b> Returns " + effect.amount + " of " + whose + " cards from " + whose + " hand to the deck";
			break;
			default:
			  return "None";
		}
	}
}