gl = canvas = squareVerticesBuffer = squareVerticesColorBuffer = mvMatrix = shaderProgram = vertexPositionAttribute = vertexColorAttribute = perspectiveMatrix = null
horizAspect = 600.0/800.0

$(document).ready( ->
	start()
)

start = ->
	canvas = $('canvas.glcanvas')[0]

	initWebGL(canvas)

	if gl
		gl.clearColor(0.0, 0.0, 0.0, 1.0)
		gl.clearDepth(1.0)
		gl.enable gl.DEPTH_TEST
		gl.depthFunc gl.LEQUAL

		initShaders()
		initBuffers()
		drawScene()
		# setInterval(drawScene, 15)

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

	vertexColorAttribute = gl.getAttribLocation(shaderProgram, 'aVertexColor')
	gl.enableVertexAttribArray(vertexColorAttribute)

initBuffers = ->
	squareVerticesBuffer = gl.createBuffer()
	gl.bindBuffer(gl.ARRAY_BUFFER, squareVerticesBuffer)

	vertices = [
		1.0, 1.0, 0.0,
		-1.0, 1.0, 0.0,
		1.0, -1.0, 0.0,
		-1.0, -1.0, 0.0
	]

	gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW)

	colors = [
		1.0, 1.0, 1.0, 1.0,
		1.0, 0.0, 0.0, 1.0,
		0.0, 1.0, 0.0, 1.0,
		0.0, 0.0, 1.0, 1.0
	]

	squareVerticesColorBuffer = gl.createBuffer()
	gl.bindBuffer(gl.ARRAY_BUFFER, squareVerticesColorBuffer)
	gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(colors), gl.STATIC_DRAW)

drawScene = ->
	gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
	perspectiveMatrix = makePerspective(45, 800.0/600.0, 0.1, 100.0)

	loadIdentity()
	mvTranslate([-0.0, 0.0, -6.0])

	gl.bindBuffer(gl.ARRAY_BUFFER, squareVerticesBuffer)
	gl.vertexAttribPointer(vertexPositionAttribute, 3, gl.FLOAT, false, 0, 0)

	gl.bindBuffer(gl.ARRAY_BUFFER, squareVerticesColorBuffer)
	gl.vertexAttribPointer(vertexColorAttribute, 4, gl.FLOAT, false, 0, 0)

	setMatrixUniforms()
	gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)

# Auxiliary functions

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