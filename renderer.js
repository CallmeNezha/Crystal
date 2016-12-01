// This file is required by the index.html file and will
// be executed in the renderer process for that window.
// All of the Node.js APIs are available in this process.

'use strict'

const THREE = require( './third-party/three/three.js' )
const Stats = require( './third-party/three/libs/js/libs/stats.min.js' )

let Loading = require( './example/loading.js' )
let example = new Loading()
let renderer, stats


init();
animate();

function init() {

    renderer = new THREE.WebGLRenderer();
    renderer.setSize( window.innerWidth, window.innerHeight );

    document.getElementById( 'webgl-output' ).appendChild( renderer.domElement );

    // Stats initialzation
    stats = new Stats()
    document.getElementById( 'stats-output' ).appendChild( stats.dom )

    // Window event listeners
    window.addEventListener( 'resize', onWindowResize, false )

    example = new Loading()
    example.init()
    document.getElementById( 'loading' ).style.display = 'none'
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
var cnsl = new Console({}, {
    hotkey: 192, // <kbd>ESC</kbd> ('~' for default)
    welcome: 'Welcome back, Master.Nezha.',
    caseSensitive: true,
    defaultHandler: function(){},
    onShow: function(){},
    onHide: function(){},
})

cnsl.register('showall',function(name){
    playerName = name;
    return '' + playerName + ' now.';
}, {
    usage: 'SHOWALL &lt;name&gt; || SHOW -a &lt;name&gt;',
    desc: 'Show all geometry name on console.'
}).register('selfdestroy',function(name){
    playerName = name;
    return '' + playerName + ' now.';
}, {
    usage: 'SELFDESTROY',
    desc: 'Destroy geometry name on console.'
}).register('help', function () {
    var cmds = cnsl.commands;
    for (var name in cmds) {
        if (cmds.hasOwnProperty(name)) {
        cmds[name].desc && cnsl.log(' -', cmds[name].usage + ':', cmds[name].desc);
        }
    }
},{
    usage: 'HELP',
    desc: 'Show help messages.'
}).register('command', function (command) {
    eval(command)
} , {
    usage: 'COMMAND &lt;command&gt;',
    desc: 'Execute javascript interactively.'
}).register( 'clear', function() {
    example = new Loading()
    example.init()
    console.log( 'clear success' )
}, {
    usage: 'CLEAR',
    desc: 'Clear current scene and pop back to defualt.'
} )