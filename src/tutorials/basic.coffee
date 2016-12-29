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
# Stats = require "#{env.PATH.THREE}examples/js/libs/stats.min.js"
DBSCAN = require "#{env.PATH.LIB}DBSCAN"
#TWEEN = require "#{env.PATH.TWEEN}src/Tween"

do ->
  file = fs.readFileSync("#{env.PATH.THREE}examples/js/loaders/STLLoader.js", 'utf-8');      eval file
  file = fs.readFileSync("#{env.PATH.THREE}examples/js/loaders/3MFLoader.js", 'utf-8');      eval file
  file = fs.readFileSync("#{env.PATH.THREE}examples/js/loaders/OBJLoader.js", 'utf-8');      eval file
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


    @_control = new THREE.OrbitControls(@camera, @renderer.domElement)
    @_control.target = new THREE.Vector3(-7,0,7)
    @camera.lookAt(new THREE.Vector3(-7,0,7))

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
        "We use DBSCAN(kd-tree accelerated) for a more accurate table plane estimation follow with RANSAC. In my opinion & tested, use DBSCAN as K-MEANS substitution
        in the first step also works fine, the critical point is to choose a cluster that in line with our expectations.
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
        "After RANSAC, we have got the exact table plane equation: &lt;ax + by + cz + d = 0&gt;. Another half of
        our algorithm remained is to estimate table rectangle(if exist) out of model's convex hull.
        "
      group = new THREE.Group()
      planegeometry = new THREE.PlaneGeometry(10, 20)
      plane = new THREE.Mesh(planegeometry, new THREE.MeshBasicMaterial(color: 0x436EEE, side: THREE.DoubleSide, transparent: true))
      plane.rotation.x = Math.PI / 2
      plane.position.set(-7, 2.5, 9)
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

    if @_step is 6
      document.getElementById('text-step-describe').innerHTML =
        "We project points to plane &lt;ax + by + cz_d = 0&gt; which is computed before, then
        use OpenCV for constructing 2-D convex hull which is showed by <span style='color: lightgreen'>Green line.</span>
        "
      group = new THREE.Group()
      planegeometry = new THREE.PlaneGeometry(10, 20)
      plane = new THREE.Mesh(planegeometry, new THREE.MeshBasicMaterial(color: 0x436EEE, side: THREE.DoubleSide, transparent: true))
      plane.rotation.x = Math.PI / 2
      plane.position.set(-7, 2.5, 9)
      plane.material.opacity = 0.7
      group.add(plane)

      linegeometry = new THREE.Geometry()
      linepos =
        [ { x: -1.5199062824249268, y: 2.4417765140533447, z: 16.194272994995117 }
        , { x: -1.5199062824249268, y: 2.4417765140533447, z: 16.194272994995117 }
        , { x: -2.71992564201355, y: 2.3030941486358643, z: 2.663135528564453 }
        , { x: -2.8616158962249756, y: 2.4311020374298096, z: 0.8671684265136719 }

        , { x: -5.770935535430908, y: 2.50488543510437, z: 0.245237922668457 }
        , { x: -6.646801948547363, y: 2.5329926013946533, z: 0.1933300018310547 }
        , { x: -9.488754272460938, y: 2.5821444988250732, z: 0.4128446578979492 }
        , { x: -9.813177108764648, y: 2.472151517868042, z: 0.8701448440551758 }
        , { x: -11.813786506652832, y: 2.639867067337036, z: 9.216063499450684 }
        , { x: -12.006025314331055, y: 2.760622262954712, z: 14.193246841430664 }
        , { x: -8.203739166259766, y: 2.705040216445923, z: 17.43173599243164 }
        , { x: -4.479922771453857, y: 2.5549418926239014, z: 16.98052978515625 }
        , { x: -1.5199062824249268, y: 2.4417765140533447, z: 16.194272994995117 }
        ]

      spherematerial = new THREE.MeshToonMaterial(color: 0x00ff00)
      for pos in linepos
        pos = new THREE.Vector3(pos.x, pos.y, pos.z)
        linegeometry.vertices.push(pos)
        spheregeometry = new THREE.SphereGeometry(0.2)
        sphere = new THREE.Mesh(spheregeometry, spherematerial)
        sphere.position.set(pos.x, pos.y, pos.z)
        group.add(sphere)


      linematerial = new THREE.LineBasicMaterial(color: 0x00ff00, linewidth: 10, transparent: false)
      line = new THREE.Line(linegeometry, linematerial)
      group.add(line)

      @scene.add(group)
      @_rollback = =>
        @scene.remove(group)

    if @_step is 7
      document.getElementById('text-step-describe').innerHTML =
        "Based on convex hull, we can get wave-front edges.
        "
      group = new THREE.Group()
      linegeometry = new THREE.Geometry()
      linepos =
        [ { x: -1.5199062824249268, y: 2.4417765140533447, z: 16.194272994995117 }
        , { x: -1.5199062824249268, y: 2.4417765140533447, z: 16.194272994995117 }
        , { x: -2.71992564201355, y: 2.3030941486358643, z: 2.663135528564453 }
        , { x: -2.8616158962249756, y: 2.4311020374298096, z: 0.8671684265136719 }
        ]

      spherematerial = new THREE.MeshToonMaterial(color: 0x00ff00)
      for pos in linepos
        pos = new THREE.Vector3(pos.x, pos.y, pos.z)
        linegeometry.vertices.push(pos)
        spheregeometry = new THREE.SphereGeometry(0.2)
        sphere = new THREE.Mesh(spheregeometry, spherematerial)
        sphere.position.set(pos.x, pos.y, pos.z)
        group.add(sphere)


      linematerial = new THREE.LineBasicMaterial(color: 0x00ff00, linewidth: 10, transparent: false)
      line = new THREE.Line(linegeometry, linematerial)
      group.add(line)

      @scene.add(group)
      @_rollback = =>
        @scene.remove(group)

    if @_step is 8
      document.getElementById('text-step-describe').innerHTML =
        "Finally we compute the table rectangle with estimated height.
        "
      group = new THREE.Group()
      planegeometry = new THREE.PlaneGeometry(10, 16)
      plane = new THREE.Mesh(planegeometry, new THREE.MeshBasicMaterial(color: 0x8bc146, side: THREE.DoubleSide, transparent: true))
      plane.rotation.x = Math.PI / 2
      plane.rotation.z = - 0.08
      plane.position.set(-7, 2.5, 9)
      plane.material.opacity = 0.7
      group.add(plane)
      linegeometry = new THREE.Geometry()
      linepos =
        [ { x: -1.5199062824249268, y: 2.4417765140533447, z: 16.194272994995117 }
        , { x: -1.5199062824249268, y: 2.4417765140533447, z: 16.194272994995117 }
        , { x: -2.71992564201355, y: 2.3030941486358643, z: 2.663135528564453 }
        , { x: -2.8616158962249756, y: 2.4311020374298096, z: 0.8671684265136719 }
        ]

      spherematerial = new THREE.MeshToonMaterial(color: 0x00ff00)
      for pos in linepos
        pos = new THREE.Vector3(pos.x, pos.y, pos.z)
        linegeometry.vertices.push(pos)
        spheregeometry = new THREE.SphereGeometry(0.2)
        sphere = new THREE.Mesh(spheregeometry, spherematerial)
        sphere.position.set(pos.x, pos.y, pos.z)
        group.add(sphere)


      linematerial = new THREE.LineBasicMaterial(color: 0x00ff00, linewidth: 10, transparent: false)
      line = new THREE.Line(linegeometry, linematerial)
      group.add(line)

      @scene.add(group)
      @_rollback = =>
        @scene.remove(group)

    if @_step is 9
      document.getElementById('text-step-describe').innerHTML =
        "Final Effect.  Thank you for your patience : )
        "
      group = new THREE.Group()
      planegeometry = new THREE.PlaneGeometry(10, 16)
      plane = new THREE.Mesh(planegeometry, new THREE.MeshBasicMaterial(color: 0x436EEE, side: THREE.DoubleSide, transparent: true))
      plane.rotation.x = Math.PI / 2
      plane.rotation.z = - 0.08
      plane.position.set(-7, 2.5, 9)
      plane.material.opacity = 0.7
      group.add(plane)

      boxgeometry = new THREE.BoxGeometry( 10, 4, 16 )
      boxmaterial = new THREE.MeshBasicMaterial(color: 0x8bc146, transparent: true)
      boxmaterial.opacity = 0.7
      box = new THREE.Mesh(boxgeometry, boxmaterial)
      box.rotation.y = 0.09
      box.position.set(-7, 0.7, 9)
      group.add(box)

      @scene.add(group)
      @_rollback = =>
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
  # # Stats initialization
  # node = document.getElementById('stats-output')
  # while node.firstChild?
  #   node.removeChild(node.firstChild)
  # node.appendChild(stats.dom)

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
  # stats.update()
  return





# main
gldiv = document.getElementById('webgl-output')
guidiv = document.getElementById('tutorial-panel')
document.getElementById('btn-next')
# stats = new Stats()

tutorial = new Tutorial()
document.getElementById('btn-next').addEventListener('click', tutorial.next)
document.getElementById('btn-prev').addEventListener('click', tutorial.prev)


init()
animate()
