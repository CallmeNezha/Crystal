//              ______    _____            _________       _____   _____
//            /     /_  /    /            \___    /      /    /__/    /
//           /        \/    /    ___        /    /      /            /    ___
//          /     / \      /    /\__\      /    /___   /    ___     /    /   \
//        _/____ /   \___ /    _\___     _/_______ / _/___ / _/___ /    _\___/\_
//        revised on 2/12/2016  All rights reserved by @NeZha
'use strict'

const THREE = require( '../third-party/three/build/three.js' )

// Vertex shader x-shader/x-vertex
let vs = `
    uniform sampler2D map;

    uniform float width;
    uniform float height;
    uniform float nearClipping, farClipping;
    
    uniform float pointSize;
    uniform float zOffset;

    varying vec2 vUv;

    const float XtoZ = 1.11146; // tan( 1.0144686 / 2.0 ) * 2.0;
    const float YtoZ = 0.83359; // tan( 0.7898090 / 2.0 ) * 2.0;

    void main() {

        vUv = vec2( position.x / width, position.y / height );

        vec4 color = texture2D( map, vUv );
        float depth = ( color.r + color.g + color.b ) / 3.0;

        // Projection code by @kcmic

        float z = ( 1.0 - depth ) * (farClipping - nearClipping) + nearClipping;

        vec4 pos = vec4(
            ( position.x / width - 0.5 ) * z * XtoZ,
            ( position.y / height - 0.5 ) * z * YtoZ,
            - z + zOffset,
            1.0);

        gl_PointSize = pointSize;
        gl_Position = projectionMatrix * modelViewMatrix * pos;
    }
`

let fs = `
    uniform sampler2D map;

    varying vec2 vUv;

    void main() {

        vec4 color = texture2D( map, vUv );
        gl_FragColor = vec4( color.r, color.g, color.b, 0.2 );

    }
`

let mouse = new THREE.Vector3( 0, 0, 1 )
let center = new THREE.Vector3( 0, 0, -1000 )



class Kinect {
    constructor() {
        this.scene = new THREE.Scene()
        this.camera = new THREE.PerspectiveCamera( 50, window.innerWidth / window.innerHeight, 1, 10000 )
        this.clock = new THREE.Clock()
        this.objects = {}
    }

    init() {
        this.camera.position.set( 0, 0, 500 )


        let video = document.createElement( 'video' )
        video.addEventListener( 'loadedmetadata',  event => {

            let texture = new THREE.VideoTexture( video )
            texture.minFilter = THREE.NearestFilter

            let width = 640, height = 480
            let nearClipping = 850, farClipping = 4000

            let geometry = new THREE.BufferGeometry()

            let vertices = new Float32Array( width * height * 3 )

            for ( let i = 0, j = 0, l = vertices.length; i < l; i += 3, j++ ) {
                vertices[ i ] = j % width
                vertices[ i + 1 ] = Math.floor( j / width )
            }

            geometry.addAttribute( 'position', new THREE.BufferAttribute( vertices, 3 ) )

            let material = new THREE.ShaderMaterial( {

                uniforms: {
                    "map": { value: texture }
                    , "width": { value: width }
                    , "height": { value: height }
                    , "nearClipping": { value: nearClipping }
                    , "farClipping": { value: farClipping }
                    , "pointSize": { value: 2 }
                    , "zOffset": { value: 1000 }
                }
                , vertexShader: vs
                , fragmentShader: fs
                , blending: THREE.AdditiveBlending
                , depthTest: false
                , depthWrite: false
                , transparent: true

            } )

            let mesh = new THREE.Points( geometry, material )
            this.scene.add( mesh )

            // let gui = new dat.GUI()
            // gui.add( material.uniforms.nearClipping, 'value', 1, 10000, 1.0 ).name( 'nearClipping' )
            // gui.add( material.uniforms.farClipping, 'value', 1, 10000, 1.0 ).name( 'farClipping' )
            // gui.add( material.uniforms.pointSize, 'value', 1, 10, 1.0 ).name( 'pointSize' )
            // gui.add( material.uniforms.zOffset, 'value', 0, 4000, 1.0 ).name( 'zOffset' )
            // gui.close()

        }, false )

        video.loop = true;
        video.muted = true;

        video.src = __dirname + '/../third-party/three/examples/textures/kinect.webm'
        video.setAttribute( 'webkit-playsinline', 'webkit-playsinline' )
        video.play()
        
        
        document.addEventListener( 'mousemove', this.onDocumentMouseMove, false )
    
    }

    onRender() {
        
        this.camera.position.x += ( mouse.x - this.camera.position.x ) * 0.05
        this.camera.position.y += ( mouse.y - this.camera.position.y ) * 0.05
        this.camera.lookAt( center )

    }

    onDocumentMouseMove( event ) {
        mouse.x = ( event.clientX - window.innerWidth / 2 ) * 8
        mouse.y = ( event.clientY - window.innerHeight / 2 ) * 8
    }
    
}

if ( typeof module === 'object' ) {
    module.exports = Kinect
}