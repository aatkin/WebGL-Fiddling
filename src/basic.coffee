gl = canvas =  mvMatrix = shaderProgram = perspectiveMatrix = null 
# squareVerticesBuffer = squareVerticesColorBuffer = null
vertexPositionAttribute = vertexColorAttribute = null
# cubeVerticesBuffer = cubeVerticesColorBuffer = cubeVerticesIndexBuffer = null 
triangleVerticesBuffer = triangleVerticesColorBuffer = triangleVerticesIndexBuffer = triangleVertexIndices = 
	triangleVertices = null 
cubeRotation = cubeXOffset = cubeYOffset = cubeZOffset = lastCubeUpdateTime = 0 
xIncValue = 0.2 
yIncValue = -0.4 
zIncValue = 0 
horizAspect = 640.0/480.0 
mvMatrixStack = []
moveSpeed = 1

stats = null

$(document).ready( ->
	initStats()
	start()
)

start = ->
	canvas = $('canvas.glcanvas')[0]
	canvas.appendChild(stats.domElement)
	$('#stats').appendTo('#container')

	initWebGL(canvas)

	if gl
		gl.clearColor(1.0, 1.0, 1.0, 1.0)
		gl.clearDepth(1.0)
		gl.enable gl.DEPTH_TEST
		gl.depthFunc gl.LEQUAL

		initShaders()
		initBuffers()
		drawScene()

		setInterval( ->
			stats.begin()
			drawScene()
			stats.end()
		, 1000 / 60)

initWebGL = (canvas) ->
	gl = null

	try 
		gl = canvas.getContext('experimental-webgl')
	catch error 
		console.log error

	if !gl
		alert 'Unable to initialize WebGL. Your browser may not support it.'

initShaders = () ->
	vertexShader = getShader(gl, 'shader-vs')
	fragmentShader = getShader(gl, 'shader-fs')

	shaderProgram = gl.createProgram()
	gl.attachShader(shaderProgram, vertexShader)
	gl.attachShader(shaderProgram, fragmentShader)
	gl.linkProgram(shaderProgram)

	if !gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)
		alert 'Unable to initialize the shader program.'

	gl.useProgram(shaderProgram)

	vertexPositionAttribute = gl.getAttribLocation(shaderProgram, 'aVertexPosition')
	gl.enableVertexAttribArray(vertexPositionAttribute)

	# vertexColorAttribute = gl.getAttribLocation(shaderProgram, 'aVertexColor')
	# gl.enableVertexAttribArray(vertexColorAttribute)

