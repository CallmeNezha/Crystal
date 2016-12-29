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
DBSCAN = require "#{env.PATH.LIB}DBSCAN"
#TWEEN = require "#{env.PATH.TWEEN}src/Tween"

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
    # TWEEN.update(time)
    return

  next: (f) =>
    table = @objects['table']
    faces = table.geometry.faces
    vertices = table.geometry.vertices
    @_rollback?()
    if f is 'LOL' then @_step--  else @_step++

    if @_step is 1
      document.getElementById('text-step-describe').innerHTML = 
        "First we use K-Means clustering the vertices by its normal. 
        So we can get the clusters with its center(cluster center).
        "
      group = new THREE.Group()
      for idx in [0...faces.length] by 6
        face = faces[idx]
        nor = face.normal
        pos = vertices[face.a]
        arrowHelper = new THREE.ArrowHelper(nor, pos, 0.7, new THREE.Color(nor.x, nor.y, nor.z))
        group.updateMatrixWorld(true)
        group.add(arrowHelper)
      @scene.add(group)
      @_rollback = =>
        @scene.remove(group)

    if @_step is 2
      document.getElementById('text-step-describe').innerHTML = 
        "Since we have the clusters with its center(cluster center), we can campared each cluster\'s center
        with WORLD Upward direction which is prior known as (0, 1, 0) and choose a best cluster as our
        best-fit candidate.
        "
      group = new THREE.Group()
      for idx in [0...faces.length] by 3
        face = faces[idx]
        nor = face.normal
        continue if nor.dot(new THREE.Vector3(0,1,0)) < 0.7
        pos = vertices[face.a]
        if pos.y > 3.0 or pos.y < 1.3
          arrowHelper = new THREE.ArrowHelper(nor, pos, 0.7, new THREE.Color(1, 0.1, 0.1))
        else
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
      for idx in [0...faces.length] by 2
        face = faces[idx]
        nor = face.normal
        pos = vertices[face.a]
        
        continue if nor.dot(new THREE.Vector3(0,1,0)) < 0.7 or pos.y > 3.0 or pos.y < 1.3
        arrowHelper = new THREE.ArrowHelper(nor, pos, 0.7, new THREE.Color(nor.x, nor.y, nor.z))
        group.updateMatrixWorld(true)
        group.add(arrowHelper)
      @scene.add(group)
      @_rollback = =>
        @scene.remove(group)

    if @_step is 4
      document.getElementById('text-step-describe').innerHTML = 
        "We use DBSCAN for a more accurate table plane estimation.
        "
      group = new THREE.Group()
      for idx in [0...faces.length] by 2
        face = faces[idx]
        nor = face.normal
        pos = vertices[face.a]
        
        continue if nor.dot(new THREE.Vector3(0,1,0)) < 0.98 or pos.y > 3.0 or pos.y < 1.3
        arrowHelper = new THREE.ArrowHelper(nor, pos, 0.7, new THREE.Color(nor.x, nor.y, nor.z))
        group.updateMatrixWorld(true)
        group.add(arrowHelper)
      @scene.add(group)
      @_dbscanTable(@objects['table'])
      @_rollback = =>
        @objects['table'].material = new THREE.MeshPhongMaterial(color: 0x24426b, specular: 0x1111111, shininess: 2)
        @objects['table'].geometry.elementsNeedUpdate = true
        @scene.remove(group)

    if @_step is 5
      document.getElementById('text-step-describe').innerHTML = 
        "After all these, we have got the accurate table plane equation: <ax + by + cz + d = 0>. Another half of
        our algorithm remained is to estimate table rectangle(if exist) out of model's convex hull.
        "
      group = new THREE.Group()
      planegeometry = new THREE.PlaneGeometry(10, 20)
      plane = new THREE.Mesh(planegeometry, new THREE.MeshBasicMaterial( {color: 0x436EEE, side: THREE.DoubleSide} ))
      plane.rotation.x = Math.PI / 2
      plane.position.set(-7, 2.5, 9)
      plane.material.transparent = true
      plane.material.opacity = 0.7
      group.add(plane)
      for idx in [0...faces.length] by 2
        face = faces[idx]
        nor = face.normal
        pos = vertices[face.a]
        
        continue if nor.dot(new THREE.Vector3(0,1,0)) < 0.98 or pos.y > 3.0 or pos.y < 1.3
        arrowHelper = new THREE.ArrowHelper(nor, pos, 0.7, new THREE.Color(nor.x, nor.y, nor.z))
        group.updateMatrixWorld(true)
        group.add(arrowHelper)
      @scene.add(group)
      @_dbscanTable(@objects['table'])
      @_rollback = =>
        @objects['table'].material = new THREE.MeshPhongMaterial(color: 0x24426b, specular: 0x1111111, shininess: 2)
        @objects['table'].geometry.elementsNeedUpdate = true
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
    loader.load("#{env.PATH.ROOT}mesh_simple.stl", (geometry) => 

      pos = geometry.getAttribute('position')

      newGeometry = new THREE.Geometry();
      indexVertex = -1;
      for i in [0...pos.array.length] by 9
        newGeometry.vertices.push(
            (new THREE.Vector3( pos.array[ i ], pos.array[ i + 1 ], pos.array[ i + 2 ] ))
            , (new THREE.Vector3( pos.array[ i + 3 ], pos.array[ i + 4 ], pos.array[ i + 5 ] ))
            , (new THREE.Vector3( pos.array[ i + 6 ], pos.array[ i + 7 ], pos.array[ i + 8 ] ))
        )
        newGeometry.faces.push( new THREE.Face3( ++indexVertex, ++indexVertex, ++indexVertex ) )

      console.log( "Old mesh has " + newGeometry.faces.length + " faces " )

      newGeometry.customMergeVertices = @_mergeVertices
      numDeleted = newGeometry.customMergeVertices()
      console.log( numDeleted + " duplicate vertices deleted" )

      console.log( "New mesh has " + newGeometry.vertices.length + " vertices " )
      console.log( "New mesh has " + newGeometry.faces.length + " faces " )

      newGeometry.computeFaceNormals()
      newGeometry.computeVertexNormals(true)

      material = new THREE.MeshPhongMaterial(color: 0x24426b, specular: 0x1111111, shininess: 2)
      mesh = new THREE.Mesh(newGeometry, material)
      geometry.verticesNeedUpdate = true
      geometry.elementsNeedUpdate = true
      geometry.normalsNeedUpdate = true

      @scene.add(mesh)
      @objects["table"] = mesh
      )

  _dbscanTable: (mesh) ->
    geometry = mesh.geometry
    vtxs = geometry.vertices
    faces = geometry.faces

    cpl = []

    for face in faces
      center = new THREE.Vector3( 0, 0, 0 )
      center.add( vtxs[ face.a ] ).add( vtxs[ face.b ] ).add( vtxs[ face.c ] ).divideScalar( 3 )
      cpl.push( @_planeEquation( face.normal, center ) )


    dbscan = new DBSCAN();
    clusters = dbscan.run(cpl, 0.01, 10)
    console.log(clusters)
    for clust in clusters
      color = Math.random() * 0xffffff
      for idx in clust
        geometry.faces[idx].color.setHex(color)


    dcolor = 0x080000
    for idx in dbscan.noise
      geometry.faces[ idx ].color.setHex(dcolor)

    mesh.material = new THREE.MeshBasicMaterial(vertexColors: THREE.FaceColors)
    mesh.material.needsUpdate = true
    geometry.elementsNeedUpdate = true
  
  _planeEquation: (normal, point)  ->
    d = - ( point.dot( normal ) )
    return [ normal.x / d, normal.y / d, normal.z / d ]

  Tutorial.prototype._mergeVertices =
    ``` function() {
      var verticesMap = {}; // Hashmap for looking up vertices by position coordinates (and making sure they are unique)
      var unique = [], changes = [];

      var v, key;
      var precisionPoints = 3; // number of decimal points, e.g. 4 for epsilon of 0.001
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
    }```


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