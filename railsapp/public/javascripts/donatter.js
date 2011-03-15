// Set URL of your WebSocketMain.swf here:
WEB_SOCKET_SWF_LOCATION = "WebSocketMain.swf";
// Set this to dump debug message from Flash to console.log:
WEB_SOCKET_DEBUG = true;

		var ws;

$(document).ready(function(){

    // Element event handlers
    $("#open-whats-this").colorbox({width:"50%", inline:true, href:"#whats-this"});
    $("#open-help-translate").colorbox({width:"50%", inline:true, href:"#help-translate"});

    var update_paused = false;
    var connection_lost = false;
    
    $("#tweets").bind("mouseover", function(){
      if (!connection_lost){
        $("#ws-status").find("img").attr("src", "images/bullet_white.png");
        $("#ws-status").find("span").text(messages["paused"]);
        $("#content").css("background-color", "#CCCCCC");
        update_paused = true;
      }
    });

    $("#tweets").bind("mouseout", function(){
      if (!connection_lost){
        $("#ws-status").find("img").attr("src", "images/bullet_blue.png");
        $("#ws-status").find("span").text(messages["realtime"]);
        $("#content").css("background-color", "#F9F9F9");
        update_paused = false;
      }
    });

    // Web socket
    var show_count = 10;

    var tweet_html_template = '';
    tweet_html_template+= '<div class="tweet">';
    tweet_html_template+= '  <div class="profile_image"><a href="http://twitter.com/%screen_name%"><img src="%profile_image_url%" alt="%screen_name%" width="46" height="46"/></a></div>';
    tweet_html_template+= '  <div class="screen_name"><a href="http://twitter.com/%screen_name%">%screen_name%</a></div>';
    tweet_html_template+= '  <div class="text">%text%</div>';
    tweet_html_template+= '  <div class="clear"></div>';
    tweet_html_template+= '</div>';

    // Connect to Web Socket.
    // Change host/port here to your own Web Socket server.
    ws = new WebSocket("ws://paduntu:10081/");

    ws.onmessage = function(e) {
      if (!update_paused){
        var data = $.parseJSON(e.data);
        console.log(data);
        add_tweet(data.tweet);
        purge_tweets();
      }
    };

    ws.onopen = function() {
      console.log("onopen");
    };

    ws.onclose = function() {
      console.log("onclose");
      on_close();
    };

    ws.onerror = function() {
      console.log("onerror");
      on_close();
    };

    var on_close = function(){
      $("#ws-status").find("img").attr("src", "images/bullet_error.png");
      $("#ws-status").find("span").text(messages["wserror"]);
      $("#content").css("background-color", "#CCCCCC");
      update_paused = true;
      connection_lost = true;
    }


    // Tweet display
    var add_tweet = function(tweet) {
      var html = tweet_html_template;
      html = html.replace(/%profile_image_url%/g, tweet.profile_image_url);
      html = html.replace(/%screen_name%/g, tweet.screen_name);
      html = html.replace(/%text%/g, tweet.text);
      var elem = $(html).css("display", "none");
      $("#tweets").prepend(elem);
      elem.show("blind", {}, "slow");
    }

    var purge_tweets = function() {
      while ((children = $("#tweets").children()).length > show_count) {
        children.last().remove();
      }
    }

});

