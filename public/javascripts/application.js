// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function(){
	$('div#broadcast').anythingSlider({
		easing: "swing",                // Anything other than "linear" or "swing" requires the easing plugin
		autoPlay: true,                 // This turns off the entire FUNCTIONALY, not just if it starts running or not
		startStopped: false,            // If autoPlay is on, this can force it to start stopped
		delay: 6000,                    // How long between slide transitions in AutoPlay mode
		animationTime: 1000,             // How long the slide transition takes
		hashTags: false,                 // Should links change the hashtag in the URL?
		buildNavigation: true,          // If true, builds and list of anchor links to link to each slide
		pauseOnHover: false,             // If true, and autoPlay is enabled, the show will pause on hover
		startText: "Start",             // Start text
		stopText: "Stop",               // Stop text
		navigationFormatter: null       // Details at the top of the file on this use (advanced use)
	});
	

	//When page loads...
	$(".tab_content").hide(); //Hide all content
	$("ul.tabs li:first").addClass("active").show(); //Activate first tab
	$(".tab_content:first").show(); //Show first tab content
  
	//On Click Event
	$("ul.tabs li").click(function() {
  
		$("ul.tabs li").removeClass("active"); //Remove any "active" class
		$(this).addClass("active"); //Add "active" class to selected tab
		$(".tab_content").hide(); //Hide all tab content
  
		var activeTab = $(this).find("a").attr("href"); //Find the href attribute value to identify the active tab + content
		$(activeTab).fadeIn(); //Fade in the active ID content
		return false;
	});

	
})