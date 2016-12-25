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

do ->
  file = fs.readFileSync("#{env.PATH.THREE}examples/js/loaders/STLLoader.js", 'utf-8'); eval file
  file = fs.readFileSync("#{env.PATH.THREE}examples/js/loaders/3MFLoader.js", 'utf-8'); eval file
  file = fs.readFileSync("#{env.PATH.THREE}examples/js/loaders/OBJLoader.js", 'utf-8'); eval file
  file = fs.readFileSync("#{env.PATH.THREE}examples/js/controls/OrbitControls.js", 'utf-8'); eval file


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
    return

  add: (mesh) ->
    # mesh.castShadow = yes
    # mesh.receiveShadow = yes
    @scene.add(mesh)

  remove: (mesh) ->
    @scene.remove(mesh)

  onRender: ->
    dt = this.clock.getDelta()
    @_control.update()
    return


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


# MeshLab is a template for swift mesh algorithm development & playground
MeshLab =
  View: View
  THREE: THREE
  env: env
  STLLoader: THREE.STLLoader
  OBJLoader: THREE.OBJLoader
  ThreeMFLoader: THREE.ThreeMFLoader

module.exports = MeshLab if module?