initBuffers = ->
	# cubeVerticesBuffer = gl.createBuffer()
	# gl.bindBuffer(gl.ARRAY_BUFFER, cubeVerticesBuffer)
	triangleVerticesBuffer = gl.createBuffer()
	gl.bindBuffer(gl.ARRAY_BUFFER, triangleVerticesBuffer)

	# vertices = [
	# 	# Front face
	#     -1.0, -1.0,  1.0,
	#      1.0, -1.0,  1.0,
	#      1.0,  1.0,  1.0,
	#     -1.0,  1.0,  1.0,
	    
	#     # Back face
	#     -1.0, -1.0, -1.0,
	#     -1.0,  1.0, -1.0,
	#      1.0,  1.0, -1.0,
	#      1.0, -1.0, -1.0,
	    
	#     # Top face
	#     -1.0,  1.0, -1.0,
	#     -1.0,  1.0,  1.0,
	#      1.0,  1.0,  1.0,
	#      1.0,  1.0, -1.0,
	    
	#     # Bottom face
	#     -1.0, -1.0, -1.0,
	#      1.0, -1.0, -1.0,
	#      1.0, -1.0,  1.0,
	#     -1.0, -1.0,  1.0,
	    
	#     # Right face
	#      1.0, -1.0, -1.0,
	#      1.0,  1.0, -1.0,
	#      1.0,  1.0,  1.0,
	#      1.0, -1.0,  1.0,
	    
	#     # Left face
	#     -1.0, -1.0, -1.0,
	#     -1.0, -1.0,  1.0,
	#     -1.0,  1.0,  1.0,
	#     -1.0,  1.0, -1.0
	# ]

	# triangle vertices
	triangleVertices = [
		# Front face
		-1.0, -1.0, 1.0,
		1.0, -1.0, 1.0,
		0.0, 1.0, 0.0,

		# Back face
		-1.0, -1.0, -1.0,
		0.0, 1.0, 0.0,
		1.0, -1.0, -1.0,

		# Bottom face
		-1.0, -1.0, -1.0,
		1.0, -1.0, -1.0,
		1.0, -1.0, 1.0,
		-1.0, -1.0, 1.0,

		# Right face
		1.0, -1.0, -1.0,
		0.0, 1.0, 0.0,
		1.0, -1.0, 1.0,

		# Left face
		-1.0, -1.0, -1.0,
		-1.0, -1.0, 1.0,
		0.0, 1.0, 0.0
	]

	gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(triangleVertices), gl.STATIC_DRAW)

	# colors = [
	# 	1.0, 1.0, 1.0, 1.0,
	# 	1.0, 0.0, 0.0, 1.0,
	# 	0.0, 1.0, 0.0, 1.0,
	# 	0.0, 0.0, 1.0, 1.0
	# ]

	# front, back, top, bottom, right, left
	# colors = [
	# 	[1.0,  0.0,  0.0,  1.0], 
	#     [0.9,  0.0,  0.0,  1.0],
	#     [0.8,  0.0,  0.0,  1.0],
	#     [0.7,  0.0,  0.0,  1.0],
	#     [0.6,  0.0,  0.0,  1.0],
	#     [0.5,  0.0,  0.0,  1.0] 
	# ]

	# front, back, bottom, right, left
	colors = [
		[1.0,  0.0,  0.0,  1.0], 
	    [0.9,  0.0,  0.0,  1.0],
	    [0.7,  0.0,  0.0,  1.0],
	    [0.6,  0.0,  0.0,  1.0],
	    [0.5,  0.0,  0.0,  1.0] 
	]

	generatedColors = []

	for row in [0..4] by 1
		side = colors[row]
		for index in [0..3] by 1
			generatedColors = generatedColors.concat side

	# cubeVerticesColorBuffer = gl.createBuffer()
	# triangleVerticesColorBuffer = gl.createBuffer()
	# gl.bindBuffer(gl.ARRAY_BUFFER, triangleVerticesColorBuffer)
	# gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(generatedColors), 
	#	gl.STATIC_DRAW)

	# cubeVerticesIndexBuffer = gl.createBuffer()
	triangleVerticesIndexBuffer = gl.createBuffer()
	gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, triangleVerticesIndexBuffer)

	# cubeVertexIndices = [
	# 	0,  1,  2,      0,  2,  3,
	#     4,  5,  6,      4,  6,  7,
	#     8,  9,  10,     8,  10, 11,
	#     12, 13, 14,     12, 14, 15,
	#     16, 17, 18,     16, 18, 19,
	#     20, 21, 22,     20, 22, 23
	# ]
	triangleVertexIndices = [
		0, 1, 2,
		3, 4, 5,
		6, 7, 8,	6, 8, 9,
		10, 11, 12,
		13, 14, 15
	]

	gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(triangleVertexIndices), gl.STATIC_DRAW)

