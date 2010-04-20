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
})