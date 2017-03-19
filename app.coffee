
$.fn.rect = ->
	o = @offset()
	o.width = @width()
	o.height = @height()
	o.right = o.left + o.width
	o.bottom = o.top + o.height
	o
	# maybe these would be outerWidth/Height and/or offsetParent
	# for a more generally useful helper function

$screens = $("<div class='screens'/>").appendTo("body")
$screens.css position: "relative", width: 0, height: 0

scale = 1/7

screens = []

# system_colors = ["#3C97BA", "#156260", "#5D7DBE", "#ff0", "#f0f", "#f55"]
# system_colors = ["#5D7DBE", "#156260", "#ff0", "#f0f", "#f55"]
system_colors = ["#9AD9E9", "#B5E637", "#FE7E34", "#C8BFE6"]
# TODO: bikeshed on a color palette and/or use one of those unique color modules
system_colors_index = 0

class System
	constructor: ($screens)->
		@color = system_colors[system_colors_index++]
		@name = "Computer " + system_colors_index
		@$screens = []
		if $screens
			@add $screen for $screen in $screens
	add: ($screen)->
		@$screens.push($screen)
		$screen.find(".work-area").css(backgroundColor: @color, color: "rgba(0, 0, 0, 0.5)", padding: 5).text(@name)
		$screen.css(color: "black")
		$screen.system = @
	dragBy: ($handle_screen)->
		# FIXME: snaps to other screens of the same system
		# (at their original positions at the start of the drag)
		# TODO: actually have a position for the System in meta screen space
		# and update that and update the elements from that
		# (If this were in React I would have just done this the right way)
		# FIXME: pixel inaccuracy issues because it's done the wrong way
		handle_position = $handle_screen.position()
		for $screen in @$screens #when $screen isnt $handle_screen
			$screen.css(
				left: ~~(handle_position.left + ($screen.screen.bounds.x - $handle_screen.screen.bounds.x) * scale)
				top: ~~(handle_position.top + ($screen.screen.bounds.y - $handle_screen.screen.bounds.y) * scale)
			)

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
		cursor: "move" # @TODO: use -webkit-drag and -webkit-dragging cursors
	
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
	
	# TODO: take into account the whole System's shape when snapping
	$screen.draggable(snap: yes, snapTolerance: 5, opacity: 0.8, stack: ".screen")
	$screen.on "drag", ->
		update = ->
			$screen.system?.dragBy($screen)
			update_intersections()
		# HACK: draggable() might not have actually moved the elements yet, so try again in a bit
		# we need mousemove so that other screens don't lag behind the directly dragged screen
		$(window).one "mousemove", update
		# we need setTimeout for the end of the drag
		setTimeout update, 1
	
	screens.push $screen
	$screen.screen = screen
	$screen

$WindowOnScreen = (window, $screen)->
	$window = $("<div class='window'/>").appendTo($screen)
	
	{bounds, work_area} = $screen.screen
	
	update = ->
		nw_win = nwDispatcher?.nwGui?.Window?.get?(window)
		
		if nw_win
			{x, y, width, height} = nw_win
		else
			x = window.screenX
			y = window.screenY
			width = window.outerWidth
			height = window.outerHeight
		
		$window.css
			position: "absolute"
			left: (x - bounds.x) * scale
			top: (y - bounds.y) * scale
			width: ~~(width * scale)
			height: ~~(height * scale)
			pointerEvents: "none"

	setInterval update, 50
	
	$window

update_intersections = ->
	$(".overlap, .edge").remove()
	for $screen_a in screens
		for $screen_b in screens when $screen_b isnt $screen_a
			a = $screen_a.rect()
			b = $screen_b.rect()
			
			left = Math.max(a.left, b.left)
			right = Math.min(a.right, b.right)
			bottom = Math.min(a.bottom, b.bottom)
			top = Math.max(a.top, b.top)
			width = right - left
			height = bottom - top
			
			ox = parseFloat($screen_a.css("left")) - a.left
			oy = parseFloat($screen_a.css("top")) - a.top
			
			if width > 0 and height > 0
				$("<div class='overlap'>").appendTo($screens).css
					position: "absolute"
					left: left + ox
					top: top + oy
					width: width
					height: height
					zIndex: 50000
					pointerEvents: "none"
			
			edge = ($screen_a, a, a_side, $screen_b, b, b_side)->
				inset = 1 # shrink the edge lengthwise for display
				# to make styling easier when shadows extend from the element
				# since it looks bad when it goes beyond the edge lengthwise
				is_vertical_edge = a_side in ["left", "right"]
				is_horizontal_edge = a_side in ["top", "bottom"]
				$("<div class='edge'>").appendTo($screens).css
					position: "absolute"
					left: left + ox + (inset * is_horizontal_edge)
					top: top + oy + (inset * is_vertical_edge)
					width: width - (inset * 2 * is_horizontal_edge)
					height: height - (inset * 2 * is_vertical_edge)
					zIndex: 50001
					pointerEvents: "none"
			
			touching = (x1, x2)->
				# x1 = x2, give or take a pixel
				Math.abs(x1 - x2) <= 1 and
				# ONE of the bounds of the intersection has some length
				(width > 1 or height > 1)
				# the intersection can have no area, that's fine for an edge
			
			edge $screen_a, a, "left", $screen_b, b, "right" if touching a.left, b.right
			edge $screen_a, a, "right", $screen_b, b, "left" if touching a.right, b.left
			edge $screen_a, a, "top", $screen_b, b, "bottom" if touching a.top, b.bottom
			edge $screen_a, a, "bottom", $screen_b, b, "top" if touching a.bottom, b.top


demo_mode = on # not `not require?` for now

if require?

	{Screen} = require 'nw.gui'; Screen.Init()
	{Screen} = require 'nw.gui'# (This is stupid)

	system = new System()
	for screen in Screen.screens
		system.add(new $Screen(screen))

else if (s = window.screen)?
	system = new System()
	system.add new $Screen
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

for $screen in screens
	new $WindowOnScreen(window, $screen)

if demo_mode
	new_screen = (width, height, x, y)->
		x ?= ~~(Math.random()*5000)
		y ?= ~~(Math.random()*-1000)
		new $Screen
			bounds: {x, y, width, height}
			work_area: {x, y, width, height: height-40}
	
	# new_screen 1366, 768
	# new_screen 1024, 600
	# new_screen 640, 480
	# new_screen 480, 320
	
	# XXX: I'm defining the positions of screens in these systems so that they don't overlap
	# which won't work in a real-world scenario
	# did I mention this is done the wrong way?
	new System [
		new_screen(1024, 600, 0, -600)
		# new_screen(640, 480, 1024, -480)
		# new_screen(480, 320, 1024+640, -768)
		new_screen(1920, 1080, 1024, -1080)
	]
	new System [
		new_screen(1366, 768, 0, 0)
		# new_screen(1366, 768, 1366, 0)
	]
	new System [
		# new_screen(1366, 768, 0, 768)
		# new_screen(1366, 768, 1366, 768)
		new_screen(1366, 768, 1366, 0)
	]


update_intersections()

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

