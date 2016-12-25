//              ______    _____            _________       _____   _____
//            /     /_  /    /            \___    /      /    /__/    /
//           /        \/    /    ___        /    /      /            /    ___
//          /     / \      /    /\__\      /    /___   /    ___     /    /   \
//        _/____ /   \___ /    _\___     _/_______ / _/___ / _/___ /    _\___/\_
//        revised on 14/12/2016  All rights reserved by @NeZha

'use strict'

const env = require( '../../env' )
const fs = require( 'fs' )
const THREE = require( env.PATH.THREE + 'build/three.js' )
const DBSCAN = require( env.PATH.LIB + 'DBSCAN.js');

// Include non-commonjs module
{
    let file = fs.readFileSync( env.PATH.THREE + 'examples/js/loaders/STLLoader.js', 'utf-8' )
    eval( file )
    file = fs.readFileSync( env.PATH.THREE + 'examples/js/controls/OrbitControls.js', 'utf-8' )
    eval( file )
}

/** Orbit control */
let controls

/**
 * DBSCANTableExample class construcotr
 * @constructor
 * @returns {DBSCANTableExample}
 */

class DBSCANTableExample {
    constructor() {
        /** @type {TREE.Scene} */
        this.scene = new THREE.Scene()
        /** @type {TREE.PerspectiveCamera} */
        this.camera = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 0.01, 10000 )
        /** @type {TREE.Clock} */
        this.clock = new THREE.Clock()
        /** @type {Object} */
        this.objects = {}
    }

    /**
     * Merge vertices that almost have same position
     */
    mergeVertices() {

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
    /**
     * Get plane equation from normal and point
     * @param {THREE.Vector3} normal
     * @param {THREE.Vector3} point
     * @return {Array}
     */
    planeEquation( normal, point ) {

        let d = - ( point.dot( normal ) )
        return [ normal.x / d, normal.y / d, normal.z / d ]

    }

    /**
     * Cluster mesh facets use DBSCAN clustering
     * @param {THREE.Mesh} mesh
     */
    dbscanTable( mesh ) {

        let geometry = mesh.geometry
        let vtxs = geometry.vertices
        let faces = geometry.faces

        let cpl = []

        for (let face of faces) {

            let center = new THREE.Vector3( 0, 0, 0 )
            center.add( vtxs[ face.a ] ).add( vtxs[ face.b ] ).add( vtxs[ face.c ] ).divideScalar( 3 )
            cpl.push( this.planeEquation( face.normal, center ) )

        }

        let dbscan = new DBSCAN();
        var clusters = dbscan.run(cpl, 0.01, 10);
        console.log(clusters, dbscan.noise);

        for ( let clust of clusters ) {

            var color = Math.random() * 0xffffff
            for ( let idx of clust ) geometry.faces[ idx ].color.setHex( color )

        }

        var dcolor = 0x080000
        for ( let idx of dbscan.noise ) geometry.faces[ idx ].color.setHex( dcolor )

        mesh.material = new THREE.MeshBasicMaterial( { vertexColors: THREE.FaceColors } )

    }

    /**
     * Process mesh
     */
    loadTable() {

        let loader = new THREE.STLLoader();
            loader.load('/Users/jane/Documents/models/mesh_simple.stl', ( geometry ) => {

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

                    newGeometry.faces.push( new THREE.Face3( ++indexVertex, ++indexVertex, ++indexVertex ) )

                }

                console.log( "Old mesh has " + newGeometry.faces.length + " faces " );


                newGeometry.customMergeVertices = this.mergeVertices;

                numDeleted = newGeometry.customMergeVertices();
                console.log( numDeleted + " duplicate vertices deleted" );

                console.log( "New mesh has " + newGeometry.vertices.length + " vertices " );
                console.log( "New mesh has " + newGeometry.faces.length + " faces " );

                newGeometry.computeFaceNormals();
                newGeometry.computeVertexNormals( true );

                newGeometry.verticesNeedUpdate = true;
                newGeometry.elementsNeedUpdate = true;
                newGeometry.normalsNeedUpdate = true;


                var material = new THREE.MeshPhongMaterial( { color: 0xff5533, specular: 0x111111, shininess: 200 } );
                var mesh = new THREE.Mesh( newGeometry, material );

                //TODO: Test isolating meshes
                // var meshes = isolateMeshes( mesh );

                //meshes.sort( ( a, b ) => a.length - b.length );

                mesh.position.set( 0, 0, 0 );
                //mesh.rotation.set( -Math.PI / 2, 0, 0 );
                //mesh.scale.set( 0.1, 0.1, 0.1 );

                mesh.castShadow = true;
                mesh.receiveShadow = true;

                this.scene.add( mesh );
                this.objects["table"] = mesh;

                document.getElementById( "loading" ).style.display = 'none';

                var start = new Date();
                this.dbscanTable( mesh )
                console.log("dbscan over mesh used: "+ (new Date() - start) + " milliseconds")

            } )
    }

    /**
     * Initalize function called before first time rendering
     * @param {THREE.WebglRenderer} renderer
     */
    init( renderer ) {

        // Orbit controls

        controls = new THREE.OrbitControls( this.camera, renderer.domElement )
        controls.enableZoom = true

        this.scene.fog = new THREE.Fog( 0x72645b, 2, 150000 );
        renderer.setClearColor( this.scene.fog.color );

        renderer.gammaInput = true
        renderer.gammaOutput = true

        renderer.shadowMap.enabled = true
        renderer.shadowMap.renderReverseSided = false

        this.camera.position.set( 20, 3, 20 );
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

        // Load table
        this.loadTable()

        // Lights

        this.scene.add( new THREE.HemisphereLight( 0x443333, 0x111122 ) );

        // this.scene.add( new THREE.HemisphereLight( 0x443333, 0x111122 ) )
        this.addShadowedLight( 1, 1, 1, 0xffffff, 1.35 );
        this.addShadowedLight( 0.5, 1, -1, 0xffaa00, 1 );

    }

    /**
     * Called every time before rendering
     */
    onRender() {

        let dt = this.clock.getDelta()

        controls.update()

    }

    /**
     * Add some Lights
     */
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

    module.exports = DBSCANTableExample

}
