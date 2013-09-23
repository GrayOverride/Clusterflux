$(document).ready(function(){
	PrivatePub.subscribe("/servers/new", function(data, channel) {
	  $("#server-table").append('<tr id="' + data.server.key + '">' +
	  								'<td>' + data.server.name + '</td>' + 
	  								'<td>' + data.creator + '</td>' + 
	  								'<td><a href="javascript:void(0)" data-url="' + data.url + '" class="btn btn-inverse join-btn">Join</a></td>' +
	  							'</tr>');
	});

	PrivatePub.subscribe("/servers/remove", function(data, channel) {
	  $("#" + data.key).remove();
	});

	var settings = {
		animation: 0,	// Animation speed
		buttons: {
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

	$('div#loading-div').hide();

	$("#server-table").delegate("tr td a.join-btn", "click", function() {
		if($("select#deck").val().trim() != ""){
			var deck = $("select#deck").val();
			var url = $(this).data("url");
			if(url && deck){
				$('div#loading-div').show();
				$.ajax({
					type: "GET",
					url: url,
					data: "deck=" + deck,
					success: function(response){
						if(response.result == true){
							$('div#loading-div').hide();
							window.location = response.path;
						}
						else{
							$('div#loading-div').hide();
							Apprise("Couldn't join game, try another server or refresh the page and try again.", settings);
						}		
					}
				});
			}
			else{
				Apprise("Something went wrong, please try again", settings);
			}
		}
		else{
			Apprise("You need to select a deck in order to play", settings);
		}
	});

	$("form#new_server").submit(function(e){
		if($.trim($("select#deck").val()).length == 0 || $.trim($("input#server_name").val()).length == 0){
			e.preventDefault();
			Apprise("You need to name your server and pick a deck", settings);
		}
	});
});