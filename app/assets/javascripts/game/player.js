function Player(key, pid){
	var _self = this;
	this.key = key;
	this.plid = pid;
	
	//creates a new turn, functions during players turn
	this.turn = new Turn(_self.key, _self.plid);

	this.energy = 0;
	this.upkeep = 0;

	//selected unit and unit-slot
	this.s_card = null;
	this.s_slot = null;

	//selected deployment slot and card
	this.s_dslot = null;
	this.s_dcard = null;

	//selected opponent unit, deployed or otherwise
	this.s_target = null;
	this.s_dtarget = null;

	//array containing attack-queue
	this.queue = new Array();

	this.my_turn = false;

	this.settings = {
		animation: 0,	// Animation speed
		buttons: {
			confirm: {
				action: function(){ 
					Apprise('close'); 
				},
				className: "btn btn-primary", // Custom class name(s)
				id: 'confirm', // Element ID
				text: 'Ok', // Button text
			}
		},
		input: false, // input dialog
		override: true // Override browser navigation while Apprise is visible
	};

	this.ready = function(){
		$.ajax({
			type: "POST",
			url: "ready",
			data: "key=" + _self.key
		});
	}

	this.update_energy = function(){
		$('h4#player-energy span').text(_self.upkeep + "/" + _self.energy);
	}

	$("#ready").click(function(){
		_self.ready();
		$(this).remove();
	});

	//when flip button is clicked
	$("div.unit-slot").delegate("#flip-card", "click", function(event) {
		event.stopPropagation();

		$('#flip-card').remove();

		_self.turn.flip_card(_self.s_card);

		$(".player-card").popover('destroy');
		$(".player-card").removeClass("select-outline");
		_self.s_card = null;
	});

	$("div.unit-slot").delegate(".place-card", "click", function() {
		var flip = $(this).data("flip");

		_self.turn.place_card(_self.s_card, _self.s_slot, flip);

		$('.place-card').remove();
		$(".player-card").removeClass("select-outline");
		$(".unit-slot").removeClass("select-outline");
		$(".player-card").popover('destroy');
	});

	$("div.deployed-slot").delegate("#deploy-card", "click", function() {
		$('#deploy-card').remove();

		var allowed = $(".player-card[data-cid='" + _self.s_card + "']").data('flip');

		if(allowed == "y"){
			$(".player-card").popover('destroy');
			$(".deployed-slot").removeClass('select-outline');
			$(".player-card").removeClass('select-outline');
			_self.turn.deploy_card(_self.s_card, _self.s_dslot);
		}
	});

	$("#commit-queue").click(function(){
		var allowed = $(".player-card[data-cid='" + _self.s_card + "']").data('flip');

		if(allowed == "y" && _self.s_card != null && (_self.s_target != null || _self.s_dtarget != null) && _self.my_turn == true){
			var allowed = $(".player-card[data-cid='" + _self.s_card + "']").data('flip');

			if(allowed == "y"){
				var exists = true;

				$.map(_self.queue, function(c, i){
					if(c.unit == _self.s_card){
						exists = false;
					}
				});

				if(exists){
					_self.queue.push(new Attack(_self.s_card, _self.s_target, _self.s_dtarget));
					_self.s_card = null;
					_self.s_target = null;
					_self.s_dtarget = null;
					
					console.log(JSON.stringify(_self.queue));
					$(".op-card").removeClass("select-enemy-outline"); //remove the outline
					$(".player-card").removeClass("select-outline"); //remove the outline

					$(".player-card").popover('destroy');
					$(".op-card").popover('destroy');
				}
				else{
					Apprise("You can't attack with the same unit twice in one turn", _self.settings);
				}
			}
			else{
				Apprise("You can't attack with a unflipped card", _self.settings);
				$(".op-card").removeClass("select-enemy-outline"); //remove the outline
				$(".player-card").removeClass("select-outline"); //remove the outline

				$(".player-card").popover('destroy');
				$(".op-card").popover('destroy');
			}
		}
		else{
			Apprise("In order to attack you need to: In your turn, select your card, target an enemy unit or resource (if undefended), or target both a unit and an entrenched unit behind.", _self.settings);
			$(".player-card").popover('destroy');
			$(".op-card").popover('destroy');
			$(".op-card").removeClass("select-enemy-outline"); //remove the outline
			$(".player-card").removeClass("select-outline"); //remove the outline

		}
	});

	$("#attack-target").click(function(){
		if(_self.my_turn == true){
			_self.turn.attack(_self.queue);
			_self.queue.length = 0;

			$("html").removeClass("select-enemy-outline"); //remove the outline
			$("html").removeClass("select-outline"); //remove the outline
			$("html").popover('destroy');
			_self.s_card = null;
			_self.s_target = null;
			_self.s_dtarget = null;
		}
	});

	$("#end-turn").click(function(){
		if(_self.my_turn == true){
			//empty some variables
			_self.s_card = null;
			_self.s_slot = null;
			_self.s_dslot = null;
			_self.s_target = null;
			_self.s_dtarget = null;
			_self.queue.length = 0;

			$("html").popover('destroy');

			$("div#phases").hide();
			$("div#phases span").removeClass("phase-active phase-passed");
			$("div#not-my-turn").show();

			$("html").removeClass("select-enemy-outline"); //remove the outline
			$("html").removeClass("select-outline"); //remove the outline

			//removes buttons only usable in a turn
			$('.place-card').remove();
			$('#flip-card').remove();
			$('#deploy-card').remove();

			_self.turn.end_turn();
			_self.my_turn = false;
		}
	});

	//select or deselect a unit slot
	$("div.unit-slot").click(function(event){
		$("div.unit-slot").removeClass("select-outline");

		if(_self.s_card){
			var $target = $(event.target); //get the actual trigger element
			
			if($target.is("div")){
				$('.place-card').remove(); //remove the buttons if they exist

				var slot = $(this).data("slot"); //get the value of the data-slot (position of the slot)

				if(_self.s_slot == slot){
					_self.s_slot = null; //deselects the slot
					$(this).removeClass("select-outline");

					console.log("Deselected slot");
					console.log(_self.s_slot);
				}
				else{
					//if slot is occupied, do not select it
					if(!$.trim($(this).html()).length && _self.my_turn == true){
						_self.s_slot = slot; //select the slot

						$(this).addClass("select-outline");

						//add the buttons to the slot on select
						$(this).append('<a href="javascript:void(0)" class="place-card btn btn-small btn-inverse card-btn" data-flip="up">Face up</a>');
						$(this).append('<a href="javascript:void(0)" class="place-card btn btn-small btn-inverse card-btn" data-flip="down">Face down</a>');

						console.log("Selected slot");
						console.log(_self.s_slot);
					}
				}
			}
		}
		else{
			$(this).popover('destroy');
			$('.place-card').remove(); //remove the buttons if they exist
		}
	});

	//select or deselect a deployment slot
	$(".deployed-slot").click(function(event){
		var $target = $(event.target);

		if($target.is("div")){
			var slot = $(this).data("slot");

			$(".deployed-slot").removeClass("select-outline");
			$('#deploy-card').remove();

			if(_self.s_dslot == slot){
				_self.s_dslot = null; //deselect deploy-slot

				$(this).removeClass("select-outline");

				console.log("Deselected deployed slot");
			}
			else{
				$('#deploy-card').remove();
				var allowed = $(".player-card[data-cid='" + _self.s_card + "']").data('flip');

				if(_self.s_card && allowed == "y" && _self.my_turn == true){
					_self.s_dslot = slot; //select deploy-slot

					$(this).append('<a href="javascript:void(0)" id="deploy-card" class="btn btn-inverse card-btn">Entrench</a>');

					$(this).addClass("select-outline");

					console.log("Selected deployed slot");
				}
			}
		}
	});

	//adds event to cards after page load, all of this player's cards receives this functionality
	//the actual functionality is to select or deselect a card
	$("div#player-hand, div.unit-slot").delegate("div.player-card", "click", function(event) {

		var $target = $(event.target);
		var cid = $(this).data("cid"); //gets the alias of the card

		if(_self.s_card == cid){
			_self.s_card = null; //deselected card
			$('.place-card').remove(); //remove place buttons if they exist

			console.log("Deselected card");

			$(this).removeClass("select-outline");
			$(".player-card").popover('destroy');
			$('#flip-card').remove();
		}
		else{
			_self.s_card = cid; //selected card
			console.log("Selected card");

			$(".player-card").popover('destroy');
			$(".player-card").removeClass("select-outline");
			$("div.unit-slot").removeClass("select-outline");
			$('#flip-card').remove();

			$(this).addClass("select-outline");

			var content = $(this).children(".card-attrib").html();

			$(this).popover({ 
				html : true,
				placement: 'top',
				animation: false,
				trigger: 'manual',
				title: '<button type="button" class="close dismiss-pop" data-dismiss="popover">&times;</button>',
				container: 'body',
				content: content
			}).popover('show');

			if($(this).parent().hasClass("unit-slot")){
				//if the card is not flipped, show the flip button, otherwise don't
				if($(this).data("flip") == "n" && _self.my_turn == true){
					$(this).append('<a href="javascript:void(0)" id="flip-card" class="btn btn-inverse card-btn">Flip</a>');
				}
			}
		}

		console.log(_self.s_card);
	});

	$("div.deployed-slot, div#player-graveyard").delegate("div.player-card", "click", function(event) {
		var cid = $(this).data("cid");


		$(".player-card").popover('destroy');

		if(_self.s_dcard == cid){
			_self.s_dcard = null;
		}
		else{
			_self.s_dcard = cid;

			var content = $(this).children(".card-attrib").html();
			$(this).popover({ 
				html : true,
				trigger: 'manual',
				animation: false,
				title: '<button type="button" class="close dismiss-pop" data-dismiss="popover">&times;</button>',
				placement: 'top',
				container: 'body',
				content: content
			}).popover('show');
		}	
	});

	//targets opponent card
	$("div.op-unit-slot").delegate("div.op-card", "click", function() {
		//gets the id of the card from element data attribute
		var content = null;
		var cid = $(this).data("cid");

		$("div.op-unit-slot div.op-card").popover('destroy'); //remove the popover
		$("div.op-unit-slot div.op-card").removeClass("select-enemy-outline"); //remove the outline

		//either selects or deselects
		if(_self.s_target == cid){
			_self.s_target = null; //deselects target

			console.log("Opponent card deselected");
		}
		else{
			_self.s_target = cid; //selects target

			$(this).addClass("select-enemy-outline"); //add the outline
			
			console.log("Opponent card selected");

			if ($(this).children(".card-attrib").html().trim() == "") {
				content = "Enemy Unknown";
			}
			else{
				content = $(this).children(".card-attrib").html();
			}

			$(this).popover({ 
				html : true,
				trigger: 'manual',
				animation: false,
				title: '<button type="button" class="close dismiss-pop" data-dismiss="popover">&times;</button>',
				placement: 'right',
				container: 'body',
				content: content
			}).popover('show');
		}
	});

	//target opponent deployed card
	$("div.op-deployed-slot, div#opponent-graveyard").delegate("div.op-card", "click", function() {
		//gets the id of the card from element data attribute
		var cid = $(this).data("cid");
		var slot = parseInt($(this).closest("div.op-deployed-slot").data("slot"));
		var pSlot = slot - 1;
		var nSlot = slot + 1;
		var content = $(this).children(".card-attrib").html();

		$("div.op-deployed-slot div.op-card").removeClass("select-enemy-outline"); //remove the outline
		$("div.op-deployed-slot div.op-card").popover('destroy');

		//deselects if already selected
		if(_self.s_dtarget == cid){
			_self.s_dtarget = null; //deselect the card
			console.log("Deselected deploy-slot");
		}
		else{
			$(this).popover({ 
				html : true,
				trigger: 'manual',
				animation: false,
				title: '<button type="button" class="close dismiss-pop" data-dismiss="popover">&times;</button>',
				placement: 'bottom',
				container: 'body',
				content: content
			}).popover('show');

			//targets a deployed card if allowed (defence is targeted or no defence present)
			if(_self.s_target){
				var unit = parseInt($('div.op-card[data-cid="' + _self.s_target + '"]').closest("div.op-unit-slot").data("slot"));

				if(unit - 1 == slot || unit == slot){
					_self.s_dtarget = cid;
					$(this).addClass("select-enemy-outline");

					console.log("deployed card with defence, where a defending card is targeted");
				}
				else{
					_self.s_dtarget = null;
					console.log("Deployed card has defence, attack must go through it");
				}
			}
			else{
				//if deployed card has no defence
				if(!$.trim($('.op-unit-slot[data-slot="' + slot + '"]').html()).length && !$.trim($('.op-unit-slot[data-slot="' + nSlot + '"]').html()).length){
					_self.s_dtarget = cid;
					$(this).addClass("select-enemy-outline");

					console.log("deployed card without defence " + cid);
				}
				else{
					console.log("Deployed card has defence, attack must go through it");
				}
			}
		}
	});

	//on popover click, remove it
	$("body").delegate("div.popover", "click", function() {
		$(this).remove();
	});

	PrivatePub.subscribe("/board/" + _self.key + "/" + _self.plid, function(data, channel){
		if(data.start_turn){
			_self.my_turn = true;
			_self.turn.start_turn(true);
		}

		//deploy hq
		if(data.hq){
			_self.turn.hq.deploy_hq(data.hq);

			//update player's energy
			_self.energy = data.energy;
			_self.update_energy();
		}

		//add card to hand
		if(data.draw){
			if(data.card){
				_self.turn.card.add_card(data.card);
				_self.turn.card.deck_empty(false);
			}
			else{
				_self.turn.card.deck_empty(true);
			}
			
			_self.phases("draw");
		}

		//flip card in unit slot
		if(data.flipped){
			_self.turn.card.flip_card(data.card);

			_self.s_card = null;
			_self.s_slot = null;

			_self.phases("flip");
		}

		//unflip card in unit slot
		if(data.unflip){
			_self.turn.card.unflip_card(data.alias);

			_self.s_card = null;
			_self.s_slot = null;

			_self.phases("combat");
		}

		//place card in unit slot
		if(data.placed){
			var flip = data.flip

			_self.turn.card.play_card(data.place_card, data.pos, flip);

			_self.upkeep = data.upkeep;
			_self.energy = data.energy;
			_self.update_energy();

			_self.s_card = null;
			_self.s_slot = null;

			_self.phases("deploy");
		}

		//place card in unit slot
		if(data.returned){

			_self.turn.card.return_card(data.alias);

			_self.s_card = null;
			_self.s_slot = null;
		}

		//deploy card from unit slot
		if(data.deployed){
			_self.turn.card.deploy_card(data.deploy_card, data.pos);
			
			//update player's energy
			_self.energy = data.energy;
			_self.upkeep = data.upkeep;
			_self.update_energy();

			_self.s_card = null;
			_self.s_dslot = null;

			_self.phases("entrench");
		}

		//result of attack
		if(data.combat){
			_self.phases("combat");

			console.log("You attacked your opponent");

			//empties targeting and queue variables
			_self.s_target = null;
			_self.s_dtarget = null;
			_self.queue.length = null;

			$(".op-card").removeClass("select-enemy-outline");
			$(".player-card").removeClass("select-outline");

			//move attacking cards to graveyard if destroyed
			var card;
			for(var i = 0; i < data.result[_self.plid]["destroyed"].length; i++){
				card = data.result[_self.plid]["destroyed"][i];
				_self.turn.card.retire_card(card);
			}

			//update player's upkeep
			_self.upkeep = data.result[_self.plid].upkeep;
			_self.update_energy();

			var opponent = _self.fetch_opponent();

			//move defending cards to graveyard if destroyed
			var op_card;
			for(var i = 0; i < data.result[opponent]["destroyed"].length; i++){
				op_card = data.result[opponent]["destroyed"][i];
				_self.turn.card.retire_op_card(op_card);
			}

			//flip scouted cards
			var scouted;
			for(var i = 0; i < data.result[_self.plid]["scouted"].length; i++){
				scouted = data.result[_self.plid]["scouted"][i];
				_self.turn.card.scout_op_card(scouted);
			}


			// //power down opponent cards
			// if(data.result[opponent]["powered_down"]){
			// 	var opdc;
			// 	for(var i = 0; i < data.result[opponent]["powered_down"].length; i++){
			// 		opdc = data.result[opponent]["powered_down"][i];
			// 		_self.turn.card.power_down_card(opdc);
			// 	}
			// }

			//if player won the game
			if(data.game){	
				var end_options = {
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
					override: true // Override browser navigation while Apprise is visible
				};

				Apprise('You won, great work! \nIf you wish to support us in our work, please take the time to answer <a href="https://docs.google.com/forms/d/1-WLtK2rQvIkYO5psA3hzwYs-I6pUUc5mc7mdVpTKBmE/viewform">this survey</a> \n Much appreciated!', end_options);
			}
		}

		//power up cards
		if(data.player_power_up){
			var ppuc;
			for(var i = 0; i < data.player_power_up.length; i++){
				ppuc = data.player_power_up[i];
				_self.turn.card.power_up_card(ppuc);
			}
		}

		//power up opponent cards
		if(data.opponent_power_up){
			var opuc;
			for(var i = 0; i < data.opponent_power_up.length; i++){
				opuc = data.opponent_power_up[i];
				_self.turn.card.power_up_op_card(opuc);
			}
		}

		if(data.notice){
			$("#chat").append('<p class="text-error">System: It is not your turn</p>');
		}
	});

this.fetch_opponent = function(){
	if(_self.plid == "player_1"){
		opponent = "player_2";
	}
	else{
		opponent = "player_1";
	}

	return opponent;
}

this.phases = function(phase){
	switch(phase){
		case "draw":
		$("div#phases span:nth-child(1)").addClass("phase-passed");
		$("div#phases span:nth-child(2)").addClass("phase-active");
		break;
		case "entrench":
		$("div#phases span:nth-child(2)").prevAll().addClass("phase-passed");
		$("div#phases span:nth-child(2)").addClass("phase-passed");
		$("div#phases span:nth-child(3)").addClass("phase-active");
		break;
		case "flip":
		$("div#phases span:nth-child(3)").prevAll().addClass("phase-passed");
		$("div#phases span:nth-child(3)").addClass("phase-active");
		break;
		case "deploy":
		$("div#phases span:nth-child(4)").prevAll().addClass("phase-passed");
		$("div#phases span:nth-child(4)").addClass("phase-active");
		break;
		case "combat":
		$("div#phases span:nth-child(5)").prevAll().addClass("phase-passed");
		$("div#phases span:nth-child(5)").addClass("phase-passed");
		break;
	}
}	
}