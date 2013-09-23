function Turn(key, pid){
	var _self = this;
	this.key = key;
	this.plid = pid;
	this.card = new Card();
	this.hq = new Card();
	this.no_more = false;

	this.settings = {
		animation: 0,	// Animation speed
		buttons: {
			no_more: {
				action: function(){ 
					_self.no_more = true;
					Apprise('close'); 
				},
				className: "btn btn-warning", // Custom class name(s)
				text: "Don't show again", // Button text
			},
			confirm: {
				action: function(){
					Apprise('close'); 
				},
				className: "btn btn-primary", // Custom class name(s)
				text: 'Ok', // Button text
			}
			
		},
		input: false, // input dialog
		override: true // Override browser navigation while Apprise is visible
	};

	this.start_turn = function(draw){
		if(!_self.no_more){
			Apprise("<b>It is your turn now!</b><p>This is what you can do</p><ol><li>Draw a card (happens automatically)</li><li>Entrench a card </li><li>Flip a deployed card</li><li>Deploy a card, either face up or down</li><li>Set up a combat plan and then attack your opponent</li></ol><p>Please note that you cannot backtrack, you can't for example, flip cards and then entrench a card.</p>", _self.settings);
		}

		$("div#not-my-turn").hide();
		$("div#phases").show();

		if(draw){
			$.ajax({
				type: "POST",
				url: "../turn/start_turn",
				data: "key=" + _self.key + "&player=" + _self.plid,
				success: function(){
					_self.draw_card();
				}
			});
		}
	}

	this.draw_hq = function(){
		$.ajax({
			type: "POST",
			url: "../turn/draw",
			data: "key=" + _self.key + "&player=" + _self.plid + "&draw=hq",
			success: function(){
				_self.draw_initial();
			}
		});
	}

	this.draw_initial = function(){
		$.ajax({
			type: "POST",
			url: "../turn/draw",
			data: "key=" + _self.key + "&player=" + _self.plid + "&draw=initial"
		});
	}

	this.draw_card = function(){
		$.ajax({
			type: "POST",
			url: "../turn/draw",
			data: "key=" + _self.key + "&player=" + _self.plid + "&draw=nil"
		});
	}

	this.flip_card = function(card){
		$.ajax({
			type: "POST",
			url: "../turn/flip",
			data: "key=" + _self.key + "&player=" + _self.plid + "&card=" + card
		});
	}

	this.deploy_card = function(card, pos){
		if(card != null && pos != null){
			$.ajax({
				type: "POST",
				url: "../turn/deploy",
				data: "key=" + _self.key + "&player=" + _self.plid + "&card=" + card + "&pos=" + pos
			});
		}
		else{
			Apprise("You need to select a deployed card and a trench-slot in order to entrench.", _self.settings);
		}
	}

	this.place_card = function(card, pos, flip){
		if(card != null && pos != null){
			$.ajax({
				type: "POST",
				url: "../turn/place",
				data: "key=" + _self.key + "&player=" + _self.plid + "&card=" + card + "&pos=" + pos + "&flip=" + flip
			});
		}
		else{
			Apprise("You need to select a card in your hand and a deployment-slot in order to deploy.", _self.settings);
		}
	}

	this.attack = function(queue){
		if(queue.length > 0){
			$.ajax({
				type: "POST",
				url: "../turn/attack",
				data: {"key": _self.key, "player": _self.plid, "attack": JSON.stringify(queue)}
			});
		}
		else{
			Apprise("You need to plan you attack first.", _self.settings);
		}
	}

	this.end_turn = function(){
		$.ajax({
			type: "POST",
			url: "../turn/end_turn",
			data: "key=" + _self.key
		});
	}
}