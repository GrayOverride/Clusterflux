$(document).ready(function(){
  var faction = $("#game-title").data("faction");
  var mp3 = "";
  var oga = "";

  if(faction){
    switch(faction){
      case "Human":
        mp3 = "/assets/music/Drifting.mp3";
        oga = "/assets/music/Drifting.ogg";
      break;
      case "Mutant":
        mp3 = "/assets/music/FCUKOutcast3Mutants.mp3";
        oga = "/assets/music/FCUKOutcast3Mutants.ogg";
      break;
      case "Alien":
        mp3 = "/assets/music/DeVeeDeeeAliens.mp3";
        oga = "/assets/music/DeVeeDeeeAliens.ogg";
      break;
      case "Robot":
        mp3 = "/assets/music/Reason_To_Live_Robot.mp3";
        oga = "/assets/music/Reason_To_Live_Robot.ogg";
      break;
      default:
        mp3 = "/assets/music/Twiceafool.mp3";
        oga = "/assets/music/Twiceafool.ogg";
    }
  }

  $("#jquery_jplayer_1").jPlayer({
    solution: "html",
    supplied: "mp3, oga",
    volume: 0.1,
    loop: true,
    errorAlerts: false,
    warningAlerts: false,
    ready: function(){
      $(this).jPlayer("setMedia", {
        mp3: mp3,
        oga: oga
      });
    },
    loadstart: function() {
      $('#jquery_jplayer_1').jPlayer("play");
    }
  });
});
