# Main variables for canvas and shaders
gl = canvas = shaderProgram = null 
horizAspect = 640.0/480.0 
stats = null
# Variables for shader attributes
vertexPositionAttribute = vertexColorAttribute = null
# pyramid vertex array object & buffer variables
triangleVerticesBuffer = triangleVerticesColorBuffer = triangleVerticesIndexBuffer = triangleVertexIndices = 
	triangleVertices = null 
# sphere vertex array object & buffer variables
sphereVertexPositionBuffer = sphereIndexBuffer = null
# animation variables
rotation = lastUpdateTime = 0 
xIncValue = 0.2 
yIncValue = -0.4 
zIncValue = 0 
moveSpeed = 1
# matrix variables for transformations and such
mvMatrix = perspectiveMatrix = null
mvMatrixStack = []


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

		# setInterval( ->
		# 	stats.begin()
		# 	drawScene()
		# 	stats.end()
		# , 1000 / 60)

initWebGL = (canvas) ->
	gl = null

	try 
		gl = canvas.getContext('webgl')
	catch error 
		console.log error

	if !gl
		console.log 'Unable to initialize WebGL. Your browser may not support it.'

initShaders = () ->
	vertexShader = getShader(gl, 'shader-vs')
	fragmentShader = getShader(gl, 'shader-fs')

	shaderProgram = gl.createProgram()
	gl.attachShader(shaderProgram, vertexShader)
	gl.attachShader(shaderProgram, fragmentShader)
	gl.linkProgram(shaderProgram)

	if !gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)
		console.log 'Unable to initialize the shader program.'

	gl.useProgram(shaderProgram)

	vertexPositionAttribute = gl.getAttribLocation(shaderProgram, 'aVertexPosition')
	gl.enableVertexAttribArray(vertexPositionAttribute)

	# vertexColorAttribute = gl.getAttribLocation(shaderProgram, 'aVertexColor')
	# gl.enableVertexAttribArray(vertexColorAttribute)

initBuffers = ->
	initSphereBuffers(30, 30, 1.5)

drawScene = ->
	window.requestAnimationFrame(drawScene, canvas)

	stats.begin()

	gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
	perspectiveMatrix = makePerspective(45, 640.0/480.0, 0.1, 100.0)

	loadIdentity()

	moveSpeed += 0.0145001
	mCos = Math.cos(moveSpeed)
	absmCos = Math.abs(mCos)
	mSin = Math.sin(moveSpeed)
	vecX = 2.5 * mCos
	vecY = 1.5 * mSin

	mvTranslate([vecX, vecY, -8.0])

	mvPushMatrix()
	mvRotate(rotation, [1, 1, 0])

	setColorUniform(0.0, 0.0, 0.0, 1.0)

	gl.bindBuffer(gl.ARRAY_BUFFER, sphereVertexPositionBuffer)
	gl.vertexAttribPointer(vertexPositionAttribute, sphereVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0)

	gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, sphereIndexBuffer)
	gl.drawElements(gl.LINE_STRIP, sphereIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0)

	# gl.bindBuffer(gl.ARRAY_BUFFER, triangleVerticesBuffer)
	# gl.vertexAttribPointer(vertexPositionAttribute, 3, gl.FLOAT, false, 0, 0)

	# gl.bindBuffer(gl.ARRAY_BUFFER, triangleVerticesColorBuffer)
	# gl.vertexAttribPointer(vertexColorAttribute, 4, gl.FLOAT, false, 0, 0)

	# gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, triangleVerticesIndexBuffer)
	
	# setColorUniform(0.0, 0.0, 0.0, 1.0)
	# gl.drawElements(gl.LINE_STRIP, 18, gl.UNSIGNED_SHORT, 0)
	# if absmCos < 0.01
	# 	setColorUniform(0.0, 0.0, 0.0, 0.0)
	# 	gl.drawElements(gl.TRIANGLES, 18, gl.UNSIGNED_SHORT, 0)
	# else
	# 	setColorUniform(absmCos, 0.0, 0.0, absmCos)
	# 	gl.drawElements(gl.TRIANGLES, 18, gl.UNSIGNED_SHORT, 0)

	
	setMatrixUniforms()
	
	mvPopMatrix()

	currentTime = (new Date).getTime()

	if lastUpdateTime
		delta = currentTime - lastUpdateTime
		rotation += (30 * delta) / 1000.0

	lastUpdateTime = currentTime

	stats.end()

initSphereBuffers = (latitudeBands, longitudeBands, radius) ->
	indexData = []
	vertexPositionData = []

	for latNumber in [0..latitudeBands] by 1
		console.log latNumber
		theta = latNumber * Math.PI / latitudeBands
		sinTheta = Math.sin(theta)
		cosTheta = Math.cos(theta)

		for longNumber in [0..longitudeBands] by 1
			phi = longNumber * 2 * Math.PI / longitudeBands
			sinPhi = Math.sin(phi)
			cosPhi = Math.cos(phi)

			x = cosPhi * sinTheta
			y = cosTheta
			z = sinPhi * sinTheta

			vertexPositionData.push(radius * x)
			vertexPositionData.push(radius * y)
			vertexPositionData.push(radius * z)

	for latNumber in [0..(latitudeBands - 1)] by 1
		for longNumber in [0..(longitudeBands - 1)] by 1
			first = (latNumber * (longitudeBands + 1)) + longNumber
			second = first + longitudeBands + 1

			indexData.push(first)
			indexData.push(second)
			indexData.push(first + 1)

			indexData.push(second)
			indexData.push(second + 1)
			indexData.push(first + 1)

	sphereVertexPositionBuffer = gl.createBuffer()
	gl.bindBuffer(gl.ARRAY_BUFFER, sphereVertexPositionBuffer)
	gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertexPositionData), gl.STATIC_DRAW)
	sphereVertexPositionBuffer.itemSize = 3
	sphereVertexPositionBuffer.numItems = vertexPositionData.length / 3

	sphereIndexBuffer = gl.createBuffer()
	gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, sphereIndexBuffer)
	gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(indexData), gl.STATIC_DRAW)
	sphereIndexBuffer.itemSize = 1
	sphereIndexBuffer.numItems = indexData.length

initPyramidBuffers = ->
	triangleVerticesBuffer = gl.createBuffer()
	gl.bindBuffer(gl.ARRAY_BUFFER, triangleVerticesBuffer)

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

	triangleVerticesIndexBuffer = gl.createBuffer()
	gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, triangleVerticesIndexBuffer)

	triangleVertexIndices = [
		0, 1, 2,
		3, 4, 5,
		6, 7, 8,	6, 8, 9,
		10, 11, 12,
		13, 14, 15
	]

	gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(triangleVertexIndices), gl.STATIC_DRAW)

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
		console.log 'An error occurred compiling the shaders: ', gl.getShaderInfoLog(shader)

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

setColorUniform = (factorR, factorG, factorB, factorA) ->
	fragColor = [(1.0 * factorR), (1.0 * factorG), (1.0 * factorB), (1.0 * factorA)]

	colorUniform = gl.getUniformLocation(shaderProgram, 'colorUniform')
	gl.uniform4fv(colorUniform, new Float32Array(fragColor))

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