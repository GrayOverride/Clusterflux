function Chat(key){
	this.key = key;

	//appends message to chat
	this.logger = function(sender, content){
		$("#chat").append("<p>" + sender + ": " + content + "</p>");
		$('#chat').change();
		$('#chat').animate({ scrollTop: $('#chat').prop("scrollHeight") - $('#chat').height() }, 1000);
	}

	//sends message
	$(function(){
	  $("#chat-send").click(function(){  
	    var dataString = 'key=' + key + '&content=' + $("input#message").val();
	    $("input#message").val("");

	    $.ajax({  
		  type: "POST",  
		  url: "chat",  
		  data: dataString,
		  async: false
		});

		return false; 
	  });  
	});
}