# auto canvas resizing
cnv = document.getElementById 'canvas'
context = cnv.getContext '2d'
window.addEventListener 'resize', resizeCanvas, false    
resizeCanvas = () ->
        cnv.width = window.innerWidth
        cnv.height = window.innerHeight
        if canvas? 
        	canvas.height = window.innerHeight
        	canvas.width = window.innerWidth
resizeCanvas()

# canvas object for drawing
canvas = oCanvas.create
	canvas: "#canvas"

# keyboard handling
keys = []
canvas.bind "keydown keyup", () ->
	keys = canvas.keyboard.getKeysDown()
	if 32 in keys 
		canvas.mouse.cursor "move"
	else
		canvas.mouse.cursor "default"

# prototypes
edgeproto = canvas.display.line
	stroke: "7px #DDD"
	shadow: "0 0 5px #000"
	cap: "round"
	start: x: 0, y: 0
	end:   x: 0, y: 0

# edge extension and node moving handling
extending = false
moving = false
startNode = null
currentNode = null
extedge = canvas.display.line
	stroke: "7px #DDD"
	shadow: "0 0 5px #000"
	cap: "round"
	start: x: 0, y: 0
	end:   x: 0, y: 0

canvas.bind "mousemove", () ->
	if extending
		extedge.end = canvas.mouse
		canvas.draw.redraw()
	if moving
		currentNode.picture.x = canvas.mouse.x
		currentNode.picture.y = canvas.mouse.y
		for edge in currentNode.inedges
			edge.end = canvas.mouse
		for edge in currentNode.outedges
			edge.start = canvas.mouse
		canvas.draw.redraw()

canvas.bind "mouseup", () ->
	if extending
		if startNode isnt currentNode and startNode? and currentNode?
			startNode.connect(currentNode)
		extedge.remove()
		extending = false
	if moving
		moving = false

# moving around the world
travel = false
posx = posy = 0

canvas.bind "mousedown", () ->
	if 32 in keys
		travel = true
		posx = canvas.mouse.x
		posy = canvas.mouse.y
		for obj in canvas.children
			obj._prevx = obj.x
			obj._prevy = obj.y
canvas.bind "mousemove", () ->
	if travel
		for obj in canvas.children
			obj.x = obj._prevx - posx + canvas.mouse.x
			obj.y = obj._prevy - posy + canvas.mouse.y
		canvas.draw.redraw()

canvas.bind "mouseup", () ->
	if travel
		travel = false


# base class for all graph's nodes
class Node
	constructor: (@name, @x, @y) ->
		@inedges = []
		@outedges = []
		@picture = canvas.display.ellipse
			x: x
			y: y
			radius: 20
			fill: "#FFF"
			shadow: "0 0 10px #000"
			node: @
		@arc = canvas.display.arc
			x: 0, y: 0
			start: 0, end:360
			radius: 20
			shadow: "0 0 10px #000"
		@setcompletion("unstarted")
		@text = canvas.display.text
			x: 0
			y: 30
			origin:
				x: "center"
				y: "top"
			font: "bold 20px sans-serif"
			shadow: "0 0 5px #000"
			text: @name
			fill: "#0aa"
		canvas.addChild @picture
		@picture.addChild @text
		@picture.addChild @arc
		@initgui()
		@initbindings()
	connect: (node) ->
		edge = canvas.display.line
			stroke: "7px #DDD"
			shadow: "0 0 5px #000"
			cap: "round"
			start: @picture
			end: node.picture
		@outedges.push edge
		node.inedges.push edge
		edge.add()
		edge.zIndex = "back"
	initbindings: () ->		
		@picture.bind "mousedown", () ->
			if 32 not in keys and 16 not in keys
				moving = true
				currentNode = @node
			else if 16 in keys
				startNode = @node
				extedge.start = @
				extedge.end = @
				extedge.zIndex = "back"
				extedge.add()
				extending = true
		@picture.bind "mouseenter", () ->
			if not moving
				currentNode = @node
			@node.showgui()
		@picture.bind "mouseleave", () ->
			if extending
				currentNode = null
			@delay(500)
			@node.hidegui()
		@red.bind "click", () ->
			@node.setcompletion("unstarted")
		@green.bind "click", () ->
			@node.setcompletion("completed")
		@orange.bind "click", () ->
			@node.setcompletion("started")
	initgui: () ->
		@red = canvas.display.ellipse
			x: 10
			y: -20
			radius: 10
			fill: "rgb(255,0,0)"
			shadow: "0 0 5px #000"
			node: @
		@orange = canvas.display.ellipse
			x: 15
			y: -10
			radius: 10
			fill: "rgb(255,140,0)"
			shadow: "0 0 5px #000"
			node: @
		@green = canvas.display.ellipse
			x: 20
			y: 0
			radius: 10
			fill: "rgb(0,255,0)"
			shadow: "0 0 5px #000"
			node: @
	showgui: () ->
		@picture.addChild @red
		@picture.addChild @orange
		@picture.addChild @green
	hidegui: () ->
		@picture.removeChild(@red)
		@picture.removeChild(@orange)
		@picture.removeChild(@green)
	setcompletion: (s) ->
		switch s
			when "unstarted"
				@arc.stroke = "5px #F00"
			when "started"
				@arc.stroke = "5px rgb(255,140,0)"
			when "completed"
				@arc.stroke = "5px #0F0"
		canvas.draw.redraw()
				
			
		
	








canvas.bind "dblclick", () ->
	name = document.getElementById("intext").value
	new Node name, canvas.mouse.x, canvas.mouse.y



#node = new Node("jezus", null, 200, 200)
#node2 = node.addChild "janusz", 100, 100
#node2.addChild "oko", 200, 200