var dataset = [
    [1,1],[0,1],[1,0],
    [10,10],[10,13],[13,13],
    [54,54],[55,55],[89,89],[57,55]
];

var DBSCAN = require('../third-party/dbscan/DBSCAN.js');
var dbscan = new DBSCAN();
// parameters: 5 - neighborhood radius, 2 - number of points in neighborhood to form a cluster
var clusters = dbscan.run(dataset, 5, 2);
console.log(clusters, dbscan.noise);


'use strict'

const THREE = require( '../third-party/three/build/three.js' )
const fs = require( 'fs' )

var file = fs.readFileSync( __dirname + '/../third-party/three/examples/js/loaders/STLLoader.js', 'utf-8' )
eval( file )
file = fs.readFileSync( __dirname + '/../third-party/three/examples/js/controls/OrbitControls.js', 'utf-8' )
eval( file )

let controls, table

function mergeVertices() {

    var verticesMap = {}; // Hashmap for looking up vertices by position coordinates (and making sure they are unique)
    var unique = [], changes = [];

    var v, key;
    var precisionPoints = 1; // number of decimal points, e.g. 4 for epsilon of 0.001
    console.log( "Truncates precision:  for epsilon of 0.001 " )
    var precision = Math.pow( 10, precisionPoints );
    var i, il, face;
    var indices, j, jl;

    for ( i = 0, il = this.vertices.length; i < il; i++ ) {

        v = this.vertices[ i ];
        key = Math.round( v.x * precision ) + '_' + Math.round( v.y * precision ) + '_' + Math.round( v.z * precision );

        if ( verticesMap[ key ] === undefined ) {

            verticesMap[ key ] = i;
            unique.push( this.vertices[ i ] );
            changes[ i ] = unique.length - 1;

        } else {

            //console.log('Duplicate vertex found. ', i, ' could be using ', verticesMap[key]);
            changes[ i ] = changes[ verticesMap[ key ] ];

        }

    }


    // if faces are completely degenerate after merging vertices, we
    // have to remove them from the geometry.
    var faceIndicesToRemove = [];

    for ( i = 0, il = this.faces.length; i < il; i++ ) {

        face = this.faces[ i ];

        face.a = changes[ face.a ];
        face.b = changes[ face.b ];
        face.c = changes[ face.c ];

        indices = [ face.a, face.b, face.c ];

        var dupIndex = -1;

        // if any duplicate vertices are found in a Face3
        // we have to remove the face as nothing can be saved
        for ( var n = 0; n < 3; n++ ) {

            if ( indices[ n ] === indices[ ( n + 1 ) % 3 ] ) {

                dupIndex = n;
                faceIndicesToRemove.push( i );
                break;

            }

        }

    }

    for ( i = faceIndicesToRemove.length - 1; i >= 0; i-- ) {

        var idx = faceIndicesToRemove[ i ];

        this.faces.splice( idx, 1 );

        for ( j = 0, jl = this.faceVertexUvs.length; j < jl; j++ ) {

            this.faceVertexUvs[ j ].splice( idx, 1 );

        }

    }

    // Use unique set of vertices

    var diff = this.vertices.length - unique.length;
    this.vertices = unique;
    return diff;

}

function loadTable( scene ) {
    var loader = new THREE.STLLoader();
    loader.load( 'D:/TestFiles/mesh_simple.stl', function ( geometry ) {


        var i, end, pos, newGeometry, indexVertex, numDeleted, rotator;

        pos = geometry.getAttribute( "position" );

        console.log( "Old mesh has " + pos.array.length + " vertices " );
        newGeometry = new THREE.Geometry();
        rotator = new THREE.Euler( -Math.PI / 2, 0, 0, 'XYZ' );

        indexVertex = -1;

        for ( i = 0, end = pos.array.length; i < end; i += 9 ) {

            newGeometry.vertices.push(
                (new THREE.Vector3( pos.array[ i ], pos.array[ i + 1 ], pos.array[ i + 2 ] )).applyEuler( rotator )
                , (new THREE.Vector3( pos.array[ i + 3 ], pos.array[ i + 4 ], pos.array[ i + 5 ] )).applyEuler( rotator )
                , (new THREE.Vector3( pos.array[ i + 6 ], pos.array[ i + 7 ], pos.array[ i + 8 ] )).applyEuler( rotator )
            );

            newGeometry.faces.push( new THREE.Face3( ++indexVertex, ++indexVertex, ++indexVertex ) );
        }

        console.log( "Old mesh has " + newGeometry.faces.length + " faces " );


        newGeometry.customMergeVertices = mergeVertices;

        numDeleted = newGeometry.customMergeVertices();
        console.log( numDeleted + " duplicate vertices deleted" );

        console.log( "New mesh has " + newGeometry.vertices.length + " vertices " );
        console.log( "New mesh has " + newGeometry.faces.length + " faces " );

        newGeometry.computeFaceNormals();
        newGeometry.computeVertexNormals( true );

        newGeometry.verticesNeedUpdate = true;
        newGeometry.elementsNeedUpdate = true;
        newGeometry.normalsNeedUpdate = true;

        for ( var i = 0; i < newGeometry.faces.length; ++i ) {

        }


        var material = new THREE.MeshPhongMaterial( { color: 0xAAAAAA, specular: 0x111111, shininess: 200 } );
        var mesh = new THREE.Mesh( newGeometry, material );

        var clusters = dbscan.run(newGeometry.vertices, 5, 4);
        console.log(clusters, dbscan.noise);

        //TODO: Test isolating meshes
        // var meshes = isolateMeshes( mesh );

        //meshes.sort( ( a, b ) => a.length - b.length );

        mesh.position.set( 0, 0, 0 );
        //mesh.rotation.set( -Math.PI / 2, 0, 0 );
        //mesh.scale.set( 0.1, 0.1, 0.1 );

        mesh.castShadow = true;
        mesh.receiveShadow = true;

        table = mesh;

        scene.add( mesh )

    } );

}

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

        this.scene.fog = new THREE.Fog( 0x72645b, 2, 15 );
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

        loadTable( this.scene )
        

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