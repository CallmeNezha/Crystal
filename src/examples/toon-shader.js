//              ______    _____            _________       _____   _____
//            /     /_  /    /            \___    /      /    /__/    /
//           /        \/    /    ___        /    /      /            /    ___
//          /     / \      /    /\__\      /    /___   /    ___     /    /   \
//        _/____ /   \___ /    _\___     _/_______ / _/___ / _/___ /    _\___/\_
//        revised on 4/12/2016  All rights reserved by @NeZha

'use strict'

const THREE = require( '../third-party/three/build/three.js' )
const fs = require( 'fs' )

var file = fs.readFileSync( __dirname + '/../third-party/three/examples/js/loaders/STLLoader.js', 'utf-8' )
eval( file )
file = fs.readFileSync( __dirname + '/../third-party/three/examples/js/controls/OrbitControls.js', 'utf-8' )
eval( file )

let controls


class ToonShaderExample {
    constructor() { 
        this.scene = new THREE.Scene()
        this.camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.01, 10000 )
        this.clock = new THREE.Clock()
        this.objects = {}
    }

    

    init( renderer ) {

        // Orbit controls
        
        controls = new THREE.OrbitControls( this.camera, renderer.domElement )
        controls.enableZoom = true

        this.scene.fog = new THREE.Fog( 0x72645b, 2, 150 );
        renderer.setClearColor( this.scene.fog.color );

        renderer.gammaInput = true
        renderer.gammaOutput = true

        renderer.shadowMap.enabled = true
        renderer.shadowMap.renderReverseSided = false

        this.camera.position.set( 1, 0.15, 1 );
        let cameraTarget = new THREE.Vector3( 0, -0.25, 0 );
        this.camera.lookAt( cameraTarget );

        // Ground

        var plane = new THREE.Mesh(
            new THREE.PlaneBufferGeometry( 40, 40 ),
            new THREE.MeshPhongMaterial( { color: 0x999999, specular: 0x101010 } )
        );
        plane.rotation.x = -Math.PI/2;
        plane.position.y = -0.5;
        this.scene.add( plane );

        plane.receiveShadow = true;

        let loader = new THREE.STLLoader();
        loader.load( __dirname + '/../third-party/three/examples/models/stl/ascii/slotted_disk.stl', ( geometry ) => {

            //THREE.SceneUtils.createMultiMaterialObject(  )

            let material = new THREE.MeshPhongMaterial( { color: 0xff5533, specular: 0x111111, shininess: 200 } )
            let mesh = new THREE.Mesh( geometry, material )

            mesh.position.set( 0, - 0.25, 0.6 )
            mesh.rotation.set( 0, - Math.PI / 2, 0 )
            mesh.scale.set( 0.5, 0.5, 0.5 )

            mesh.castShadow = true
            mesh.receiveShadow = true

            this.scene.add( mesh )

        } )

        // Binary files

        var material = new THREE.MeshPhongMaterial( { color: 0xAAAAAA, specular: 0x111111, shininess: 200 } );

        loader.load( __dirname + '/../third-party/three/examples/models/stl/binary/pr2_head_pan.stl', ( geometry ) => {

            var mesh = new THREE.Mesh( geometry, material );

            mesh.position.set( 0, - 0.37, - 0.6 );
            mesh.rotation.set( - Math.PI / 2, 0, 0 );
            mesh.scale.set( 2, 2, 2 );

            mesh.castShadow = true;
            mesh.receiveShadow = true;

            this.scene.add( mesh );

        } );

        loader.load( __dirname + '/../third-party/three/examples/models/stl/binary/pr2_head_tilt.stl', ( geometry ) => {

            var mesh = new THREE.Mesh( geometry, material );

            mesh.position.set( 0.136, - 0.37, - 0.6 );
            mesh.rotation.set( - Math.PI / 2, 0.3, 0 );
            mesh.scale.set( 2, 2, 2 );

            mesh.castShadow = true;
            mesh.receiveShadow = true;

            this.scene.add( mesh );

        } );

        // Colored binary STL
        loader.load( __dirname + '/../third-party/three/examples/models/stl/binary/colored.stl', ( geometry ) => {

            var meshMaterial = material;
            if (geometry.hasColors) {
                meshMaterial = new THREE.MeshPhongMaterial({ opacity: geometry.alpha, vertexColors: THREE.VertexColors });
            }

            var mesh = new THREE.Mesh( geometry, meshMaterial );

            mesh.position.set( 0.5, 0.2, 0 );
            mesh.rotation.set( - Math.PI / 2, Math.PI / 2, 0 );
            mesh.scale.set( 0.3, 0.3, 0.3 );

            mesh.castShadow = true;
            mesh.receiveShadow = true;

            this.scene.add( mesh );

        } );


        // Lights

        this.scene.add( new THREE.HemisphereLight( 0x443333, 0x111122 ) );

        // this.scene.add( new THREE.HemisphereLight( 0x443333, 0x111122 ) )
        this.addShadowedLight( 1, 1, 1, 0xffffff, 1.35 );
        this.addShadowedLight( 0.5, 1, -1, 0xffaa00, 1 );
        
    }

    onRender() {
        let dt = this.clock.getDelta()

        controls.update()
        
    }


    addShadowedLight( x, y, z, color, intensity ) {

        var directionalLight = new THREE.DirectionalLight( color, intensity );
        directionalLight.position.set( x, y, z );
        this.scene.add( directionalLight );

        directionalLight.castShadow = true;

        var d = 1;
        directionalLight.shadow.camera.left = -d;
        directionalLight.shadow.camera.right = d;
        directionalLight.shadow.camera.top = d;
        directionalLight.shadow.camera.bottom = -d;

        directionalLight.shadow.camera.near = 1;
        directionalLight.shadow.camera.far = 4;

        directionalLight.shadow.mapSize.width = 1024;
        directionalLight.shadow.mapSize.height = 1024;

        directionalLight.shadow.bias = -0.005;
    }

}

if ( typeof module === 'object' ) {

    module.exports = ToonShaderExample
    
}