// Generated by CoffeeScript 1.7.1
(function() {
  var canvas, cubeRotation, cubeXOffset, cubeYOffset, cubeZOffset, drawScene, getShader, gl, horizAspect, initBuffers, initShaders, initStats, initWebGL, lastCubeUpdateTime, loadIdentity, moveSpeed, multMatrix, mvMatrix, mvMatrixStack, mvPopMatrix, mvPushMatrix, mvRotate, mvTranslate, perspectiveMatrix, setColorUniform, setMatrixUniforms, shaderProgram, start, stats, triangleVertexIndices, triangleVertices, triangleVerticesBuffer, triangleVerticesColorBuffer, triangleVerticesIndexBuffer, vertexColorAttribute, vertexPositionAttribute, xIncValue, yIncValue, zIncValue;

  gl = canvas = mvMatrix = shaderProgram = perspectiveMatrix = null;

  vertexPositionAttribute = vertexColorAttribute = null;

  triangleVerticesBuffer = triangleVerticesColorBuffer = triangleVerticesIndexBuffer = triangleVertexIndices = triangleVertices = null;

  cubeRotation = cubeXOffset = cubeYOffset = cubeZOffset = lastCubeUpdateTime = 0;

  xIncValue = 0.2;

  yIncValue = -0.4;

  zIncValue = 0;

  horizAspect = 640.0 / 480.0;

  mvMatrixStack = [];

  moveSpeed = 1;

  stats = null;

  $(document).ready(function() {
    initStats();
    return start();
  });

  start = function() {
    canvas = $('canvas.glcanvas')[0];
    canvas.appendChild(stats.domElement);
    $('#stats').appendTo('#container');
    initWebGL(canvas);
    if (gl) {
      gl.clearColor(1.0, 1.0, 1.0, 1.0);
      gl.clearDepth(1.0);
      gl.enable(gl.DEPTH_TEST);
      gl.depthFunc(gl.LEQUAL);
      initShaders();
      initBuffers();
      drawScene();
      return setInterval(function() {
        stats.begin();
        drawScene();
        return stats.end();
      }, 1000 / 60);
    }
  };

  initWebGL = function(canvas) {
    var error;
    gl = null;
    try {
      gl = canvas.getContext('experimental-webgl', {
        antialias: true
      });
    } catch (_error) {
      error = _error;
      console.log(error);
    }
    if (!gl) {
      return console.log('Unable to initialize WebGL. Your browser may not support it.');
    }
  };

  initShaders = function() {
    var fragmentShader, vertexShader;
    vertexShader = getShader(gl, 'shader-vs');
    fragmentShader = getShader(gl, 'shader-fs');
    shaderProgram = gl.createProgram();
    gl.attachShader(shaderProgram, vertexShader);
    gl.attachShader(shaderProgram, fragmentShader);
    gl.linkProgram(shaderProgram);
    if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)) {
      console.log('Unable to initialize the shader program.');
    }
    gl.useProgram(shaderProgram);
    vertexPositionAttribute = gl.getAttribLocation(shaderProgram, 'aVertexPosition');
    return gl.enableVertexAttribArray(vertexPositionAttribute);
  };

  initBuffers = function() {
    var generatedColors;
    triangleVerticesBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, triangleVerticesBuffer);
    triangleVertices = [-1.0, -1.0, 1.0, 1.0, -1.0, 1.0, 0.0, 1.0, 0.0, -1.0, -1.0, -1.0, 0.0, 1.0, 0.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, -1.0, -1.0, 1.0, -1.0, 1.0, -1.0, -1.0, 1.0, 1.0, -1.0, -1.0, 0.0, 1.0, 0.0, 1.0, -1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 0.0, 1.0, 0.0];
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(triangleVertices), gl.STATIC_DRAW);
    generatedColors = [0.0, 0.0, 0.0, 1.0];
    triangleVerticesIndexBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, triangleVerticesIndexBuffer);
    triangleVertexIndices = [0, 1, 2, 3, 4, 5, 6, 7, 8, 6, 8, 9, 10, 11, 12, 13, 14, 15];
    return gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(triangleVertexIndices), gl.STATIC_DRAW);
  };

  drawScene = function() {
    var currentTime, delta, mCos, mSin, vecX, vecY;
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    perspectiveMatrix = makePerspective(45, 640.0 / 480.0, 0.1, 100.0);
    loadIdentity();
    moveSpeed += 0.0265001;
    mCos = Math.cos(moveSpeed);
    mSin = Math.sin(moveSpeed);
    vecX = 3.0 * mCos;
    vecY = 1.5 * mSin;
    mvTranslate([vecX, vecY, -10.0]);
    mvPushMatrix();
    mvRotate(cubeRotation, [1, 1, 0]);
    gl.bindBuffer(gl.ARRAY_BUFFER, triangleVerticesBuffer);
    gl.vertexAttribPointer(vertexPositionAttribute, 3, gl.FLOAT, false, 0, 0);
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, triangleVerticesIndexBuffer);
    setMatrixUniforms();
    setColorUniform(0.0, 0.0, 0.0, 1.0);
    gl.drawElements(gl.LINE_STRIP, 18, gl.UNSIGNED_SHORT, 0);
    if (mCos > 0.0) {
      setColorUniform(0.0, 0.0, 0.0, 0.0);
      gl.drawElements(gl.TRIANGLES, 18, gl.UNSIGNED_SHORT, 0);
    } else {
      setColorUniform(0.0, 0.0, 0.0, Math.abs(mCos));
      gl.drawElements(gl.TRIANGLES, 18, gl.UNSIGNED_SHORT, 0);
    }
    mvPopMatrix();
    currentTime = (new Date).getTime();
    if (lastCubeUpdateTime) {
      delta = currentTime - lastCubeUpdateTime;
      cubeRotation += (30 * delta) / 1000.0;
    }
    return lastCubeUpdateTime = currentTime;
  };

  initStats = function() {
    stats = new Stats();
    stats.setMode(0);
    stats.domElement.style.position = 'absolute';
    stats.domElement.style.left = '0px';
    return stats.domElement.style.zIndex = 100;
  };

  getShader = function(gl, id) {
    var currentChild, shader, shaderScript, theSource;
    theSource = currentChild = shader = null;
    shaderScript = document.getElementById(id);
    if (!shaderScript) {
      return null;
    }
    theSource = '';
    currentChild = shaderScript.firstChild;
    while (currentChild) {
      if (currentChild.nodeType === 3) {
        theSource += currentChild.textContent;
      }
      currentChild = currentChild.nextSibling;
    }
    if (shaderScript.type === 'x-shader/x-fragment') {
      shader = gl.createShader(gl.FRAGMENT_SHADER);
    } else if (shaderScript.type === 'x-shader/x-vertex') {
      shader = gl.createShader(gl.VERTEX_SHADER);
    } else {
      return null;
    }
    gl.shaderSource(shader, theSource);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      console.log('An error occurred compiling the shaders: ', gl.getShaderInfoLog(shader));
    }
    return shader;
  };

  loadIdentity = function() {
    return mvMatrix = Matrix.I(4);
  };

  multMatrix = function(m) {
    return mvMatrix = mvMatrix.x(m);
  };

  mvTranslate = function(v) {
    return multMatrix(Matrix.Translation($V([v[0], v[1], v[2]])).ensure4x4());
  };

  setMatrixUniforms = function() {
    var mvUniform, pUniform;
    pUniform = gl.getUniformLocation(shaderProgram, 'uPMatrix');
    gl.uniformMatrix4fv(pUniform, false, new Float32Array(perspectiveMatrix.flatten()));
    mvUniform = gl.getUniformLocation(shaderProgram, 'uMVMatrix');
    return gl.uniformMatrix4fv(mvUniform, false, new Float32Array(mvMatrix.flatten()));
  };

  setColorUniform = function(factorR, factorG, factorB, factorA) {
    var colorUniform, fragColor;
    fragColor = [1.0 * factorR, 1.0 * factorG, 1.0 * factorB, 1.0 * factorA];
    colorUniform = gl.getUniformLocation(shaderProgram, 'colorUniform');
    return gl.uniform4fv(colorUniform, new Float32Array(fragColor));
  };

  mvPushMatrix = function(m) {
    if (m) {
      mvMatrixStack.push(m.dup());
      return mvMatrix = m.dup();
    } else {
      return mvMatrixStack.push(mvMatrix.dup());
    }
  };

  mvPopMatrix = function() {
    if (!mvMatrixStack.length) {
      throw 'Cant pop from an empty matrix stack.';
    }
    mvMatrix = mvMatrixStack.pop();
    return mvMatrix;
  };

  mvRotate = function(angle, v) {
    var inRadians, m;
    inRadians = angle * (Math.PI / 180.0);
    m = Matrix.Rotation(inRadians, $V([v[0], v[1], v[2]])).ensure4x4();
    return multMatrix(m);
  };

}).call(this);
