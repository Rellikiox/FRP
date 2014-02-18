// Generated by CoffeeScript 1.7.1
var root, u, _base,
  __hasProp = {}.hasOwnProperty,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
  __slice = [].slice;

this.ABM = {};

root = this;

(function() {
  var vendor, _i, _len, _ref;
  this.requestAnimFrame = this.requestAnimationFrame || null;
  this.cancelAnimFrame = this.cancelAnimationFrame || null;
  _ref = ['ms', 'moz', 'webkit', 'o'];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    vendor = _ref[_i];
    if (!(!this.requestAnimFrame)) {
      continue;
    }
    this.requestAnimFrame || (this.requestAnimFrame = this[vendor + 'RequestAnimationFrame']);
    this.cancelAnimFrame || (this.cancelAnimFrame = this[vendor + 'CancelAnimationFrame']);
    this.cancelAnimFrame || (this.cancelAnimFrame = this[vendor + 'CancelRequestAnimationFrame']);
  }
  this.requestAnimFrame || (this.requestAnimFrame = function(callback) {
    return this.setTimeout(callback, 1000 / 60);
  });
  return this.cancelAnimFrame || (this.cancelAnimFrame = function(id) {
    return this.clearTimeout(id);
  });
})();

(_base = Array.prototype).indexOf || (_base.indexOf = function(item) {
  var i, x;
  if ((function() {
    var _i, _len, _results;
    _results = [];
    for (i = _i = 0, _len = this.length; _i < _len; i = ++_i) {
      x = this[i];
      _results.push(x === item);
    }
    return _results;
  }).call(this)) {
    return i;
  }
  return -1;
});

