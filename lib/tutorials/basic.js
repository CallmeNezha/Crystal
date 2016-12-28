// Generated by CoffeeScript 1.12.2
(function() {
  var Stats, THREE, TWEEN, Tutorial, animate, env, fs, gldiv, guidiv, init, stats, tutorial,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  fs = require('fs');

  env = require('../../env');

  THREE = require(env.PATH.THREE + "build/three");

  Stats = require(env.PATH.THREE + "examples/js/libs/stats.min.js");

  TWEEN = require(env.PATH.TWEEN + "src/Tween");

  (function() {
    var file;
    file = fs.readFileSync(env.PATH.THREE + "examples/js/loaders/STLLoader.js", 'utf-8');
    eval(file);
    file = fs.readFileSync(env.PATH.THREE + "examples/js/loaders/3MFLoader.js", 'utf-8');
    eval(file);
    file = fs.readFileSync(env.PATH.THREE + "examples/js/loaders/OBJLoader.js", 'utf-8');
    eval(file);
    file = fs.readFileSync(env.PATH.THREE + "examples/js/controls/OrbitControls.js", 'utf-8');
    return eval(file);
  })();

  Tutorial = (function() {
    function Tutorial() {
      this.prev = bind(this.prev, this);
      this.next = bind(this.next, this);
      this.onWindowResize = bind(this.onWindowResize, this);
      this.renderer = new THREE.WebGLRenderer({
        antialias: false
      });
      this.scene = new THREE.Scene();
      this.camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.01, 10000);
      this.objects = {};
      this._control = null;
      this._step = 0;
      this._rollback = null;
    }

    Tutorial.prototype.init = function() {
      var axisHelper;
      this.renderer.setPixelRatio(window.devicePixelRatio);
      this.renderer.setSize(window.innerWidth, window.innerHeight);
      this.renderer.setClearColor(0xDBDBDB);
      this.renderer.gammaInput = true;
      this.renderer.gammaOutput = true;
      this.camera.position.set(12, 12, 0);
      this.camera.lookAt(new THREE.Vector3());
      this._control = new THREE.OrbitControls(this.camera, this.renderer.domElement);
      this._control.enableZoom = true;
      this._control.minPolarAngle = -2e308;
      this._control.maxPolarAngle = 2e308;
      this.scene.add(new THREE.HemisphereLight(0xffffbb, 0x080820, 1));
      this._addShadowedLight(1, 1, 1);
      this._loadTable();
      axisHelper = new THREE.AxisHelper(5);
      this.scene.add(axisHelper);
    };

    Tutorial.prototype.onWindowResize = function() {
      this.renderer.setSize(window.innerWidth, window.innerHeight);
      this.camera.aspect = window.innerWidth / window.innerHeight;
      this.camera.updateProjectionMatrix();
    };

    Tutorial.prototype.render = function(time) {
      this.renderer.render(this.scene, this.camera);
      TWEEN.update(time);
    };

    Tutorial.prototype.next = function(f) {
      var arrowHelper, group, i, idx, j, k, l, material, nor, normals, plane, pos, ref, ref1, ref2, ref3, table, vertices;
      table = this.objects['table'];
      vertices = table.geometry.getAttribute('position').array;
      normals = table.geometry.getAttribute('normal').array;
      if (typeof this._rollback === "function") {
        this._rollback();
      }
      if (f === 'LOL') {
        this._step--;
      } else {
        this._step++;
      }
      if (this._step === 1) {
        document.getElementById('text-step-describe').innerHTML = "First we use K-Means clustering the vertices by its normal. So we can get the clusters with its center(cluster center).";
        group = new THREE.Group();
        for (idx = i = 0, ref = vertices.length; i < ref; idx = i += 30) {
          pos = new THREE.Vector3(vertices[idx], vertices[idx + 1], vertices[idx + 2]);
          nor = new THREE.Vector3(normals[idx], normals[idx + 1], normals[idx + 2]);
          arrowHelper = new THREE.ArrowHelper(nor, pos, 0.7, new THREE.Color(nor.x, nor.y, nor.z));
          group.updateMatrixWorld(true);
          group.add(arrowHelper);
        }
        this.scene.add(group);
        this._rollback = (function(_this) {
          return function() {
            return _this.scene.remove(group);
          };
        })(this);
      }
      if (this._step === 2) {
        document.getElementById('text-step-describe').innerHTML = "So we have the clusters with its center(cluster center), we can campared each cluster\'s center with WORLD Upward direction which is prior known as (0, 1, 0) and choose a best cluster as our best-fit candidate.";
        group = new THREE.Group();
        for (idx = j = 0, ref1 = vertices.length; j < ref1; idx = j += 30) {
          pos = new THREE.Vector3(vertices[idx], vertices[idx + 1], vertices[idx + 2]);
          nor = new THREE.Vector3(normals[idx], normals[idx + 1], normals[idx + 2]);
          if (nor.dot(new THREE.Vector3(0, 1, 0)) < 0.7) {
            continue;
          }
          arrowHelper = new THREE.ArrowHelper(nor, pos, 0.7, new THREE.Color(nor.x, nor.y, nor.z));
          group.updateMatrixWorld(true);
          group.add(arrowHelper);
        }
        this.scene.add(group);
        this._rollback = (function(_this) {
          return function() {
            return _this.scene.remove(group);
          };
        })(this);
      }
      if (this._step === 3) {
        document.getElementById('text-step-describe').innerHTML = "Now we have a better vertices' group to work with which more likely be the vertices lay upon the table. We use K-MEANS again to cluster them in \"cluster center direction\"(project them into one dimension with respect to its cluster center). You can think this as cluster against Table's Upward Direction. Then we can get rid of other \"Noise\" in the model.";
        group = new THREE.Group();
        for (idx = k = 0, ref2 = vertices.length; k < ref2; idx = k += 30) {
          pos = new THREE.Vector3(vertices[idx], vertices[idx + 1], vertices[idx + 2]);
          nor = new THREE.Vector3(normals[idx], normals[idx + 1], normals[idx + 2]);
          if (nor.dot(new THREE.Vector3(0, 1, 0)) < 0.7 || pos.y > 3.0 || pos.y < 1.3) {
            continue;
          }
          arrowHelper = new THREE.ArrowHelper(nor, pos, 0.7, new THREE.Color(nor.x, nor.y, nor.z));
          group.updateMatrixWorld(true);
          group.add(arrowHelper);
        }
        this.scene.add(group);
        this._rollback = (function(_this) {
          return function() {
            return _this.scene.remove(group);
          };
        })(this);
      }
      if (this._step === 4) {
        document.getElementById('text-step-describe').innerHTML = "Now we have a better vertices' group to work with which more likely be the vertices lay upon the table. We use K-MEANS again to cluster them in \"cluster center direction\"(project them into one dimension with respect to its cluster center). You can think this as cluster against Table's Upward Direction. Then we can get rid of other \"Noise\" in the model.";
        group = new THREE.Group();
        for (idx = l = 0, ref3 = vertices.length; l < ref3; idx = l += 30) {
          pos = new THREE.Vector3(vertices[idx], vertices[idx + 1], vertices[idx + 2]);
          nor = new THREE.Vector3(normals[idx], normals[idx + 1], normals[idx + 2]);
          if (nor.dot(new THREE.Vector3(0, 1, 0)) < 0.7 || pos.y > 3.0 || pos.y < 1.3) {
            continue;
          }
          plane = new THREE.PlaneGeometry(0.4, 0.4);
          material = new THREE.MeshBasicMaterial({
            color: 0xffff00,
            side: THREE.DoubleSide
          });
          plane = new THREE.Mesh(geometry, material);
          plane.position.set(pos);
          group.updateMatrixWorld(true);
          group.add(plane);
        }
        this.scene.add(group);
        return this._rollback = (function(_this) {
          return function() {
            return _this.scene.remove(group);
          };
        })(this);
      }
    };

    Tutorial.prototype.prev = function() {
      return this.next('LOL');
    };

    Tutorial.prototype._addShadowedLight = function(x, y, z, d, color, intensity) {
      var directLight;
      if (d == null) {
        d = 10000;
      }
      if (color == null) {
        color = 0xffffbb;
      }
      if (intensity == null) {
        intensity = 1;
      }
      directLight = new THREE.DirectionalLight(color, intensity);
      directLight.position.set(x, y, z);
      this.scene.add(directLight);
    };

    Tutorial.prototype._loadTable = function() {
      var loader;
      loader = new THREE.STLLoader();
      return loader.load('d:/TestFiles/mesh_simple.stl', (function(_this) {
        return function(geometry) {
          var material, mesh;
          material = new THREE.MeshPhongMaterial({
            color: 0x24426b,
            specular: 0x1111111,
            shininess: 2
          });
          mesh = new THREE.Mesh(geometry, material);
          geometry.computeFaceNormals();
          geometry.computeVertexNormals(true);
          geometry.verticesNeedUpdate = true;
          geometry.elementsNeedUpdate = true;
          geometry.normalsNeedUpdate = true;
          _this.scene.add(mesh);
          return _this.objects["table"] = mesh;
        };
      })(this));
    };

    return Tutorial;

  })();

  init = function() {
    var node;
    node = document.getElementById('stats-output');
    while (node.firstChild != null) {
      node.removeChild(node.firstChild);
    }
    node.appendChild(stats.dom);
    node = document.getElementById('webgl-output');
    while (node.firstChild != null) {
      node.removeChild(node.firstChild);
    }
    node.appendChild(typeof tutorial !== "undefined" && tutorial !== null ? tutorial.renderer.domElement : void 0);
    window.addEventListener('resize', typeof tutorial !== "undefined" && tutorial !== null ? tutorial.onWindowResize : void 0, false);
    window.addEventListener('close', typeof tutorial !== "undefined" && tutorial !== null ? tutorial.onWindowClose : void 0, false);
    if (typeof tutorial !== "undefined" && tutorial !== null) {
      tutorial.init(document.getElementById('tutorial-panel'));
    }
  };

  animate = function(time) {
    requestAnimationFrame(animate);
    if (typeof tutorial !== "undefined" && tutorial !== null) {
      tutorial.render(time);
    }
    stats.update();
  };

  gldiv = document.getElementById('webgl-output');

  guidiv = document.getElementById('tutorial-panel');

  document.getElementById('btn-next');

  stats = new Stats();

  tutorial = new Tutorial();

  document.getElementById('btn-next').addEventListener('click', tutorial.next);

  document.getElementById('btn-prev').addEventListener('click', tutorial.prev);

  init();

  animate();

}).call(this);

//# sourceMappingURL=basic.js.map