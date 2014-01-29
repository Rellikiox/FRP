// Generated by CoffeeScript 1.7.0
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

ABM.AgentSet = (function(_super) {
  __extends(AgentSet, _super);

  AgentSet.asSet = function(a, setType) {
    var _ref;
    if (setType == null) {
      setType = ABM.AgentSet;
    }
    a.__proto__ = (_ref = setType.prototype) != null ? _ref : setType.constructor.prototype;
    return a;
  };

  function AgentSet(agentClass, name, mainSet) {
    this.agentClass = agentClass;
    this.name = name;
    this.mainSet = mainSet;
    AgentSet.__super__.constructor.call(this, 0);
    if (this.mainSet == null) {
      this.breeds = [];
    }
    this.agentClass.prototype.breed = this;
    this.ownVariables = [];
    if (this.mainSet == null) {
      this.ID = 0;
    }
  }

  AgentSet.prototype.create = function() {};

  AgentSet.prototype.add = function(o) {
    if (this.mainSet != null) {
      this.mainSet.add(o);
    } else {
      o.id = this.ID++;
    }
    this.push(o);
    return o;
  };

  AgentSet.prototype.remove = function(o) {
    if (this.mainSet != null) {
      u.removeItem(this.mainSet, o);
    }
    u.removeItem(this, o);
    return this;
  };

  AgentSet.prototype.setDefault = function(name, value) {
    this.agentClass.prototype[name] = value;
    return this;
  };

  AgentSet.prototype.own = function(vars) {
    var name, _i, _len, _ref;
    _ref = vars.split(" ");
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      name = _ref[_i];
      this.setDefault(name, null);
      this.ownVariables.push(name);
    }
    return this;
  };

  AgentSet.prototype.setBreed = function(a) {
    var k, proto, v;
    if (a.breed.mainSet != null) {
      u.removeItem(a.breed, a, "id");
    }
    if (this.mainSet != null) {
      u.insertItem(this, a, "id");
    }
    proto = a.__proto__ = this.agentClass.prototype;
    for (k in a) {
      if (!__hasProp.call(a, k)) continue;
      v = a[k];
      if (proto[k] != null) {
        delete a[k];
      }
    }
    return a;
  };

  AgentSet.prototype.exclude = function(breeds) {
    var o;
    breeds = breeds.split(" ");
    return this.asSet((function() {
      var _i, _len, _ref, _results;
      _results = [];
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        o = this[_i];
        if (_ref = o.breed.name, __indexOf.call(breeds, _ref) < 0) {
          _results.push(o);
        }
      }
      return _results;
    }).call(this));
  };

  AgentSet.prototype.floodFill = function(aset, fCandidate, fJoin, fNeighbors, asetLast) {
    var asetNext, n, p, _i, _j, _k, _len, _len1, _len2, _ref;
    if (asetLast == null) {
      asetLast = [];
    }
    for (_i = 0, _len = aset.length; _i < _len; _i++) {
      p = aset[_i];
      fJoin(p, asetLast);
    }
    asetNext = [];
    for (_j = 0, _len1 = aset.length; _j < _len1; _j++) {
      p = aset[_j];
      _ref = fNeighbors(p);
      for (_k = 0, _len2 = _ref.length; _k < _len2; _k++) {
        n = _ref[_k];
        if (fCandidate(n)) {
          if (asetNext.indexOf(n) < 0) {
            asetNext.push(n);
          }
        }
      }
    }
    if (asetNext.length > 0) {
      return this.floodFill(asetNext, fCandidate, fJoin, fNeighbors, aset);
    }
  };

  AgentSet.prototype.uniq = function() {
    return u.uniq(this);
  };

  AgentSet.prototype.asSet = function(a, setType) {
    if (setType == null) {
      setType = this;
    }
    return ABM.AgentSet.asSet(a, setType);
  };

  AgentSet.prototype.asOrderedSet = function(a) {
    return this.asSet(a).sortById();
  };

  AgentSet.prototype.toString = function() {
    var a;
    return "[" + ((function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        a = this[_i];
        _results.push(a.toString());
      }
      return _results;
    }).call(this)).join(", ") + "]";
  };

  AgentSet.prototype.getProp = function(prop) {
    var o, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      o = this[_i];
      _results.push(o[prop]);
    }
    return _results;
  };

  AgentSet.prototype.getPropWith = function(prop, value) {
    var o;
    return this.asSet((function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        o = this[_i];
        if (o[prop] === value) {
          _results.push(o);
        }
      }
      return _results;
    }).call(this));
  };

  AgentSet.prototype.setProp = function(prop, value) {
    var i, o, _i, _j, _len, _len1;
    if (u.isArray(value)) {
      for (i = _i = 0, _len = this.length; _i < _len; i = ++_i) {
        o = this[i];
        o[prop] = value[i];
      }
      return this;
    } else {
      for (_j = 0, _len1 = this.length; _j < _len1; _j++) {
        o = this[_j];
        o[prop] = value;
      }
      return this;
    }
  };

  AgentSet.prototype.maxProp = function(prop) {
    return u.aMax(this.getProp(prop));
  };

  AgentSet.prototype.minProp = function(prop) {
    return u.aMin(this.getProp(prop));
  };

  AgentSet.prototype.histOfProp = function(prop, bin) {
    if (bin == null) {
      bin = 1;
    }
    return u.histOf(this, bin, prop);
  };

  AgentSet.prototype.shuffle = function() {
    return u.shuffle(this);
  };

  AgentSet.prototype.sortById = function() {
    return u.sortBy(this, "id");
  };

  AgentSet.prototype.clone = function() {
    return this.asSet(u.clone(this));
  };

  AgentSet.prototype.last = function() {
    return u.last(this);
  };

  AgentSet.prototype.any = function() {
    return u.any(this);
  };

  AgentSet.prototype.other = function(a) {
    var o;
    return this.asSet((function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        o = this[_i];
        if (o !== a) {
          _results.push(o);
        }
      }
      return _results;
    }).call(this));
  };

  AgentSet.prototype.oneOf = function() {
    return u.oneOf(this);
  };

  AgentSet.prototype.nOf = function(n) {
    return this.asSet(u.nOf(this, n));
  };

  AgentSet.prototype.minOneOf = function(f, valueToo) {
    if (valueToo == null) {
      valueToo = false;
    }
    return u.minOneOf(this, f, valueToo);
  };

  AgentSet.prototype.maxOneOf = function(f, valueToo) {
    if (valueToo == null) {
      valueToo = false;
    }
    return u.maxOneOf(this, f, valueToo);
  };

  AgentSet.prototype.draw = function(ctx) {
    var o, _i, _len;
    u.clearCtx(ctx);
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      o = this[_i];
      if (!o.hidden) {
        o.draw(ctx);
      }
    }
    return null;
  };

  AgentSet.prototype.show = function() {
    var o, _i, _len;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      o = this[_i];
      o.hidden = false;
    }
    return this.draw(ABM.contexts[this.name]);
  };

  AgentSet.prototype.hide = function() {
    var o, _i, _len;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      o = this[_i];
      o.hidden = true;
    }
    return this.draw(ABM.contexts[this.name]);
  };

  AgentSet.prototype.inRadius = function(o, d, meToo) {
    var a, d2, h, w, x, y;
    if (meToo == null) {
      meToo = false;
    }
    d2 = d * d;
    x = o.x;
    y = o.y;
    if (ABM.patches.isTorus) {
      w = ABM.patches.numX;
      h = ABM.patches.numY;
      return this.asSet((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = this.length; _i < _len; _i++) {
          a = this[_i];
          if (u.torusSqDistance(x, y, a.x, a.y, w, h) <= d2 && (meToo || a !== o)) {
            _results.push(a);
          }
        }
        return _results;
      }).call(this));
    } else {
      return this.asSet((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = this.length; _i < _len; _i++) {
          a = this[_i];
          if (u.sqDistance(x, y, a.x, a.y) <= d2 && (meToo || a !== o)) {
            _results.push(a);
          }
        }
        return _results;
      }).call(this));
    }
  };

  AgentSet.prototype.inCone = function(o, heading, cone, radius, meToo) {
    var a, h, rSet, w, x, y;
    if (meToo == null) {
      meToo = false;
    }
    rSet = this.inRadius(o, radius, meToo);
    x = o.x;
    y = o.y;
    if (ABM.patches.isTorus) {
      w = ABM.patches.numX;
      h = ABM.patches.numY;
      return this.asSet((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = rSet.length; _i < _len; _i++) {
          a = rSet[_i];
          if ((a === o && meToo) || u.inTorusCone(heading, cone, radius, x, y, a.x, a.y, w, h)) {
            _results.push(a);
          }
        }
        return _results;
      })());
    } else {
      return this.asSet((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = rSet.length; _i < _len; _i++) {
          a = rSet[_i];
          if ((a === o && meToo) || u.inCone(heading, cone, radius, x, y, a.x, a.y)) {
            _results.push(a);
          }
        }
        return _results;
      })());
    }
  };

  AgentSet.prototype.ask = function(f) {
    var o, _i, _len;
    if (u.isString(f)) {
      eval("f=function(o){return " + f + ";}");
    }
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      o = this[_i];
      f(o);
    }
    return this;
  };

  AgentSet.prototype["with"] = function(f) {
    var o;
    if (u.isString(f)) {
      eval("f=function(o){return " + f + ";}");
    }
    return this.asSet((function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        o = this[_i];
        if (f(o)) {
          _results.push(o);
        }
      }
      return _results;
    }).call(this));
  };

  return AgentSet;

})(Array);
