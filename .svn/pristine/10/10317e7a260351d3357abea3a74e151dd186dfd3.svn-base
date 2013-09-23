$(document).ready(function(){
	var selected = new Array();
	var hq = $("ul#selected-hq li").data("cid");
	var id = $("#deck_id").val();

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

	$("ul#selected li").each(function(index) {
		selected.push($(this).data("cid"));
	});

	$("#selected-cards span").empty();
	$("#selected-cards span").append(selected.length + "/39");

	$("ul#available li").click(function(){
		var cid = $(this).data("cid");

		var occ = $.grep(selected, function (elem) {
		    return elem === cid;
		}).length;

		if(occ < 4){
			$(this).clone().appendTo("ul#selected");
			selected.push(cid);
			$("#selected-cards span").empty();
			$("#selected-cards span").append(selected.length + "/39");
		}
		else{
			Apprise("You can have a maximum of 4 of the same card in your deck", settings);
		}
	});

	$("ul#selected").delegate("li", "click", function(){
		selected.splice($.inArray($(this).data("cid"), selected), 1);
		$(this).remove();

		$("#selected-cards span").empty();
		$("#selected-cards span").append(selected.length + "/39");
	});

	$("ul#headquarters li").click(function(){
		if(hq != null){
			$("ul#selected-hq").empty();
		}

		$(this).clone().appendTo("ul#selected-hq");
		hq = $(this).data("cid");
	});

	$("ul#selected-hq").delegate("li", "click", function(){
		hq = null;
		$(this).remove();
	});

	$("button#save").click(function(){
		if($("#deck_name").val().trim() == ""){
			Apprise("Please fill in a name for you deck.", settings);
		}
		else{
			if((selected.length != 39) || (hq == null)){
				Apprise("You need to pick a total of 39 cards, the 40th is your headquarters", settings);
			}
			else{
				$("button#save").attr("disabled", "disabled");
				
				var user = $("h2#deck-creator").data("user");

				var url;
				var method = "POST";

				if(user == "n"){					
					if(id != null){
						console.log("3");
						method = "PUT";
						url = "/admin/decks/" + id;
					}
					else{
						url = "/admin/decks";
					}
				}
				else{
					if(id != null){
						console.log("4");
						method = "PUT";
						url = "/user/decks/" + id;
					}
					else{
						url = "/user/decks";
					}					
				}

				$.ajax({
					type: method,
					url: url,
					data: {"name": $("#deck_name").val().trim(), "hq": hq, "selected": JSON.stringify(selected)},
					success:function(response){
						if(response.result){
							if(response.valid){
								window.location = response.valid;
							}
							else{
								window.location = "/user/decks";
							}
						}
						else{
							$("button#save").removeAttr("disabled");
							alert("The deck was not saved, try again in a while.");
						}
					}
				});
			}
		}
	});
});