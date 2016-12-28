#              ______    _____            _________       _____   _____
#            /     /_  /    /            \___    /      /    /__/    /
#           /        \/    /    ___        /    /      /            /    ___
#          /     / \      /    /\__\      /    /___   /    ___     /    /   \
#        _/____ /   \___ /    _\___     _/_______ / _/___ / _/___ /    _\___/\_
#        revised on 22/12/2016  All rights reserved by @NeZha

env = require( '../../env.js' )
THREE = require( env.PATH.THREE + 'build/three.js' )
Function = require( './blueprint/function.js' )

class Blueprint

    constructor: ->
        @scene = new THREE.Scene()
        @camera = new THREE.OrthographicCamera( - 100, 100, 100, - 100, 0.1, 100 )
        @clock = new THREE.Clock()
        @objects = {}
        return @

    init: ( renderer ) ->
        renderer.setClearColor( 0x162b42 )
        @camera.position.z = 100
        geometry = new THREE.PlaneGeometry( 5, 5 )
        material = new THREE.MeshBasicMaterial( { color: 0xff0000, wireframe: true } )
        mesh = new THREE.Mesh( geometry, material )
        @scene.add( mesh )
        @objects[ 'cube' ] = mesh
        return

    onRender: ->
        dt = @clock.getDelta()
        return

module.exports = Blueprint if module?