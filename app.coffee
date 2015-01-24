
$screens = $("<div class='screens'/>").appendTo("body")
$screens.css position: "relative", width: 0, height: 0

scale = 1/7

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
		width: ~~(bounds.width * scale)
		height: ~~(bounds.height * scale)
		cursor: "move"
	
	$work_area.css
		position: "absolute"
		left: (work_area.x - bounds.x) * scale
		top: (work_area.y - bounds.y) * scale
		width: ~~(work_area.width * scale)
		height: ~~(work_area.height * scale)
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
	
	$screen.draggable(snap: yes, snapTolerance: 5, opacity: 0.8, stack: ".screen")
	# @TODO: use -webkit-drag and -webkit-dragging cursors
	
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

unless require?
	add_screen = (width, height)->
		x = ~~(Math.random()*5000)
		y = ~~(Math.random()*5000)
		new $Screen
			bounds: {x, y, width, height}
			work_area: {x, y, width, height: height-40}

	add_screen 1366, 768
	add_screen 1024, 600
	add_screen 640, 480
	add_screen 480, 320


do window.onresize = ->
	center = {}
	for $screen in screens
		{screen} = $screen
		scx = screen.bounds.x + screen.bounds.width / 2
		scy = screen.bounds.y + screen.bounds.height / 2
		center.x = ((center.x ? scx) + scx) / (screens.length)
		center.y = ((center.y ? scy) + scy) / (screens.length)

	$screens.css
		left: ~~((window.innerWidth - center.x * scale) / 2)
		top: ~~((window.innerHeight - center.y * scale) / 2)