drawScene = ->
	gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
	perspectiveMatrix = makePerspective(45, 640.0/480.0, 0.1, 100.0)

	loadIdentity()

	moveSpeed += 0.0125
	vecX = 3.0 * Math.cos(moveSpeed)
	vecY = 1.5 * Math.sin(moveSpeed)

	mvTranslate([vecX, vecY, -10.0])

	mvPushMatrix()
	mvRotate(cubeRotation, [1, 1, 0])
	# mvTranslate([cubeXOffset, cubeYOffset, cubeZOffset])

	gl.bindBuffer(gl.ARRAY_BUFFER, triangleVerticesBuffer)
	gl.vertexAttribPointer(vertexPositionAttribute, 3, gl.FLOAT, false, 0, 0)

	# gl.bindBuffer(gl.ARRAY_BUFFER, triangleVerticesColorBuffer)
	# gl.vertexAttribPointer(vertexColorAttribute, 4, gl.FLOAT, false, 0, 0)

	gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, triangleVerticesIndexBuffer)
	setMatrixUniforms()
	# gl.drawElements(gl.TRIANGLES, 18, gl.UNSIGNED_SHORT, 0)
	gl.drawElements(gl.LINE_STRIP, 18, gl.UNSIGNED_SHORT, 0)

	mvPopMatrix()

	currentTime = (new Date).getTime()

	if lastCubeUpdateTime
		delta = currentTime - lastCubeUpdateTime

		cubeRotation += (30 * delta) / 1000.0
		# cubeXOffset += xIncValue * ((30 * delta) / 1000.0)
		# cubeYOffset += yIncValue * ((30 * delta) / 1000.0)
		# cubeZOffset += zIncValue * ((30 * delta) / 1000.0)

		# if Math.abs(cubeYOffset) > 2.5
		# 	xIncValue = -xIncValue
		# 	yIncValue = -yIncValue
		# 	zIncValue = -zIncValue

	lastCubeUpdateTime = currentTime

# Auxiliary functions

initStats = ->
	stats = new Stats()
	stats.setMode(0)

	stats.domElement.style.position = 'absolute'
	stats.domElement.style.left = '0px'
	stats.domElement.style.zIndex = 100

getShader = (gl, id) ->
	theSource = currentChild = shader = null
	shaderScript = document.getElementById(id)

	if !shaderScript then return null

	theSource = ''
	currentChild = shaderScript.firstChild

	while currentChild
		if currentChild.nodeType == 3
			theSource += currentChild.textContent
		currentChild = currentChild.nextSibling

	if shaderScript.type == 'x-shader/x-fragment'
		shader = gl.createShader(gl.FRAGMENT_SHADER)
	else if shaderScript.type == 'x-shader/x-vertex'
		shader = gl.createShader(gl.VERTEX_SHADER)
	else
		return null

	gl.shaderSource(shader, theSource)
	gl.compileShader(shader)

	if !gl.getShaderParameter(shader, gl.COMPILE_STATUS)
		alert 'An error occurred compiling the shaders: ', gl.getShaderInfoLog(shader)

	return shader

loadIdentity = ->
	mvMatrix = Matrix.I(4)

multMatrix = (m) ->
	mvMatrix = mvMatrix.x(m)

mvTranslate = (v) ->
	multMatrix(Matrix.Translation($V([v[0], v[1], v[2]])).ensure4x4())

setMatrixUniforms = ->
	pUniform = gl.getUniformLocation(shaderProgram, 'uPMatrix')
	gl.uniformMatrix4fv(pUniform, false, new Float32Array(perspectiveMatrix.flatten()))

	mvUniform = gl.getUniformLocation(shaderProgram, 'uMVMatrix')
	gl.uniformMatrix4fv(mvUniform, false, new Float32Array(mvMatrix.flatten()))

mvPushMatrix = (m) ->
	if m
		mvMatrixStack.push m.dup()
		mvMatrix = m.dup()
	else
		mvMatrixStack.push mvMatrix.dup()

mvPopMatrix = ->
	if !mvMatrixStack.length
		throw 'Cant pop from an empty matrix stack.'
	mvMatrix = mvMatrixStack.pop()
	return mvMatrix

mvRotate = (angle, v) ->
	inRadians = angle * (Math.PI / 180.0)

	m = Matrix.Rotation(inRadians, $V([v[0], v[1], v[2]])).ensure4x4()
	multMatrix(m)