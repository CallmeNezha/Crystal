#              ______    _____            _________       _____   _____
#            /     /_  /    /            \___    /      /    /__/    /
#           /        \/    /    ___        /    /      /            /    ___
#          /     / \      /    /\__\      /    /___   /    ___     /    /   \
#        _/____ /   \___ /    _\___     _/_______ / _/___ / _/___ /    _\___/\_
#        created on 28/12/2016  All rights reserved by @NeZha
#        Night gathers, and now my watch begins. It shall not end until my death.

fs = require 'fs'
env = require '../../env'
THREE = require "#{env.PATH.THREE}build/three"
Stats = require "#{env.PATH.THREE}examples/js/libs/stats.min.js"
TWEEN = require "#{env.PATH.TWEEN}src/Tween"

do ->
  file = fs.readFileSync("#{env.PATH.THREE}examples/js/loaders/STLLoader.js", 'utf-8'); eval file
  file = fs.readFileSync("#{env.PATH.THREE}examples/js/loaders/3MFLoader.js", 'utf-8'); eval file
  file = fs.readFileSync("#{env.PATH.THREE}examples/js/loaders/OBJLoader.js", 'utf-8'); eval file
  file = fs.readFileSync("#{env.PATH.THREE}examples/js/controls/OrbitControls.js", 'utf-8'); eval file


