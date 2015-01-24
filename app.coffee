
$screens = $("<div class='screens'/>").appendTo("body")
$screens.css
	position: "relative"

$Screen = (@screen)->
	$screen = $("<div class='screen'/>").appendTo($screens)
	
	$screen.css
		position: "absolute"
		left: @screen.bounds.x/9.5
		top: @screen.bounds.y/9.5
		width: @screen.bounds.width/10
		height: @screen.bounds.height/10
		cursor: "move"
	
	ox = oy = 0
	$screen.on "mousedown touchstart", (e)->
		ox = e.clientX - $screen.position().left
		oy = e.clientY - $screen.position().top
		
		$(window).on "mousemove touchmove", move = (e)->
			x = e.clientX - ox
			y = e.clientY - oy
			$screen.css
				position: "absolute"
				left: x
				top: y
				cursor: "-webkit-dragging"
		
		# @TODO touchcancel: cancel
		$(window).on "mouseup touchend touchcancel", stop = (e)->
			$(window).off "mousemove touchmove", move
			$(window).off "mouseup touchend touchcancel", stop
			x = e.clientX - ox
			y = e.clientY - oy
			$screen.css
				position: "absolute"
				left: x
				top: y
				cursor: "-webkit-drag"
	
	$screen

###
new $Screen 1920, 1080
new $Screen 1920, 1080
new $Screen 1366, 768
###

{Screen} = require 'nw.gui'
Screen.Init()
console.log Screen
#for screen in Screen.screens
#	new $Screen(screen)
