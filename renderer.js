//              ______    _____            _________       _____   _____
//            /     /_  /    /            \___    /      /    /__/    /
//           /        \/    /    ___        /    /      /            /    ___
//          /     / \      /    /\__\      /    /___   /    ___     /    /   \
//        _/____ /   \___ /    _\___     _/_______ / _/___ / _/___ /    _\___/\_
//        revised on 2/12/2016  All rights reserved by @NeZha

'use strict'

const THREE = require( './third-party/three/build/three.js' )
const Stats = require( './third-party/three/examples/js/libs/stats.min.js' )

let example
let renderer, stats


init();
animate();

function init() {

    setNewRenderer()

    // Stats initialzation
    stats = new Stats()
    let node = document.getElementById( 'stats-output' )
    while ( node.firstChild ) node.removeChild(node.firstChild)
    node.appendChild( stats.dom )

    // Window event listeners
    window.addEventListener( 'resize', onWindowResize, false )

    let Loading = require( './example/loading.js' )
    example = new Loading()
    example.init( renderer )
    document.getElementById( 'loading' ).style.display = 'none'
}

function setNewRenderer() {
    // Open antialias cause a significant reduction in performance
    renderer = new THREE.WebGLRenderer( { antialias: false } )  
    renderer.setPixelRatio( window.devicePixelRatio )
    renderer.setSize( window.innerWidth, window.innerHeight )

    let node = document.getElementById( 'webgl-output' )
    while ( node.firstChild ) node.removeChild(node.firstChild)
    node.appendChild( renderer.domElement )
}



function animate() {

    requestAnimationFrame( animate )
    if ( !example ) return

    example.onRender()
    renderer.render( example.scene, example.camera )
    stats.update()

}

function onWindowResize() {

    renderer.setSize( window.innerWidth, window.innerHeight )
    if ( !example ) return

    example.camera.aspect = window.innerWidth / window.innerHeight
    example.camera.updateProjectionMatrix()

}


// Console script
var cnsl = new Console( {}, {
    hotkey: 192 // <kbd>ESC</kbd> ('~' for default)
    , welcome: 'Welcome back, Master.Nezha.'
    , caseSensitive: true
    , defaultHandler: function() {}
    , onShow: function() {}
    , onHide: function() {}
} )

cnsl.register( 'help', function () {
    let cmds = cnsl.commands
    for ( let name in cmds ) {
        if ( cmds.hasOwnProperty( name ) ) 
            cmds[ name ].desc && cnsl.log( ' -', cmds[name].usage + ':', cmds[name].desc )
    }
}, {
    usage: 'HELP'
    , desc: 'Show help messages.'
} ).register( 'command', function ( command ) {
    eval( command )
}, {
    usage: 'COMMAND &lt;command&gt;'
    , desc: 'Execute javascript interactively.'
} ).register( 'clear', function() {
    init()
    console.log( 'clear success' )
}, {
    usage: 'CLEAR'
    , desc: 'Clear current scene and pop back to defualt.'
} ).register( 'load', function( name ) {

    document.getElementById( 'loading' ).style.display = 'block'
    setNewRenderer()
    let Foo = require( `./example/${name}.js` )
    example = new Foo()
    example.init( renderer )
    document.getElementById( 'loading' ).style.display = 'none'

}, {
    usage: `LOAD &lt;example&gt;`
    , desc: 'Load example file under Crystal/example directory'
} )