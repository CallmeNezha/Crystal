// Generated by CoffeeScript 1.12.2
(function() {
  var Function, clone,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  clone = require('clone');

  Function = (function() {
    var _describe;

    _describe = 'Function';

    function Function(name, call, params) {
      this.name = name;
      this.call = call;
      this.params = params;
      this.data = null;
      this._posts = new Set();
      this._pres = new Set();
      return this;
    }

    Function.prototype.Bind = function(func, pname) {
      if (func.params[pname] == null) {
        return false;
      }
    };

    Function.prototype.setout = function(func) {
      this._posts.add(func);
    };

    Function.prototype.SetIn = function(func) {
      this._pres.add(func);
    };

    Function.prototype.IsPrepared = function() {
      var pref;
      if (indexOf.call((function() {
        var i, len, ref, results;
        ref = this._pres;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          pref = ref[i];
          results.push(pref.data !== null);
        }
        return results;
      }).call(this), false) >= 0) {
        return false;
      }
      return true;
    };

    Function.prototype.Call = function() {
      var obj, p, paramap, results;
      paramap = this.params;
      results = [];
      for (p in paramap) {
        obj = paramap[p];
        results.push(paramap.p = obj.data);
      }
      return results;
    };

    return Function;

  })();

  if (typeof module !== "undefined" && module !== null) {
    module.exports = Function;
  }

}).call(this);
