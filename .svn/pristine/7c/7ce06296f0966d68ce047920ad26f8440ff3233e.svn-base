$(document).ready(function(){
	var key = $("#game-title").data("key");
	var pid = $("#game-title").data("player");
	var chat = new Chat(key);
	var player = new Player(key, pid);
	var opponent = new Opponent(key, pid);

	PrivatePub.subscribe("/board/" + key, function(data, channel){
	  if(data.ready){
	  	chat.logger("System", data.username + " is ready");

	  	if(data.starter){
	  		if(player.plid == data.starter){
	  			chat.logger("System", "You have first turn");

	  			$.ajax({
					type: "POST",
					url: "../turn/start_turn",
					data: "key=" + key + "&player=" + pid,
					success: function(){
						player.turn.draw_hq();
	  					player.turn.start_turn(false);
	  					player.my_turn = true;
					}
				});
	  		}
	  		else{
	  			$("div#phases").hide();
	  			$("div#not-my-turn").show();
	  			chat.logger("System", "Opponent has first turn");
	  		}
	  	}
	  }

	  if(data.message){
		chat.logger(data.message.sender, data.message.content);
	  }
	});
});

//disconnect upon leaving/refreshing page
$(window).unload(function(){
	var pathname = window.location.pathname;
	pathname = pathname.split("/");
	var key = pathname[pathname.length-1];

	$.ajax({
		type: "POST",
		url: "disconnect",
		data: "key=" + key,
		async: false
	});
});