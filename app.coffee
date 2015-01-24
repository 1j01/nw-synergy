
$screens = $("<div class='screens'/>").appendTo("body")
$screens.css
	position: "relative"

scale = 1/10
screen_position_scale = scale * 1.04 # space the screens out a little

zIndexCounter = 0

$Screen = (@screen, center)->
	$screen = $("<div class='screen'/>").appendTo($screens)
	$work_area = $("<div class='work-area'/>").appendTo($screen)
	$dimensions = $("<div class='dimensions'/>").appendTo($screen)
	
	{bounds, work_area} = @screen
	
	$screen.css
		position: "absolute"
		left: bounds.x * screen_position_scale
		top: bounds.y * screen_position_scale
		width: bounds.width * scale
		height: bounds.height * scale
		cursor: "move"
	
	$work_area.css
		position: "absolute"
		left: (work_area.x - bounds.x) * scale
		top: (work_area.y - bounds.y) * scale
		width: work_area.width * scale
		height: work_area.height * scale
		pointerEvents: "none"
	
	$dimensions.css
		#fontSize: "1.3em"
		fontWeight: "300"
		textAlign: "center"
		height: "1em"
		lineHeight: "1"
		margin: "auto"
		position: "absolute"
		top: 0
		left: 0
		bottom: 0
		right: 0
		pointerEvents: "none"
	.text "#{@screen.bounds.width} × #{@screen.bounds.height}"
	
	ox = oy = 0
	$screen.on "mousedown touchstart", (e)->
		$screen.css zIndex: ++zIndexCounter
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
{Screen} = require 'nw.gui'
console.log Screen
console.log Screen.screens
center = {}
for screen in Screen.screens
	scx = screen.bounds.x + screen.bounds.width / 2
	scy = screen.bounds.y + screen.bounds.height / 2
	center.x = ((center.x ? scx) + scx) / (Screen.screens.length)
	center.y = ((center.y ? scy) + scy) / (Screen.screens.length)

console.log center
$screens.css
	left: (window.innerWidth - center.x) / 2
	top: (window.innerHeight - center.y) / 2 + 50

for screen in Screen.screens
	new $Screen(screen, center)