ABM.util = u = {
  error: function(s) {
    throw new Error(s);
  },
  MaxINT: Math.pow(2, 53),
  MinINT: -Math.pow(2, 53),
  MaxINT32: 0 | 0x7fffffff,
  MinINT32: 0 | 0x80000000,
  isArray: Array.isArray || function(obj) {
    return !!(obj && obj.concat && obj.unshift && !obj.callee);
  },
  isFunction: function(obj) {
    return !!(obj && obj.constructor && obj.call && obj.apply);
  },
  isString: function(obj) {
    return !!(obj === '' || (obj && obj.charCodeAt && obj.substr));
  },
  randomSeed: function(seed) {
    if (seed == null) {
      seed = 123456;
    }
    return Math.random = function() {
      var x;
      x = Math.sin(seed++) * 10000;
      return x - Math.floor(x);
    };
  },
  randomInt: function(max) {
    return Math.floor(Math.random() * max);
  },
  randomInt2: function(min, max) {
    return min + Math.floor(Math.random() * (max - min));
  },
  randomNormal: function(mean, sigma) {
    var norm, u1, u2;
    if (mean == null) {
      mean = 0.0;
    }
    if (sigma == null) {
      sigma = 1.0;
    }
    u1 = 1.0 - Math.random();
    u2 = Math.random();
    norm = Math.sqrt(-2.0 * Math.log(u1)) * Math.cos(2.0 * Math.PI * u2);
    return norm * sigma + mean;
  },
  randomFloat: function(max) {
    return Math.random() * max;
  },
  randomFloat2: function(min, max) {
    return min + Math.random() * (max - min);
  },
  randomCentered: function(r) {
    return this.randomFloat2(-r / 2, r / 2);
  },
  log10: function(n) {
    return Math.log(n) / Math.LN10;
  },
  logN: function(n, base) {
    return Math.log(n) / Math.log(base);
  },
  ln: function(n) {
    return Math.log(n);
  },
  mod: function(v, n) {
    return ((v % n) + n) % n;
  },
  wrap: function(v, min, max) {
    return min + this.mod(v - min, max - min);
  },
  clamp: function(v, min, max) {
    return Math.max(Math.min(v, max), min);
  },
  sign: function(v) {
    if (v < 0) {
      return -1;
    } else {
      return 1;
    }
  },
  fixed: function(n, p) {
    if (p == null) {
      p = 2;
    }
    p = Math.pow(10, p);
    return Math.round(n * p) / p;
  },
  aToFixed: function(a, p) {
    var i, _i, _len, _results;
    if (p == null) {
      p = 2;
    }
    _results = [];
    for (_i = 0, _len = a.length; _i < _len; _i++) {
      i = a[_i];
      _results.push(i.toFixed(p));
    }
    return _results;
  },
  tls: function(n) {
    return n.toLocaleString();
  },
  randomColor: function(c) {
    var i, _i;
    if (c == null) {
      c = [];
    }
    if (c.str != null) {
      c.str = null;
    }
    for (i = _i = 0; _i <= 2; i = ++_i) {
      c[i] = this.randomInt(256);
    }
    return c;
  },
  randomGray: function(c, min, max) {
    var i, r, _i;
    if (c == null) {
      c = [];
    }
    if (min == null) {
      min = 64;
    }
    if (max == null) {
      max = 192;
    }
    if (arguments.length === 2) {
      return this.randomGray(null, c, min);
    }
    if (c.str != null) {
      c.str = null;
    }
    r = this.randomInt2(min, max);
    for (i = _i = 0; _i <= 2; i = ++_i) {
      c[i] = r;
    }
    return c;
  },
  randomMapColor: function(c, set) {
    if (c == null) {
      c = [];
    }
    if (set == null) {
      set = [0, 63, 127, 191, 255];
    }
    return this.setColor(c, this.oneOf(set), this.oneOf(set), this.oneOf(set));
  },
  randomBrightColor: function(c) {
    if (c == null) {
      c = [];
    }
    return this.randomMapColor(c, [0, 127, 255]);
  },
  setColor: function(c, r, g, b, a) {
    if (c.str != null) {
      c.str = null;
    }
    c[0] = r;
    c[1] = g;
    c[2] = b;
    if (a != null) {
      c[3] = a;
    }
    return c;
  },
  setGray: function(c, g, a) {
    return this.setColor(c, g, g, g, a);
  },
  scaleColor: function(max, s, c) {
    var i, val, _i, _len;
    if (c == null) {
      c = [];
    }
    if (c.str != null) {
      c.str = null;
    }
    for (i = _i = 0, _len = max.length; _i < _len; i = ++_i) {
      val = max[i];
      c[i] = this.clamp(Math.round(val * s), 0, 255);
    }
    return c;
  },
  colorStr: function(c) {
    var s;
    if ((s = c.str) != null) {
      return s;
    }
    if (c.length === 4 && c[3] > 1) {
      this.error("alpha > 1");
    }
    return c.str = c.length === 3 ? "rgb(" + c + ")" : "rgba(" + c + ")";
  },
  colorsEqual: function(c1, c2) {
    return c1.toString() === c2.toString();
  },
  rgbToGray: function(c) {
    return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2];
  },
  rgbToHsb: function(c) {
    var b, d, g, h, max, min, r, s, v;
    r = c[0] / 255;
    g = c[1] / 255;
    b = c[2] / 255;
    max = Math.max(r, g, b);
    min = Math.min(r, g, b);
    v = max;
    h = 0;
    d = max - min;
    s = max === 0 ? 0 : d / max;
    if (max !== min) {
      switch (max) {
        case r:
          h = (g - b) / d + (g < b ? 6 : 0);
          break;
        case g:
          h = (b - r) / d + 2;
          break;
        case b:
          h = (r - g) / d + 4;
      }
    }
    return [Math.round(255 * h / 6), Math.round(255 * s), Math.round(255 * v)];
  },
  hsbToRgb: function(c) {
    var b, f, g, h, i, p, q, r, s, t, v;
    h = c[0] / 255;
    s = c[1] / 255;
    v = c[2] / 255;
    i = Math.floor(h * 6);
    f = h * 6 - i;
    p = v * (1 - s);
    q = v * (1 - f * s);
    t = v * (1 - (1 - f) * s);
    switch (i % 6) {
      case 0:
        r = v;
        g = t;
        b = p;
        break;
      case 1:
        r = q;
        g = v;
        b = p;
        break;
      case 2:
        r = p;
        g = v;
        b = t;
        break;
      case 3:
        r = p;
        g = q;
        b = v;
        break;
      case 4:
        r = t;
        g = p;
        b = v;
        break;
      case 5:
        r = v;
        g = p;
        b = q;
    }
    return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
  },
  rgbMap: function(R, G, B) {
    var b, g, i, map, r, _i, _j, _k, _len, _len1, _len2;
    if (G == null) {
      G = R;
    }
    if (B == null) {
      B = R;
    }
    if (typeof R === "number") {
      R = (function() {
        var _i, _results;
        _results = [];
        for (i = _i = 0; 0 <= R ? _i < R : _i > R; i = 0 <= R ? ++_i : --_i) {
          _results.push(Math.round(i * 255 / (R - 1)));
        }
        return _results;
      })();
    }
    if (typeof G === "number") {
      G = (function() {
        var _i, _results;
        _results = [];
        for (i = _i = 0; 0 <= G ? _i < G : _i > G; i = 0 <= G ? ++_i : --_i) {
          _results.push(Math.round(i * 255 / (G - 1)));
        }
        return _results;
      })();
    }
    if (typeof B === "number") {
      B = (function() {
        var _i, _results;
        _results = [];
        for (i = _i = 0; 0 <= B ? _i < B : _i > B; i = 0 <= B ? ++_i : --_i) {
          _results.push(Math.round(i * 255 / (B - 1)));
        }
        return _results;
      })();
    }
    map = [];
    for (_i = 0, _len = R.length; _i < _len; _i++) {
      r = R[_i];
      for (_j = 0, _len1 = G.length; _j < _len1; _j++) {
        g = G[_j];
        for (_k = 0, _len2 = B.length; _k < _len2; _k++) {
          b = B[_k];
          map.push([r, g, b]);
        }
      }
    }
    return map;
  },
  grayMap: function() {
    var i, _i, _results;
    _results = [];
    for (i = _i = 0; _i <= 255; i = ++_i) {
      _results.push([i, i, i]);
    }
    return _results;
  },
  hsbMap: function(n, s, b) {
    var i, _i, _results;
    if (n == null) {
      n = 256;
    }
    if (s == null) {
      s = 255;
    }
    if (b == null) {
      b = 255;
    }
    _results = [];
    for (i = _i = 0; 0 <= n ? _i < n : _i > n; i = 0 <= n ? ++_i : --_i) {
      _results.push(this.hsbToRgb([i * 255 / (n - 1), s, b]));
    }
    return _results;
  },
  gradientMap: function(nColors, stops, locs) {
    var ctx, grad, i, id, _i, _j, _ref, _ref1, _results;
    if (locs == null) {
      locs = (function() {
        var _i, _ref, _results;
        _results = [];
        for (i = _i = 0, _ref = stops.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          _results.push(i / (stops.length - 1));
        }
        return _results;
      })();
    }
    ctx = this.createCtx(nColors, 1);
    grad = ctx.createLinearGradient(0, 0, nColors, 0);
    for (i = _i = 0, _ref = stops.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      grad.addColorStop(locs[i], this.colorStr(stops[i]));
    }
    ctx.fillStyle = grad;
    ctx.fillRect(0, 0, nColors, 1);
    id = this.ctxToImageData(ctx).data;
    _results = [];
    for (i = _j = 0, _ref1 = id.length; _j < _ref1; i = _j += 4) {
      _results.push([id[i], id[i + 1], id[i + 2]]);
    }
    return _results;
  },
  isLittleEndian: function() {
    var d32;
    d32 = new Uint32Array([0x01020304]);
    return (new Uint8ClampedArray(d32.buffer))[0] === 4;
  },
  degToRad: function(degrees) {
    return degrees * Math.PI / 180;
  },
  radToDeg: function(radians) {
    return radians * 180 / Math.PI;
  },
  subtractRads: function(rad1, rad2) {
    var PI, dr;
    dr = rad1 - rad2;
    PI = Math.PI;
    if (dr <= -PI) {
      dr += 2 * PI;
    }
    if (dr > PI) {
      dr -= 2 * PI;
    }
    return dr;
  },
  ownKeys: function(obj) {
    var key, value, _results;
    _results = [];
    for (key in obj) {
      if (!__hasProp.call(obj, key)) continue;
      value = obj[key];
      _results.push(key);
    }
    return _results;
  },
  ownVarKeys: function(obj) {
    var key, value, _results;
    _results = [];
    for (key in obj) {
      if (!__hasProp.call(obj, key)) continue;
      value = obj[key];
      if (!this.isFunction(value)) {
        _results.push(key);
      }
    }
    return _results;
  },
  ownValues: function(obj) {
    var key, value, _results;
    _results = [];
    for (key in obj) {
      if (!__hasProp.call(obj, key)) continue;
      value = obj[key];
      _results.push(value);
    }
    return _results;
  },
  parseToPrimitive: function(s) {
    var e;
    try {
      return JSON.parse(s);
    } catch (_error) {
      e = _error;
      return decodeURIComponent(s);
    }
  },
  parseQueryString: function(query) {
    var res, s, t, _i, _len, _ref;
    if (query == null) {
      query = window.location.search.substring(1);
    }
    res = {};
    _ref = query.split("&");
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      s = _ref[_i];
      if (!(query.length !== 0)) {
        continue;
      }
      t = s.split("=");
      res[t[0]] = t.length === 1 ? true : this.parseToPrimitive(t[1]);
    }
    return res;
  },
  any: function(array) {
    return array.length !== 0;
  },
  empty: function(array) {
    return array.length === 0;
  },
  clone: function(array, begin, end) {
    var op;
    op = array.slice != null ? "slice" : "subarray";
    if (begin != null) {
      return array[op](begin, end);
    } else {
      return array[op](0);
    }
  },
  last: function(array) {
    if (this.empty(array)) {
      this.error("last: empty array");
    }
    return array[array.length - 1];
  },
  oneOf: function(array) {
    if (this.empty(array)) {
      this.error("oneOf: empty array");
    }
    return array[this.randomInt(array.length)];
  },
  nOf: function(array, n) {
    var o, r;
    n = Math.min(array.length, Math.floor(n));
    r = [];
    while (r.length < n) {
      o = this.oneOf(array);
      if (__indexOf.call(r, o) < 0) {
        r.push(o);
      }
    }
    return r;
  },
  contains: function(array, item, f) {
    return this.indexOf(array, item, f) >= 0;
  },
  removeItem: function(array, item, f) {
    var i;
    if (!((i = this.indexOf(array, item, f)) < 0)) {
      return array.splice(i, 1);
    } else {
      return this.error("removeItem: item not found");
    }
  },
  removeItems: function(array, items, f) {
    var i, _i, _len;
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      this.removeItem(array, i, f);
    }
    return array;
  },
  insertItem: function(array, item, f) {
    var i;
    i = this.sortedIndex(array, item, f);
    if (array[i] === item) {
      error("insertItem: item already in array");
    }
    return array.splice(i, 0, item);
  },
  shuffle: function(array) {
    return array.sort(function() {
      return 0.5 - Math.random();
    });
  },
  minOneOf: function(array, f, valueToo) {
    var a, o, r, r1, _i, _len;
    if (f == null) {
      f = this.identity;
    }
    if (valueToo == null) {
      valueToo = false;
    }
    if (this.empty(array)) {
      this.error("minOneOf: empty array");
    }
    r = Infinity;
    o = null;
    if (this.isString(f)) {
      f = this.propFcn(f);
    }
    for (_i = 0, _len = array.length; _i < _len; _i++) {
      a = array[_i];
      if ((r1 = f(a)) < r) {
        r = r1;
        o = a;
      }
    }
    if (valueToo) {
      return [o, r];
    } else {
      return o;
    }
  },
  maxOneOf: function(array, f, valueToo) {
    var a, o, r, r1, _i, _len;
    if (f == null) {
      f = this.identity;
    }
    if (valueToo == null) {
      valueToo = false;
    }
    if (this.empty(array)) {
      this.error("maxOneOf: empty array");
    }
    r = -Infinity;
    o = null;
    if (this.isString(f)) {
      f = this.propFcn(f);
    }
    for (_i = 0, _len = array.length; _i < _len; _i++) {
      a = array[_i];
      if ((r1 = f(a)) > r) {
        r = r1;
        o = a;
      }
    }
    if (valueToo) {
      return [o, r];
    } else {
      return o;
    }
  },
  firstOneOf: function(array, f) {
    var a, i, _i, _len;
    for (i = _i = 0, _len = array.length; _i < _len; i = ++_i) {
      a = array[i];
      if (f(a)) {
        return i;
      }
    }
    return -1;
  },
  histOf: function(array, bin, f) {
    var a, i, r, ri, val, _i, _j, _len, _len1;
    if (bin == null) {
      bin = 1;
    }
    if (f == null) {
      f = function(i) {
        return i;
      };
    }
    r = [];
    if (this.isString(f)) {
      f = this.propFcn(f);
    }
    for (_i = 0, _len = array.length; _i < _len; _i++) {
      a = array[_i];
      i = Math.floor(f(a) / bin);
      r[i] = (ri = r[i]) != null ? ri + 1 : 1;
    }
    for (i = _j = 0, _len1 = r.length; _j < _len1; i = ++_j) {
      val = r[i];
      if (val == null) {
        r[i] = 0;
      }
    }
    return r;
  },
  sortBy: function(array, f) {
    if (this.isString(f)) {
      f = this.propFcn(f);
    }
    return array.sort(function(a, b) {
      return f(a) - f(b);
    });
  },
  uniq: function(array) {
    var i, _i, _ref;
    if (array.length < 2) {
      return array;
    }
    for (i = _i = _ref = array.length - 1; _i >= 1; i = _i += -1) {
      if (array[i - 1] === array[i]) {
        array.splice(i, 1);
      }
    }
    return array;
  },
  flatten: function(matrix) {
    return matrix.reduce(function(a, b) {
      return a.concat(b);
    });
  },
  aProp: function(array, prop) {
    var a, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = array.length; _i < _len; _i++) {
      a = array[_i];
      _results.push(a[prop]);
    }
    return _results;
  },
  aMax: function(array) {
    var a, v, _i, _len;
    v = array[0];
    for (_i = 0, _len = array.length; _i < _len; _i++) {
      a = array[_i];
      v = Math.max(v, a);
    }
    return v;
  },
  aMin: function(array) {
    var a, v, _i, _len;
    v = array[0];
    for (_i = 0, _len = array.length; _i < _len; _i++) {
      a = array[_i];
      v = Math.min(v, a);
    }
    return v;
  },
  aSum: function(array) {
    var a, v, _i, _len;
    v = 0;
    for (_i = 0, _len = array.length; _i < _len; _i++) {
      a = array[_i];
      v += a;
    }
    return v;
  },
  aAvg: function(array) {
    return this.aSum(array) / array.length;
  },
  aNaNs: function(array) {
    var i, v, _i, _len, _results;
    _results = [];
    for (i = _i = 0, _len = array.length; _i < _len; i = ++_i) {
      v = array[i];
      if (isNaN(v)) {
        _results.push(i);
      }
    }
    return _results;
  },
  aPairwise: function(a1, a2, f) {
    var i, v, _i, _len, _results;
    v = 0;
    _results = [];
    for (i = _i = 0, _len = a1.length; _i < _len; i = ++_i) {
      v = a1[i];
      _results.push(f(v, a2[i]));
    }
    return _results;
  },
  aPairSum: function(a1, a2) {
    return this.aPairwise(a1, a2, function(a, b) {
      return a + b;
    });
  },
  aPairDif: function(a1, a2) {
    return this.aPairwise(a1, a2, function(a, b) {
      return a - b;
    });
  },
  aPairMul: function(a1, a2) {
    return this.aPairwise(a1, a2, function(a, b) {
      return a * b;
    });
  },
  typedToJS: function(typedArray) {
    var i, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = typedArray.length; _i < _len; _i++) {
      i = typedArray[_i];
      _results.push(i);
    }
    return _results;
  },
  lerp: function(lo, hi, scale) {
    return lo + (hi - lo) * scale;
  },
  lerp2: function(x0, y0, x1, y1, scale) {
    return [this.lerp(x0, x1, scale), this.lerp(y0, y1, scale)];
  },
  normalize: function(array, lo, hi) {
    var max, min, num, scale, _i, _len, _results;
    if (lo == null) {
      lo = 0;
    }
    if (hi == null) {
      hi = 1;
    }
    min = this.aMin(array);
    max = this.aMax(array);
    scale = 1 / (max - min);
    _results = [];
    for (_i = 0, _len = array.length; _i < _len; _i++) {
      num = array[_i];
      _results.push(this.lerp(lo, hi, scale * (num - min)));
    }
    return _results;
  },
  sortedIndex: function(array, item, f) {
    var high, low, mid, value;
    if (f == null) {
      f = function(o) {
        return o;
      };
    }
    if (this.isString(f)) {
      f = this.propFcn(f);
    }
    value = f(item);
    low = 0;
    high = array.length;
    while (low < high) {
      mid = (low + high) >>> 1;
      if (f(array[mid]) < value) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    return low;
  },
  identity: function(o) {
    return o;
  },
  propFcn: function(prop) {
    return function(o) {
      return o[prop];
    };
  },
  indexOf: function(array, item, property) {
    var i;
    if (property != null) {
      i = this.sortedIndex(array, item, property === "" ? null : property);
      if (array[i] === item) {
        return i;
      } else {
        return -1;
      }
    } else {
      return array.indexOf(item);
    }
  },
  radsToward: function(x1, y1, x2, y2) {
    return Math.atan2(y2 - y1, x2 - x1);
  },
  inCone: function(heading, cone, radius, x1, y1, x2, y2) {
    var angle12;
    if (radius < this.distance(x1, y1, x2, y2)) {
      return false;
    }
    angle12 = this.radsToward(x1, y1, x2, y2);
    return cone / 2 >= Math.abs(this.subtractRads(heading, angle12));
  },
  distance: function(x1, y1, x2, y2) {
    var dx, dy;
    dx = x1 - x2;
    dy = y1 - y2;
    return Math.sqrt(dx * dx + dy * dy);
  },
  sqDistance: function(x1, y1, x2, y2) {
    var dx, dy;
    dx = x1 - x2;
    dy = y1 - y2;
    return dx * dx + dy * dy;
  },
  polarToXY: function(r, theta, x, y) {
    if (x == null) {
      x = 0;
    }
    if (y == null) {
      y = 0;
    }
    return [x + r * Math.cos(theta), y + r * Math.sin(theta)];
  },
  torusDistance: function(x1, y1, x2, y2, w, h) {
    return Math.sqrt(this.torusSqDistance(x1, y1, x2, y2, w, h));
  },
  torusSqDistance: function(x1, y1, x2, y2, w, h) {
    var dx, dxMin, dy, dyMin;
    dx = Math.abs(x2 - x1);
    dy = Math.abs(y2 - y1);
    dxMin = Math.min(dx, w - dx);
    dyMin = Math.min(dy, h - dy);
    return dxMin * dxMin + dyMin * dyMin;
  },
  torusWraps: function(x1, y1, x2, y2, w, h) {
    var dx, dy;
    dx = Math.abs(x2 - x1);
    dy = Math.abs(y2 - y1);
    return dx > w - dx || dy > h - dy;
  },
  torus4Pts: function(x1, y1, x2, y2, w, h) {
    var x2r, y2r;
    x2r = x2 < x1 ? x2 + w : x2 - w;
    y2r = y2 < y1 ? y2 + h : y2 - h;
    return [[x2, y2], [x2r, y2], [x2, y2r], [x2r, y2r]];
  },
  torusPt: function(x1, y1, x2, y2, w, h) {
    var x, x2r, y, y2r;
    x2r = x2 < x1 ? x2 + w : x2 - w;
    y2r = y2 < y1 ? y2 + h : y2 - h;
    x = Math.abs(x2r - x1) < Math.abs(x2 - x1) ? x2r : x2;
    y = Math.abs(y2r - y1) < Math.abs(y2 - y1) ? y2r : y2;
    return [x, y];
  },
  torusRadsToward: function(x1, y1, x2, y2, w, h) {
    var _ref;
    _ref = this.torusPt(x1, y1, x2, y2, w, h), x2 = _ref[0], y2 = _ref[1];
    return this.radsToward(x1, y1, x2, y2);
  },
  inTorusCone: function(heading, cone, radius, x1, y1, x2, y2, w, h) {
    var p, _i, _len, _ref;
    _ref = this.torus4Pts(x1, y1, x2, y2, w, h);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      p = _ref[_i];
      if (this.inCone(heading, cone, radius, x1, y1, p[0], p[1])) {
        return true;
      }
    }
    return false;
  },
  fileIndex: {},
  importImage: function(name, f) {
    var img;
    if (f == null) {
      f = function() {};
    }
    if ((img = this.fileIndex[name]) != null) {
      f(img);
    } else {
      this.fileIndex[name] = img = new Image();
      img.isDone = false;
      img.onload = function() {
        f(img);
        return img.isDone = true;
      };
      img.src = name;
    }
    return img;
  },
  xhrLoadFile: function(name, method, type, f) {
    var xhr;
    if (method == null) {
      method = "GET";
    }
    if (type == null) {
      type = "text";
    }
    if (f == null) {
      f = function() {};
    }
    if ((xhr = this.fileIndex[name]) != null) {
      f(xhr.response);
    } else {
      this.fileIndex[name] = xhr = new XMLHttpRequest();
      xhr.isDone = false;
      xhr.open(method, name);
      xhr.responseType = type;
      xhr.onload = function() {
        f(xhr.response);
        return xhr.isDone = true;
      };
      xhr.send();
    }
    return xhr;
  },
  filesLoaded: function(files) {
    var array, v;
    if (files == null) {
      files = this.fileIndex;
    }
    array = (function() {
      var _i, _len, _ref, _results;
      _ref = this.ownValues(files);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        v = _ref[_i];
        _results.push(v.isDone);
      }
      return _results;
    }).call(this);
    return array.reduce((function(a, b) {
      return a && b;
    }), true);
  },
  waitOnFiles: function(f, files) {
    if (files == null) {
      files = this.fileIndex;
    }
    return this.waitOn(((function(_this) {
      return function() {
        return _this.filesLoaded(files);
      };
    })(this)), f);
  },
  waitOn: function(done, f) {
    if (done()) {
      return f();
    } else {
      return setTimeout(((function(_this) {
        return function() {
          return _this.waitOn(done, f);
        };
      })(this)), 1000);
    }
  },
  cloneImage: function(img) {
    var i;
    (i = new Image()).src = img.src;
    return i;
  },
  imageToData: function(img, f, arrayType) {
    if (f == null) {
      f = this.pixelByte(0);
    }
    if (arrayType == null) {
      arrayType = Uint8ClampedArray;
    }
    return this.imageRowsToData(img, img.height, f, arrayType);
  },
  imageRowsToData: function(img, rowsPerSlice, f, arrayType) {
    var ctx, data, dataStart, i, idata, rows, rowsDone, _i, _ref;
    if (f == null) {
      f = this.pixelByte(0);
    }
    if (arrayType == null) {
      arrayType = Uint8ClampedArray;
    }
    rowsDone = 0;
    data = new arrayType(img.width * img.height);
    while (rowsDone < img.height) {
      rows = Math.min(img.height - rowsDone, rowsPerSlice);
      ctx = this.imageSliceToCtx(img, 0, rowsDone, img.width, rows);
      idata = this.ctxToImageData(ctx).data;
      dataStart = rowsDone * img.width;
      for (i = _i = 0, _ref = idata.length / 4; _i < _ref; i = _i += 1) {
        data[dataStart + i] = f(idata, 4 * i);
      }
      rowsDone += rows;
    }
    return data;
  },
  pixelBytesToInt: function(a) {
    var ImageByteFmts;
    ImageByteFmts = [[2], [1, 2], [0, 1, 2], [3, 0, 1, 2]];
    if (typeof a === "number") {
      a = ImageByteFmts[a - 1];
    }
    return function(id, i) {
      var j, val, _i, _len;
      val = 0;
      for (_i = 0, _len = a.length; _i < _len; _i++) {
        j = a[_i];
        val = val * 256 + id[i + j];
      }
      return val;
    };
  },
  pixelByte: function(n) {
    return function(id, i) {
      return id[i + n];
    };
  },
  createCanvas: function(width, height) {
    var can;
    can = document.createElement('canvas');
    can.width = width;
    can.height = height;
    return can;
  },
  createCtx: function(width, height, ctxType) {
    var can, _ref;
    if (ctxType == null) {
      ctxType = "2d";
    }
    can = this.createCanvas(width, height);
    if (ctxType === "2d") {
      return can.getContext("2d");
    } else {
      return (_ref = can.getContext("webgl")) != null ? _ref : can.getContext("experimental-webgl");
    }
  },
  createLayer: function(div, width, height, z, ctx) {
    var element;
    if (ctx == null) {
      ctx = "2d";
    }
    if (ctx === "img") {
      element = ctx = new Image();
      ctx.width = width;
      ctx.height = height;
    } else {
      element = (ctx = this.createCtx(width, height, ctx)).canvas;
    }
    this.insertLayer(div, element, width, height, z);
    return ctx;
  },
  insertLayer: function(div, element, w, h, z) {
    element.setAttribute('style', "position:absolute;top:0;left:0;width:" + w + ";height:" + h + ";z-index:" + z);
    return div.appendChild(element);
  },
  setCtxSmoothing: function(ctx, smoothing) {
    ctx.imageSmoothingEnabled = smoothing;
    ctx.mozImageSmoothingEnabled = smoothing;
    ctx.oImageSmoothingEnabled = smoothing;
    return ctx.webkitImageSmoothingEnabled = smoothing;
  },
  setIdentity: function(ctx) {
    ctx.save();
    return ctx.setTransform(1, 0, 0, 1, 0, 0);
  },
  clearCtx: function(ctx) {
    if (ctx.save != null) {
      this.setIdentity(ctx);
      ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
      return ctx.restore();
    } else {
      ctx.clearColor(0, 0, 0, 0);
      return ctx.clear(ctx.COLOR_BUFFER_BIT | ctx.DEPTH_BUFFER_BIT);
    }
  },
  fillCtx: function(ctx, color) {
    if (ctx.fillStyle != null) {
      this.setIdentity(ctx);
      ctx.fillStyle = this.colorStr(color);
      ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);
      return ctx.restore();
    } else {
      ctx.clearColor.apply(ctx, __slice.call(color).concat([1]));
      return ctx.clear(ctx.COLOR_BUFFER_BIT | ctx.DEPTH_BUFFER_BIT);
    }
  },
  ctxDrawText: function(ctx, string, x, y, color, setIdentity) {
    if (color == null) {
      color = [0, 0, 0];
    }
    if (setIdentity == null) {
      setIdentity = true;
    }
    if (setIdentity) {
      this.setIdentity(ctx);
    }
    ctx.fillStyle = this.colorStr(color);
    ctx.fillText(string, x, y);
    if (setIdentity) {
      return ctx.restore();
    }
  },
  ctxTextParams: function(ctx, font, align, baseline) {
    if (align == null) {
      align = "center";
    }
    if (baseline == null) {
      baseline = "middle";
    }
    ctx.font = font;
    ctx.textAlign = align;
    return ctx.textBaseline = baseline;
  },
  elementTextParams: function(e, font, align, baseline) {
    if (align == null) {
      align = "center";
    }
    if (baseline == null) {
      baseline = "middle";
    }
    if (e.canvas != null) {
      e = e.canvas;
    }
    e.style.font = font;
    e.style.textAlign = align;
    return e.style.textBaseline = baseline;
  },
  imageToCtx: function(img, w, h) {
    var ctx;
    if ((w != null) && (h != null)) {
      ctx = this.createCtx(w, h);
      ctx.drawImage(img, 0, 0, w, h);
    } else {
      ctx = this.createCtx(img.width, img.height);
      ctx.drawImage(img, 0, 0);
    }
    return ctx;
  },
  imageSliceToCtx: function(img, sx, sy, sw, sh, ctx) {
    if (ctx != null) {
      ctx.canvas.width = sw;
      ctx.canvas.height = sh;
    } else {
      ctx = this.createCtx(sw, sh);
    }
    ctx.drawImage(img, sx, sy, sw, sh, 0, 0, sw, sh);
    return ctx;
  },
  ctxToDataUrl: function(ctx) {
    return ctx.canvas.toDataURL("image/png");
  },
  ctxToDataUrlImage: function(ctx, f) {
    var img;
    img = new Image();
    if (f != null) {
      img.onload = function() {
        return f(img);
      };
    }
    img.src = ctx.canvas.toDataURL("image/png");
    return img;
  },
  ctxToImageData: function(ctx) {
    return ctx.getImageData(0, 0, ctx.canvas.width, ctx.canvas.height);
  },
  drawCenteredImage: function(ctx, img, rad, x, y, dx, dy) {
    ctx.translate(x, y);
    ctx.rotate(rad);
    return ctx.drawImage(img, -dx / 2, -dy / 2);
  },
  copyCtx: function(ctx0) {
    var ctx;
    ctx = this.createCtx(ctx0.canvas.width, ctx0.canvas.height);
    ctx.drawImage(ctx0.canvas, 0, 0);
    return ctx;
  },
  resizeCtx: function(ctx, width, height, scale) {
    var copy;
    if (scale == null) {
      scale = false;
    }
    copy = this.copyCtx(ctx);
    ctx.canvas.width = width;
    ctx.canvas.height = height;
    return ctx.drawImage(copy.canvas, 0, 0);
  }
};