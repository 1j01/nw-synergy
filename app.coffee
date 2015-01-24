
$screens = $("<div class='screens'/>").appendTo("body")
$screens.css position: "relative"

scale = 1/10

zIndexCounter = 0

screens = []

$Screen = (screen)->
	
	$screen = $("<div class='screen'/>").appendTo($screens)
	$work_area = $("<div class='work-area'/>").appendTo($screen)
	$dimensions = $("<div class='dimensions'/>").appendTo($screen)
	
	{bounds, work_area} = screen
	
	$screen.css
		position: "absolute"
		left: bounds.x * scale
		top: bounds.y * scale
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
		fontWeight: "300"
		height: "100%"
		position: "relative"
		display: "flex"
		alignItems: "center"
		justifyContent: "center"
		pointerEvents: "none"
	.text "#{screen.bounds.width} × #{screen.bounds.height}"
	
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
				left: x, top: y
				cursor: "-webkit-dragging"
		
		# @TODO: actually cancel on touchcancel
		$(window).on "mouseup touchend touchcancel", stop = (e)->
			$(window).off "mousemove touchmove", move
			$(window).off "mouseup touchend touchcancel", stop
			x = e.clientX - ox
			y = e.clientY - oy
			$screen.css
				position: "absolute"
				left: x, top: y
				cursor: "-webkit-drag"
	
	screens.push $screen
	$screen.screen = screen
	$screen

if require?

	{Screen} = require 'nw.gui'; Screen.Init()
	{Screen} = require 'nw.gui'# (This is stupid)

	for screen in Screen.screens
		new $Screen(screen)

else if (s = window.screen)?
	new $Screen
		bounds:
			x: s.availLeft
			y: s.availTop
			width: s.width
			height: s.height
		work_area:
			x: s.availLeft
			y: s.availTop
			width: s.availWidth
			height: s.availHeight
	
else
	
	new $Screen bounds: {x: 0, y: 0, width: 1920, height: 1080}, work_area: {x: 0, y: 0, width: 1920, height: 1040}
	new $Screen bounds: {x: 1920, y: 0, width: 1920, height: 1080}, work_area: {x: 1920, y: 0, width: 1920, height: 1040}
	new $Screen bounds: {x: (1920*2-1366)/2, y: 1080, width: 1366, height: 768}, work_area: {x: (1920*2-1366)/2, y: 1080, width: 1366, height: 768-40}


do window.onresize = ->
	center = {}
	for $screen in screens
		{screen} = $screen
		scx = screen.bounds.x + screen.bounds.width / 2
		scy = screen.bounds.y + screen.bounds.height / 2
		center.x = ((center.x ? scx) + scx) / (screens.length)
		center.y = ((center.y ? scy) + scy) / (screens.length)

	$screens.css
		left: "calc(50% - #{center.x * scale}px / 2)"
		top: "calc(50% - #{center.y * scale}px / 2)"

