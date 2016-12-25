//              ______    _____            _________       _____   _____
//            /     /_  /    /            \___    /      /    /__/    /
//           /        \/    /    ___        /    /      /            /    ___
//          /     / \      /    /\__\      /    /___   /    ___     /    /   \
//        _/____ /   \___ /    _\___     _/_______ / _/___ / _/___ /    _\___/\_
//        revised on 2/12/2016  All rights reserved by @NeZha
'use strict'

const THREE = require( '../third-party/three/build/three.js' )

class Loading {
    constructor() { 
        this.scene = new THREE.Scene()
        this.camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 1, 10000 )
        this.clock = new THREE.Clock()
        this.objects = {}
    }

    init() {
        this.camera.position.z = 1000
        let geometry = new THREE.BoxGeometry( 200, 200, 200 )
        let material = new THREE.MeshBasicMaterial( { color: 0xff0000, wireframe: true } )
        let mesh = new THREE.Mesh( geometry, material )
        this.scene.add( mesh )

        this.objects[ 'cube' ] = mesh
    }

    onRender() {
        let dt = this.clock.getDelta()
        this.objects[ 'cube' ].rotation.x += 0.01;
        this.objects[ 'cube' ].rotation.y += 0.02;
    }

}


if ( typeof module === 'object' ) {
    module.exports = Loading
}