class Tutorial
  constructor: ->
    @renderer = new THREE.WebGLRenderer(antialias: false)
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.01, 10000)
    @objects = {}

    @_control = null
    @_step = 0
    @_rollback = null

  init: ->
    # Renderer initialization
    @renderer.setPixelRatio(window.devicePixelRatio)
    @renderer.setSize(window.innerWidth, window.innerHeight)
    @renderer.setClearColor(0xDBDBDB)
    @renderer.gammaInput = on
    @renderer.gammaOutput = on

    @camera.position.set(12, 12, 0)
    @camera.lookAt(new THREE.Vector3())

    @_control = new THREE.OrbitControls(@camera, @renderer.domElement)
    @_control.enableZoom = yes
    @_control.minPolarAngle = - Infinity
    @_control.maxPolarAngle = Infinity

    # Lights
    @scene.add(new THREE.HemisphereLight(0xffffbb, 0x080820, 1))
    @_addShadowedLight(1, 1, 1)


    @_loadTable()

    axisHelper = new THREE.AxisHelper(5)
    @scene.add(axisHelper)

    return


  onWindowResize: =>
    @renderer.setSize(window.innerWidth, window.innerHeight)
    @camera.aspect = window.innerWidth / window.innerHeight
    @camera.updateProjectionMatrix()

    return

   

  render: (time) ->
    @renderer.render(@scene, @camera)
    TWEEN.update(time)
    return

  next: (f) =>
    table = @objects['table']
    vertices = table.geometry.getAttribute('position').array
    normals = table.geometry.getAttribute('normal').array
    @_rollback?()
    if f is 'LOL' then @_step--  else @_step++

    if @_step is 1
      document.getElementById('text-step-describe').innerHTML = 
        "First we use K-Means clustering the vertices by its normal. 
        So we can get the clusters with its center(cluster center).
        "
      group = new THREE.Group()
      for idx in [0...vertices.length] by 30
        pos = new THREE.Vector3(vertices[idx], vertices[idx + 1], vertices[idx + 2])
        nor = new THREE.Vector3(normals[idx], normals[idx + 1], normals[idx + 2])
        arrowHelper = new THREE.ArrowHelper(nor, pos, 0.7, new THREE.Color(nor.x, nor.y, nor.z))
        group.updateMatrixWorld(true)
        group.add(arrowHelper)
      @scene.add(group)
      @_rollback = =>
        @scene.remove(group)

    if @_step is 2
      document.getElementById('text-step-describe').innerHTML = 
        "So we have the clusters with its center(cluster center), we can campared each cluster\'s center
        with WORLD Upward direction which is prior known as (0, 1, 0) and choose a best cluster as our
        best-fit candidate.
        "
      group = new THREE.Group()
      for idx in [0...vertices.length] by 30
        pos = new THREE.Vector3(vertices[idx], vertices[idx + 1], vertices[idx + 2])
        nor = new THREE.Vector3(normals[idx], normals[idx + 1], normals[idx + 2])
        continue if nor.dot(new THREE.Vector3(0,1,0)) < 0.7
        arrowHelper = new THREE.ArrowHelper(nor, pos, 0.7, new THREE.Color(nor.x, nor.y, nor.z))
        group.updateMatrixWorld(true)
        group.add(arrowHelper)
      @scene.add(group)
      @_rollback = =>
        @scene.remove(group)

    if @_step is 3
      document.getElementById('text-step-describe').innerHTML = 
        "Now we have a better vertices' group to work with which more likely be the vertices lay upon the table.
        We use K-MEANS again to cluster them in \"cluster center direction\"(project them into one dimension with respect to its cluster center).
        You can think this as cluster against Table's Upward Direction. Then we can get rid of other \"Noise\" in the model.
        "
      group = new THREE.Group()
      for idx in [0...vertices.length] by 30
        pos = new THREE.Vector3(vertices[idx], vertices[idx + 1], vertices[idx + 2])
        nor = new THREE.Vector3(normals[idx], normals[idx + 1], normals[idx + 2])
        continue if nor.dot(new THREE.Vector3(0,1,0)) < 0.7 or pos.y > 3.0 or pos.y < 1.3
        arrowHelper = new THREE.ArrowHelper(nor, pos, 0.7, new THREE.Color(nor.x, nor.y, nor.z))
        group.updateMatrixWorld(true)
        group.add(arrowHelper)
      @scene.add(group)
      @_rollback = =>
        @scene.remove(group)

    if @_step is 4
      document.getElementById('text-step-describe').innerHTML = 
        "Now we have a better vertices' group to work with which more likely be the vertices lay upon the table.
        We use K-MEANS again to cluster them in \"cluster center direction\"(project them into one dimension with respect to its cluster center).
        You can think this as cluster against Table's Upward Direction. Then we can get rid of other \"Noise\" in the model.
        "
      group = new THREE.Group()
      for idx in [0...vertices.length] by 30
        pos = new THREE.Vector3(vertices[idx], vertices[idx + 1], vertices[idx + 2])
        nor = new THREE.Vector3(normals[idx], normals[idx + 1], normals[idx + 2])
        continue if nor.dot(new THREE.Vector3(0,1,0)) < 0.7 or pos.y > 3.0 or pos.y < 1.3
        plane = new THREE.PlaneGeometry( 0.4, 0.4)
        material = new THREE.MeshBasicMaterial( {color: 0xffff00, side: THREE.DoubleSide} )
        plane = new THREE.Mesh( geometry, material )
        plane.position.set(pos)
        group.updateMatrixWorld(true)
        group.add(plane)
      @scene.add(group)
      @_rollback = =>
        @scene.remove(group)

  prev: =>
    @next('LOL')



  ##
  # Add some direct light from sky
  #
  _addShadowedLight: (x, y, z, d = 10000, color = 0xffffbb, intensity = 1) ->
    directLight = new THREE.DirectionalLight(color, intensity)
    directLight.position.set(x, y, z)
    # directLight.castShadow = yes
    # directLight.shadow.camera.left = -d
    # directLight.shadow.camera.right = d
    # directLight.shadow.camera.top = d
    # directLight.shadow.camera.bottom = -d
    # directLight.shadow.camera.near = 1
    # directLight.shadow.camera.far = d
    # directLight.shadow.mapSize.width = 1024
    # directLight.shadow.mapSize.height = 1024
    # directLight.shadow.bias = -0.005
    @scene.add(directLight)
    return

  _loadTable: ->
    loader = new THREE.STLLoader()
    loader.load('d:/TestFiles/mesh_simple.stl', (geometry) => 
        material = new THREE.MeshPhongMaterial(color: 0x24426b, specular: 0x1111111, shininess: 2)
        mesh = new THREE.Mesh(geometry, material)
        geometry.computeFaceNormals()
        geometry.computeVertexNormals(true)
        geometry.verticesNeedUpdate = true
        geometry.elementsNeedUpdate = true
        geometry.normalsNeedUpdate = true

        @scene.add(mesh)
        @objects["table"] = mesh
      )







init = ->
  # Stats initialization
  node = document.getElementById('stats-output')
  while node.firstChild?
    node.removeChild(node.firstChild)
  node.appendChild(stats.dom)

  node = document.getElementById('webgl-output')
  while node.firstChild?
    node.removeChild(node.firstChild)
  node.appendChild(tutorial?.renderer.domElement)
  
  # Window event listeners
  window.addEventListener('resize', tutorial?.onWindowResize, false)
  window.addEventListener('close', tutorial?.onWindowClose, false)

  tutorial?.init(document.getElementById('tutorial-panel'))
  return

animate = (time) ->
  requestAnimationFrame(animate)
  tutorial?.render(time)
  stats.update()
  return




# main
gldiv = document.getElementById('webgl-output')
guidiv = document.getElementById('tutorial-panel')
document.getElementById('btn-next')
stats = new Stats()

tutorial = new Tutorial()
document.getElementById('btn-next').addEventListener('click', tutorial.next)
document.getElementById('btn-prev').addEventListener('click', tutorial.prev)


init()
animate()