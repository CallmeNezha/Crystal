#              ______    _____            _________       _____   _____
#            /     /_  /    /            \___    /      /    /__/    /
#           /        \/    /    ___        /    /      /            /    ___
#          /     / \      /    /\__\      /    /___   /    ___     /    /   \
#        _/____ /   \___ /    _\___     _/_______ / _/___ / _/___ /    _\___/\_
#        created on 25/12/2016  All rights reserved by @NeZha
#        Today is chrismas :) but Dan Shen Gou still keep finding source code of the world instead of meeting
#        a girl to make little human(in biology aspect of source code), so the saying: Ge Si Qi Zhi

fs = require 'fs'
env = require '../../env'
THREE = require "#{env.PATH.THREE}build/three"
Kinect = require "./Crystal_Geo.node"
console.log(Kinect)
do ->
  file = fs.readFileSync("#{env.PATH.THREE}examples/js/loaders/STLLoader.js", 'utf-8'); eval file
  file = fs.readFileSync("#{env.PATH.THREE}examples/js/loaders/3MFLoader.js", 'utf-8'); eval file
  file = fs.readFileSync("#{env.PATH.THREE}examples/js/loaders/OBJLoader.js", 'utf-8'); eval file
  file = fs.readFileSync("#{env.PATH.THREE}examples/js/controls/OrbitControls.js", 'utf-8'); eval file

vertexShader =
  """
  uniform float width;
  uniform float height;
  varying vec2 vUv;
  uniform sampler2D map;
  uniform float time;

	void main()
	{
    vUv = vec2(position.x / width, position.y / height);
    vec4 color = texture2D(map, vUv);

		vec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );
    gl_PointSize = 5.0;
		gl_Position = projectionMatrix * mvPosition;
	}

  """

fragmentShader =
  """
  uniform sampler2D map;
  varying vec2 vUv;
  uniform float time;

  void main() {

    vec4 color = texture2D(map, vUv);
    gl_FragColor = vec4(color.rgb, 1.0);
  }
  """

class View
  constructor: ->
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.01, 10000)
    @clock = new THREE.Clock()
    @objects = {}

    @_control = null

  init: (renderer) ->
    renderer.setClearColor(0xDBDBDB)
    renderer.gammaInput = on
    renderer.gammaOutput = on
    # renderer.shadowMap.enabled = true

    @_control = new THREE.OrbitControls(@camera, renderer.domElement)
    @_control.enableZoom = yes
    @camera.position.set(20, 20, 0)
    @camera.lookAt(new THREE.Vector3())

    # Lights
    @scene.add(new THREE.HemisphereLight(0xffffbb, 0x080820, 1))
    @_addShadowedLight(1, 1, 1)

    Kinect.CreateKinect()
    width = 512
    height = 424
    @_depthframe = new Float32Array(width * height)
    # geometry = new THREE.PlaneGeometry(1, 1)
    @_geometry = geometry = new THREE.BufferGeometry()
    vertices = new Float32Array( width * height * 3)
    ```
    for ( var i = 0, j = 0, l = vertices.length; i < l; i += 3, j ++ ) {
      vertices[ i ] = j % width;
      vertices[ i + 1 ] = Math.floor( j / width );
    }
    ```
    geometry.addAttribute( 'position', new THREE.BufferAttribute( vertices, 3 ) )

    @_texture = new THREE.Texture(@_generateTexture())
    @_texture.needsUpdate = true

    @_uniforms =
      map: { value: @_texture }
      width: {value: width}
      height: {value: height}
      time: {value: 0.0}
      blending: THREE.AdditiveBlending
      depthTest: false
      depthWrite: false,
      transparent: true

    material = new THREE.ShaderMaterial(uniforms: @_uniforms
      , vertexShader: vertexShader
      , fragmentShader: fragmentShader)

    #material = new THREE.MeshBasicMaterial( {color: 0x102000, side: THREE.DoubleSide} )

    mesh = new THREE.Points(geometry, material)
    mesh.scale.set(0.01, 0.01, 0.01)
    @scene.add(mesh)

    return

  onRender: ->
    dt = this.clock.getDelta()
    @_control.update()

    success = Kinect.GetDepthBuffer(@_depthframe)
    # console.log("#{success} GetDepthBuffer returns")
    @_putImageData()
    @_texture.needsUpdate = true
    @_updateDepth()
    @_uniforms.time.value += 0.05
    return

  onExit: ->
    Kinect.DestroyKinect()
    return

  ##
  # Add some direct light from sky
  #
  _addShadowedLight: (x, y, z, d = 10000, color = 0xffffbb, intensity = 0.2) ->
    directLight = new THREE.DirectionalLight(color, intensity)
    directLight.position.set(x, y, z)
    @scene.add(directLight)
    return

  _generateTexture: ->
    canvas = document.createElement('canvas')
    canvas.width = 512
    canvas.height = 424
    @_context = canvas.getContext('2d')
    image = @_context.getImageData(0, 0, 512, 424)
    for i in [0...512 * 424]
      image.data[i] = Math.random() * 255

    @_context.putImageData(image, 0, 0)
    return canvas

  _putImageData: ->
    image = @_context.getImageData(0, 0, 512, 424)
    for ipxl in [0...512 * 424 * 4] by 4
      intensity = @_depthframe[ipxl / 4]
      intensity = if intensity < 1800 then (intensity / 1800) * 255 else 0
      image.data[ipxl    ] = intensity
      image.data[ipxl + 1] = intensity
      image.data[ipxl + 2] = intensity
      image.data[ipxl + 3] = 255
    @_context.putImageData(image, 0, 0)
    return

  _updateDepth: ->
    position = @_geometry.attributes.position.array
    for ipxl in [0...512 * 424]
      depth = @_depthframe[ipxl]
      position[ipxl * 3 + 2] = depth / 10 

    @_geometry.attributes.position.needsUpdate = true;


module.exports = View if module?
