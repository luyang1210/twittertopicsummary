{% extends "base.tpl" %}

{% block content %}
<img src="/static/img/logo.png">
<div>
<input type="text" name="query" value="dogs" id="query"/><input type="button" name="search" value="Search" id="search">
</div>


<div id='main'>

  <div id='resultswrapper'>
    <div id='resultscontent'><h2>results</h2>
      <div id='resultsbytheme'></div>
    </div>
  </div>
  <div id='themelistcontainer'><h2>themes</h2>
    <ul id="themelist-col0"></ul>
    <ul id="themelist-col1"></ul>
    
    
  </div>  
</div>
<script type="text/javascript" charset="utf-8">
  function labelHtml(label) {
    return htmlQuote(label).replace(/ /g,"&nbsp;");
  }
  function htmlQuote(s) {
    return s.replace(/"/g, "&quot;").replace(/>/g, "&gt;").replace(/</g,
    "&lt;");  //"
  }
  function pluralize(s,n, /*optional*/ suffix) {
    if (n == 1) return s;
    if (suffix==undefined)  suffix = "s"
    return s + suffix;
  }
  twitterThemes = new function(){
    this.blocksToEnqueue = 3;
    this.data = {};
    this.tweetsPerResult = 4;
    this.currentlyEnqueued = [];
    
    this.clearThemeList = function() {
      $("#themelist-col0").html("");
      $("#themelist-col1").html("");
    }
    this.displayThemeList = function(){
      this.clearThemeList();
      for (var i = 0; i < this.themeList.length; i++) {
        var curTheme = this.themeList[i];
        var whichCol = i % 2;
        $('<li><a href="#" theme="' + htmlQuote(curTheme) + '"' +  
            'onclick="twitterThemes.enqueueTheme($(this).attr(\'theme\')); return false">' + 
            labelHtml(curTheme) + '</a></li>').appendTo("#themelist-col" + whichCol);
      }
    }
    
    this.showMoreFor = function(id) {
      $(".extratweets", "#tweetresult-" + id).slideDown("normal");
      $(".slidedownlink", "#tweetresult-" + id).hide();
    }
    
    this.enqueueTheme = function (theme){
      var currentPosition = -1;
      for (var i = 0; i < this.currentlyEnqueued.length; i++) {
        if (this.currentlyEnqueued[i] == theme) {
          currentPosition = i;
        }
      }
      if (currentPosition != -1 && currentPosition != 0) {
        // console.log($("#resultscontent").contents()[currentPosition]);
        var elem = $("#resultsbytheme").contents()[currentPosition];
        $(elem).remove();
        this.currentlyEnqueued.splice(currentPosition, 1);
        
      } else if (currentPosition == 0) {
        return;
      }
      this.currentlyEnqueued.unshift(theme);
      var themeData = this.data[theme];
      var tweetList = $("<div class='theme'><h3>&ldquo;" + theme + "&rdquo;</h3></div>");
      for (var i = 0; i < themeData.groups.length; i++) {
        var group = themeData.groups[i];
        var thisTweet = $("<div class='tweet'>" + group.head_html + "</div>").appendTo(tweetList);
        if (group.rest_htmls.length > 0) {
          var n = group.rest_htmls.length
          var t = pluralize("tweet", n)
          // todo clicky
          thisTweet = $("<div class='rest_tweets'>" + n + " similar " + t + "...</div>").appendTo(tweetList);
        }
        if (i > this.tweetsPerResult) {
          thisTweet.addClass("extratweets");
        }
      }
      tweetList.hide();
      var safeThemeName = theme.replace(/ /g, "_");
      tweetList.attr("id", "tweetresult-" + (safeThemeName));
      tweetList.append('<div><a class="slidedownlink" href="#" onclick="twitterThemes.showMoreFor(\'' + safeThemeName +'\'); return false">See more</a></div>');
      $("#resultsbytheme").prepend(tweetList);
      tweetList.slideDown("normal");
      if ($("#resultsbytheme").contents().length > this.blocksToEnqueue) {
        $($("#resultsbytheme").contents()[this.blocksToEnqueue]).slideUp();
      }
    }
  }

    // // twitterThemes.enqueueTheme("foo");
    // // twitterThemes.enqueueTheme("bar");
    // 
    // window.setTimeout(function(){
    //   twitterThemes.enqueueTheme("foo");      
    //   window.setTimeout(function(){
    //     twitterThemes.enqueueTheme("bar");
    //     window.setTimeout(function(){
    //       twitterThemes.enqueueTheme("baz");      
    //       window.setTimeout(function(){
    //         twitterThemes.enqueueTheme("foo");      
    //       }, 2000);            
    // 
    //     }, 2000);            
    //   }, 2000);    
    //   
    // }, 2000);
    
    
    $(document).ready(function() {
      $("#search").click(function(){
        $.getJSON('/do_query',{
         q: $("#query").val()},
         function(result){
          $("#themelist").empty();
          $("#resultsbytheme").empty();
            twitterThemes.themeList = result.topic_list;
          twitterThemes.data = result.topic_info;
          twitterThemes.displayThemeList();
          for (var i = 2; i >= 0; i--) {
            twitterThemes.enqueueTheme(twitterThemes.themeList[i])
          }
        });
        
      })
      
    });

</script>

{% endblock %}
