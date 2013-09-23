function Card(){
	var _self = this;

	this.add_card = function(card){
		var scout = _self.build_effect(card.scout);
		var flip = _self.build_effect(card.flip);
		$("#player-hand").append('<div class="player-card span2 pull-left" data-cid="' + card.alias + '" data-img="' + card.avatar + '" data-flip="n"><div class="card-attrib"> <ul class="ulpop"><li><h4>  '+ card.name + '</h4></li><li> Attack: '+ card.atk + '</li><li> Defense: '+ card.def +'</li><li> Cost & Upkeep: '+ card.upkeep + '</li><li> Flux Generation: '+ card.energy + '</li><li><div class="effectbox"><h6>Probe effect</h6>'+ scout + '</div></li><li><div class="effectbox"><h6>Flip effect</h6>'+ flip + '</div></li></ul></div><img src="' + card.avatar + '" /></div>');
	}

	this.deck_empty = function(empty){
		if(empty){
			$("div#player-deck").css("opacity", "0.6");
		}
		else{
			$("div#player-deck").css("opacity", "1");
		}	
	}

	this.flip_card = function(card){
		console.log("Flipped a card");

		$(".player-card[data-cid='" + card.alias + "']").data('flip', 'y');
		$(".player-card[data-cid='" + card.alias + "']").attr('data-flip', 'y');

		var img = $(".player-card[data-cid='" + card.alias + "']").data("img");
		$(".player-card[data-cid='" + card.alias + "'] img").attr("src", img);

		var scout = _self.build_effect(card.scout);
		var flip = _self.build_effect(card.flip);
		$(".player-card[data-cid='" + card.alias + "'] .card-attrib ul").remove();
		$(".player-card[data-cid='" + card.alias + "']").children(".card-attrib").append('<ul class="ulpop"><li><h4>  '+ card.name + '</h4></li><li> Attack: '+ card.atk + '</li><li> Defense: '+ card.def +'</li><li> Cost & Upkeep: '+ card.upkeep + '</li><li> Flux Generation: '+ card.energy + '</li><li><div class="effectbox"><h6>Probe effect</h6>'+ scout + '</div></li><li><div class="effectbox"><h6>Flip effect</h6>'+ flip + '</div></li></ul>');
	}

	this.unflip_card = function(card){
		console.log("Unflipped a card");
		$(".player-card[data-cid='" + card + "'] img").attr("src","/assets/placeholder.png");

		$(".player-card[data-cid='" + card + "']").data('flip', 'n');
		$(".player-card[data-cid='" + card + "']").attr('data-flip', 'n');
	}

	this.play_card = function(card, unit_slot, flip){
		if(flip == false){
			$(".player-card[data-cid='" + card + "']").data('flip', 'n');
			$(".player-card[data-cid='" + card + "']").attr('data-flip', 'n');
			$(".player-card[data-cid='" + card + "'] img").attr("src","/assets/placeholder.png");
		}
		else{
			$(".player-card[data-cid='" + card + "']").data('flip', 'y');
			$(".player-card[data-cid='" + card + "']").attr('data-flip', 'y');
		}

		$(".player-card[data-cid='" + card + "']").removeClass("span2");
		$(".player-card[data-cid='" + card + "']").addClass("span");
		$(".player-card[data-cid='" + card + "']").appendTo(".unit-slot[data-slot='" + unit_slot + "']");
	}

	this.deploy_card = function(card, deploy_slot){
		$(".player-card[data-cid='" + card + "']").appendTo(".deployed-slot[data-slot='" + deploy_slot + "']");
	}

	this.deploy_hq = function(card){
		$('<div class="player-card span pull-left" data-cid="' + card.alias + '"><div class="card-attrib"><ul class="ulpop"><li><h4>  '+ card.name + '</h4></li><li> Attack: '+ card.atk + '</li><li> Defense: '+ card.def +'</li><li> Cost & Upkeep: '+ card.upkeep + '</li><li> Flux Generation: '+ card.energy + '</li></ul></div><img src="' + card.avatar + '" /></div>').appendTo(".deployed-slot[data-slot='3']");
	}

	//card was returned to deck, remove from hand
	this.return_card = function(card){
		$(".player-card[data-cid='" + card + "']").remove();
	}

	//player card was destroyed, move to graveyard
	this.retire_card = function(card){
		$("div#player-graveyard").empty();
		$("#flip-card").remove();
		$(".player-card[data-cid='" + card + "']").appendTo("div#player-graveyard");
	}

	//opponent card was destroyed, move to graveyard
	this.retire_op_card = function(card){
		$("div#opponent-graveyard").empty();
		$(".op-card[data-cid='" + card + "']").removeClass("select-enemy-outline");
		$(".op-card[data-cid='" + card + "']").appendTo("div#opponent-graveyard");
	}

	//flip opponent card
	this.scout_op_card = function(card){
		console.log("Scouted card");
		var scout = _self.build_effect(card.scout);
		var flip = _self.build_effect(card.flip);
		$(".op-card[data-cid='" + card.alias + "']").children(".card-attrib").append(' <ul class="ulpop"><li><h4>  '+ card.name + '</h4></li><li> Attack: '+ card.atk + '</li><li> Defense: '+ card.def +'</li><li> Cost & Upkeep: '+ card.upkeep + '</li><li> Flux Generation: '+ card.energy + '</li><li><div class="effectbox"><h6>Probe effect</h6>'+ scout + '</div></li><li><div class="effectbox"><h6>Flip effect</h6>'+ flip + '</div></li></ul>');
		$(".op-card[data-cid='" + card.alias + "'] img").attr("src", card.avatar);
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

	// //opponent card was powered down
	// this.power_down_card = function(card){
	// 	console.log("Opponent card was powered down");
	// 	$(".op-card[data-cid='" + card + "']").addClass("unpowered");
	// }

	this.build_effect = function(effect){
		var amount;

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

		//get who the effect will affect
		var whose = null;
		if(effect.type == "scout"){
			whose = "opponent's"
		}
		else{
			whose = "your"
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