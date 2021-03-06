// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

ABM.Patch = (function() {
  Patch.prototype.id = null;

  Patch.prototype.breed = null;

  Patch.prototype.x = null;

  Patch.prototype.y = null;

  Patch.prototype.n = null;

  Patch.prototype.n4 = null;

  Patch.prototype.color = [0, 0, 0];

  Patch.prototype.hidden = false;

  Patch.prototype.label = null;

  Patch.prototype.labelColor = [0, 0, 0];

  Patch.prototype.labelOffset = [0, 0];

  Patch.prototype.pRect = null;

  function Patch(x, y) {
    this.x = x;
    this.y = y;
  }

  Patch.prototype.toString = function() {
    return "{id:" + this.id + " xy:" + [this.x, this.y] + " c:" + this.color + "}";
  };

  Patch.prototype.scaleColor = function(c, s) {
    if (!this.hasOwnProperty("color")) {
      this.color = u.clone(this.color);
    }
    return u.scaleColor(c, s, this.color);
  };

  Patch.prototype.draw = function(ctx) {
    var x, y, _ref;
    ctx.fillStyle = u.colorStr(this.color);
    ctx.fillRect(this.x - .5, this.y - .5, 1, 1);
    if (this.label != null) {
      _ref = this.breed.patchXYtoPixelXY(this.x, this.y), x = _ref[0], y = _ref[1];
      return u.ctxDrawText(ctx, this.label, x + this.labelOffset[0], y + this.labelOffset[1], this.labelColor);
    }
  };

  Patch.prototype.agentsHere = function() {
    var a, _ref;
    return (_ref = this.agents) != null ? _ref : (function() {
      var _i, _len, _ref1, _results;
      _ref1 = ABM.agents;
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        a = _ref1[_i];
        if (a.p === this) {
          _results.push(a);
        }
      }
      return _results;
    }).call(this);
  };

  Patch.prototype.isOnEdge = function() {
    return this.x === this.breed.minX || this.x === this.breed.maxX || this.y === this.breed.minY || this.y === this.breed.maxY;
  };

  Patch.prototype.sprout = function(num, breed, init) {
    if (num == null) {
      num = 1;
    }
    if (breed == null) {
      breed = ABM.agents;
    }
    if (init == null) {
      init = function() {};
    }
    return breed.create(num, (function(_this) {
      return function(a) {
        a.setXY(_this.x, _this.y);
        init(a);
        return a;
      };
    })(this));
  };

  return Patch;

})();

ABM.Patches = (function(_super) {
  __extends(Patches, _super);

  function Patches() {
    var k, v, _ref;
    Patches.__super__.constructor.apply(this, arguments);
    this.monochrome = false;
    _ref = ABM.world;
    for (k in _ref) {
      if (!__hasProp.call(_ref, k)) continue;
      v = _ref[k];
      this[k] = v;
    }
    if (this.mainSet == null) {
      this.populate();
    }
  }

  Patches.prototype.populate = function() {
    var x, y, _i, _j, _ref, _ref1, _ref2, _ref3;
    for (y = _i = _ref = this.maxY, _ref1 = this.minY; _i >= _ref1; y = _i += -1) {
      for (x = _j = _ref2 = this.minX, _ref3 = this.maxX; _j <= _ref3; x = _j += 1) {
        this.add(new this.agentClass(x, y));
      }
    }
    if (this.hasNeighbors) {
      this.setNeighbors();
    }
    return this.setPixels();
  };

  Patches.prototype.cacheAgentsHere = function() {
    var p, _i, _len;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      p = this[_i];
      p.agents = [];
    }
    return null;
  };

  Patches.prototype.usePixels = function(drawWithPixels) {
    var ctx;
    this.drawWithPixels = drawWithPixels != null ? drawWithPixels : true;
    ctx = ABM.contexts.patches;
    return u.setCtxSmoothing(ctx, !this.drawWithPixels);
  };

  Patches.prototype.cacheRect = function(radius, meToo) {
    var p, _i, _len;
    if (meToo == null) {
      meToo = false;
    }
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      p = this[_i];
      p.pRect = this.patchRect(p, radius, radius, meToo);
      p.pRect.radius = radius;
    }
    return radius;
  };

  Patches.prototype.setNeighbors = function() {
    var n, p, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      p = this[_i];
      p.n = this.patchRect(p, 1, 1);
      _results.push(p.n4 = this.asSet((function() {
        var _j, _len1, _ref, _results1;
        _ref = p.n;
        _results1 = [];
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          n = _ref[_j];
          if (n.x === p.x || n.y === p.y) {
            _results1.push(n);
          }
        }
        return _results1;
      })()));
    }
    return _results;
  };

  Patches.prototype.setPixels = function() {
    if (this.size === 1) {
      this.usePixels();
      this.pixelsCtx = ABM.contexts.patches;
    } else {
      this.pixelsCtx = u.createCtx(this.numX, this.numY);
    }
    this.pixelsImageData = this.pixelsCtx.getImageData(0, 0, this.numX, this.numY);
    this.pixelsData = this.pixelsImageData.data;
    if (this.pixelsData instanceof Uint8Array) {
      this.pixelsData32 = new Uint32Array(this.pixelsData.buffer);
      return this.pixelsAreLittleEndian = u.isLittleEndian();
    }
  };

  Patches.prototype.draw = function(ctx) {
    if (this.monochrome) {
      return u.fillCtx(ctx, this.agentClass.prototype.color);
    } else if (this.drawWithPixels) {
      return this.drawScaledPixels(ctx);
    } else {
      return Patches.__super__.draw.call(this, ctx);
    }
  };

  Patches.prototype.patchIndex = function(x, y) {
    return x - this.minX + this.numX * (this.maxY - y);
  };

  Patches.prototype.patchXY = function(x, y) {
    return this[this.patchIndex(x, y)];
  };

  Patches.prototype.clamp = function(x, y) {
    return [u.clamp(x, this.minXcor, this.maxXcor), u.clamp(y, this.minYcor, this.maxYcor)];
  };

  Patches.prototype.wrap = function(x, y) {
    return [u.wrap(x, this.minXcor, this.maxXcor), u.wrap(y, this.minYcor, this.maxYcor)];
  };

  Patches.prototype.coord = function(x, y) {
    if (this.isTorus) {
      return this.wrap(x, y);
    } else {
      return this.clamp(x, y);
    }
  };

  Patches.prototype.isOnWorld = function(x, y) {
    return this.isTorus || ((this.minXcor <= x && x <= this.maxXcor) && (this.minYcor <= y && y <= this.maxYcor));
  };

  Patches.prototype.patch = function(x, y) {
    var _ref;
    _ref = this.coord(x, y), x = _ref[0], y = _ref[1];
    x = u.clamp(Math.round(x), this.minX, this.maxX);
    y = u.clamp(Math.round(y), this.minY, this.maxY);
    return this.patchXY(x, y);
  };

  Patches.prototype.randomPt = function() {
    return [u.randomFloat2(this.minXcor, this.maxXcor), u.randomFloat2(this.minYcor, this.maxYcor)];
  };

  Patches.prototype.toBits = function(p) {
    return p * this.size;
  };

  Patches.prototype.fromBits = function(b) {
    return b / this.size;
  };

  Patches.prototype.patchRect = function(p, dx, dy, meToo) {
    var pnext, rect, x, y, _i, _j, _ref, _ref1, _ref2, _ref3;
    if (meToo == null) {
      meToo = false;
    }
    if ((p.pRect != null) && p.pRect.radius === dx) {
      return p.pRect;
    }
    rect = [];
    for (y = _i = _ref = p.y - dy, _ref1 = p.y + dy; _i <= _ref1; y = _i += 1) {
      for (x = _j = _ref2 = p.x - dx, _ref3 = p.x + dx; _j <= _ref3; x = _j += 1) {
        if (this.isTorus || ((this.minX <= x && x <= this.maxX) && (this.minY <= y && y <= this.maxY))) {
          if (this.isTorus) {
            if (x < this.minX) {
              x += this.numX;
            }
            if (x > this.maxX) {
              x -= this.numX;
            }
            if (y < this.minY) {
              y += this.numY;
            }
            if (y > this.maxY) {
              y -= this.numY;
            }
          }
          pnext = this.patchXY(x, y);
          if (pnext == null) {
            u.error("patchRect: x,y out of bounds, see console.log");
            console.log("x " + x + " y " + y + " p.x " + p.x + " p.y " + p.y + " dx " + dx + " dy " + dy);
          }
          if (meToo || p !== pnext) {
            rect.push(pnext);
          }
        }
      }
    }
    return this.asSet(rect);
  };

  Patches.prototype.importDrawing = function(imageSrc, f) {
    return u.importImage(imageSrc, (function(_this) {
      return function(img) {
        _this.installDrawing(img);
        if (f != null) {
          return f();
        }
      };
    })(this));
  };

  Patches.prototype.installDrawing = function(img, ctx) {
    if (ctx == null) {
      ctx = ABM.contexts.drawing;
    }
    u.setIdentity(ctx);
    ctx.drawImage(img, 0, 0, ctx.canvas.width, ctx.canvas.height);
    return ctx.restore();
  };

  Patches.prototype.pixelByteIndex = function(p) {
    return 4 * p.id;
  };

  Patches.prototype.pixelWordIndex = function(p) {
    return p.id;
  };

  Patches.prototype.pixelXYtoPatchXY = function(x, y) {
    return [this.minXcor + (x / this.size), this.maxYcor - (y / this.size)];
  };

  Patches.prototype.patchXYtoPixelXY = function(x, y) {
    return [(x - this.minXcor) * this.size, (this.maxYcor - y) * this.size];
  };

  Patches.prototype.importColors = function(imageSrc, f) {
    return u.importImage(imageSrc, (function(_this) {
      return function(img) {
        _this.installColors(img);
        if (f != null) {
          return f();
        }
      };
    })(this));
  };

  Patches.prototype.installColors = function(img) {
    var data, i, p, _i, _len;
    u.setIdentity(this.pixelsCtx);
    this.pixelsCtx.drawImage(img, 0, 0, this.numX, this.numY);
    data = this.pixelsCtx.getImageData(0, 0, this.numX, this.numY).data;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      p = this[_i];
      i = this.pixelByteIndex(p);
      p.color = [data[i++], data[i++], data[i]];
    }
    return this.pixelsCtx.restore();
  };

  Patches.prototype.drawScaledPixels = function(ctx) {
    if (this.size !== 1) {
      u.setIdentity(ctx);
    }
    if (this.pixelsData32 != null) {
      this.drawScaledPixels32(ctx);
    } else {
      this.drawScaledPixels8(ctx);
    }
    if (this.size !== 1) {
      return ctx.restore();
    }
  };

  Patches.prototype.drawScaledPixels8 = function(ctx) {
    var a, c, data, i, j, p, _i, _j, _len;
    data = this.pixelsData;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      p = this[_i];
      i = this.pixelByteIndex(p);
      c = p.color;
      a = c.length === 4 ? c[3] : 255;
      for (j = _j = 0; _j <= 2; j = ++_j) {
        data[i + j] = c[j];
      }
      data[i + 3] = a;
    }
    this.pixelsCtx.putImageData(this.pixelsImageData, 0, 0);
    if (this.size === 1) {
      return;
    }
    return ctx.drawImage(this.pixelsCtx.canvas, 0, 0, ctx.canvas.width, ctx.canvas.height);
  };

  Patches.prototype.drawScaledPixels32 = function(ctx) {
    var a, c, data, i, p, _i, _len;
    data = this.pixelsData32;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      p = this[_i];
      i = this.pixelWordIndex(p);
      c = p.color;
      a = c.length === 4 ? c[3] : 255;
      if (this.pixelsAreLittleEndian) {
        data[i] = (a << 24) | (c[2] << 16) | (c[1] << 8) | c[0];
      } else {
        data[i] = (c[0] << 24) | (c[1] << 16) | (c[2] << 8) | a;
      }
    }
    this.pixelsCtx.putImageData(this.pixelsImageData, 0, 0);
    if (this.size === 1) {
      return;
    }
    return ctx.drawImage(this.pixelsCtx.canvas, 0, 0, ctx.canvas.width, ctx.canvas.height);
  };

  Patches.prototype.floodFill = function(aset, fCandidate, fJoin, fNeighbors, asetLast) {
    if (fNeighbors == null) {
      fNeighbors = (function(p) {
        return p.n;
      });
    }
    if (asetLast == null) {
      asetLast = [];
    }
    return Patches.__super__.floodFill.call(this, aset, fCandidate, fJoin, fNeighbors, asetLast);
  };

  Patches.prototype.diffuse = function(v, rate, c) {
    var dv, dv8, n, nn, p, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref;
    if (this[0]._diffuseNext == null) {
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        p = this[_i];
        p._diffuseNext = 0;
      }
    }
    for (_j = 0, _len1 = this.length; _j < _len1; _j++) {
      p = this[_j];
      dv = p[v] * rate;
      dv8 = dv / 8;
      nn = p.n.length;
      p._diffuseNext += p[v] - dv + (8 - nn) * dv8;
      _ref = p.n;
      for (_k = 0, _len2 = _ref.length; _k < _len2; _k++) {
        n = _ref[_k];
        n._diffuseNext += dv8;
      }
    }
    for (_l = 0, _len3 = this.length; _l < _len3; _l++) {
      p = this[_l];
      p[v] = p._diffuseNext;
      p._diffuseNext = 0;
      if (c) {
        p.scaleColor(c, p[v]);
      }
    }
    return null;
  };

  return Patches;

})(ABM.AgentSet);

ABM.Agent = (function() {
  Agent.prototype.id = null;

  Agent.prototype.breed = null;

  Agent.prototype.x = 0;

  Agent.prototype.y = 0;

  Agent.prototype.p = null;

  Agent.prototype.size = 1;

  Agent.prototype.color = null;

  Agent.prototype.shape = "default";

  Agent.prototype.hidden = false;

  Agent.prototype.label = null;

  Agent.prototype.labelColor = [0, 0, 0];

  Agent.prototype.labelOffset = [0, 0];

  Agent.prototype.penDown = false;

  Agent.prototype.penSize = 1;

  Agent.prototype.heading = null;

  Agent.prototype.sprite = null;

  Agent.prototype.cacheLinks = false;

  Agent.prototype.links = null;

  function Agent() {
    this.x = this.y = 0;
    this.p = ABM.patches.patch(this.x, this.y);
    if (this.color == null) {
      this.color = u.randomColor();
    }
    if (this.heading == null) {
      this.heading = u.randomFloat(Math.PI * 2);
    }
    if (this.p.agents != null) {
      this.p.agents.push(this);
    }
    if (this.cacheLinks) {
      this.links = [];
    }
  }

  Agent.prototype.scaleColor = function(c, s) {
    if (!this.hasOwnProperty("color")) {
      this.color = u.clone(this.color);
    }
    return u.scaleColor(c, s, this.color);
  };

  Agent.prototype.toString = function() {
    return "{id:" + this.id + " xy:" + (u.aToFixed([this.x, this.y])) + " c:" + this.color + " h: " + (this.heading.toFixed(2)) + "}";
  };

  Agent.prototype.setXY = function(x, y) {
    var drawing, p, x0, y0, _ref, _ref1;
    if (this.penDown) {
      _ref = [this.x, this.y], x0 = _ref[0], y0 = _ref[1];
    }
    _ref1 = ABM.patches.coord(x, y), this.x = _ref1[0], this.y = _ref1[1];
    p = this.p;
    this.p = ABM.patches.patch(this.x, this.y);
    if ((p.agents != null) && p !== this.p) {
      u.removeItem(p.agents, this);
      this.p.agents.push(this);
    }
    if (this.penDown) {
      drawing = ABM.drawing;
      drawing.strokeStyle = u.colorStr(this.color);
      drawing.lineWidth = ABM.patches.fromBits(this.penSize);
      drawing.beginPath();
      drawing.moveTo(x0, y0);
      drawing.lineTo(x, y);
      return drawing.stroke();
    }
  };

  Agent.prototype.moveTo = function(a) {
    return this.setXY(a.x, a.y);
  };

  Agent.prototype.forward = function(d) {
    return this.setXY(this.x + d * Math.cos(this.heading), this.y + d * Math.sin(this.heading));
  };

  Agent.prototype.rotate = function(rad) {
    return this.heading = u.wrap(this.heading + rad, 0, Math.PI * 2);
  };

  Agent.prototype.draw = function(ctx) {
    var rad, shape, x, y, _ref;
    shape = ABM.shapes[this.shape];
    rad = shape.rotate ? this.heading : 0;
    if ((this.sprite != null) || this.breed.useSprites) {
      if (this.sprite == null) {
        this.setSprite();
      }
      ABM.shapes.drawSprite(ctx, this.sprite, this.x, this.y, this.size, rad);
    } else {
      ABM.shapes.draw(ctx, shape, this.x, this.y, this.size, rad, this.color);
    }
    if (this.label != null) {
      _ref = ABM.patches.patchXYtoPixelXY(this.x, this.y), x = _ref[0], y = _ref[1];
      return u.ctxDrawText(ctx, this.label, x + this.labelOffset[0], y + this.labelOffset[1], this.labelColor);
    }
  };

  Agent.prototype.setSprite = function(sprite) {
    var s;
    if ((s = sprite) != null) {
      this.sprite = s;
      this.color = s.color;
      this.shape = s.shape;
      return this.size = s.size;
    } else {
      if (this.color == null) {
        this.color = u.randomColor;
      }
      return this.sprite = ABM.shapes.shapeToSprite(this.shape, this.color, this.size);
    }
  };

  Agent.prototype.stamp = function() {
    return this.draw(ABM.drawing);
  };

  Agent.prototype.distanceXY = function(x, y) {
    if (ABM.patches.isTorus) {
      return u.torusDistance(this.x, this.y, x, y, ABM.patches.numX, ABM.patches.numY);
    } else {
      return u.distance(this.x, this.y, x, y);
    }
  };

  Agent.prototype.distance = function(o) {
    return this.distanceXY(o.x, o.y);
  };

  Agent.prototype.torusPtXY = function(x, y) {
    return u.torusPt(this.x, this.y, x, y, ABM.patches.numX, ABM.patches.numY);
  };

  Agent.prototype.torusPt = function(o) {
    return this.torusPtXY(o.x, o.y);
  };

  Agent.prototype.face = function(o) {
    return this.heading = this.towards(o);
  };

  Agent.prototype.towardsXY = function(x, y) {
    var ps;
    if ((ps = ABM.patches).isTorus) {
      return u.torusRadsToward(this.x, this.y, x, y, ps.numX, ps.numY);
    } else {
      return u.radsToward(this.x, this.y, x, y);
    }
  };

  Agent.prototype.towards = function(o) {
    return this.towardsXY(o.x, o.y);
  };

  Agent.prototype.patchAtHeadingAndDistance = function(h, d) {
    var x, y, _ref;
    _ref = u.polarToXY(d, h, this.x, this.y), x = _ref[0], y = _ref[1];
    return patchAt(x, y);
  };

  Agent.prototype.patchLeftAndAhead = function(dh, d) {
    return this.patchAtHeadingAndDistance(this.heading + dh, d);
  };

  Agent.prototype.patchRightAndAhead = function(dh, d) {
    return this.patchAtHeadingAndDistance(this.heading - dh, d);
  };

  Agent.prototype.patchAhead = function(d) {
    return this.patchAtHeadingAndDistance(this.heading, d);
  };

  Agent.prototype.canMove = function(d) {
    return this.patchAhead(d) != null;
  };

  Agent.prototype.patchAt = function(dx, dy) {
    var ps, x, y;
    x = this.x + dx;
    y = this.y + dy;
    if ((ps = ABM.patches).isOnWorld(x, y)) {
      return ps.patch(x, y);
    } else {
      return null;
    }
  };

  Agent.prototype.die = function() {
    var l, _i, _len, _ref;
    this.breed.remove(this);
    _ref = this.myLinks();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      l = _ref[_i];
      l.die();
    }
    if (this.p.agents != null) {
      u.removeItem(this.p.agents, this);
    }
    return null;
  };

  Agent.prototype.hatch = function(num, breed, init) {
    if (num == null) {
      num = 1;
    }
    if (breed == null) {
      breed = ABM.agents;
    }
    if (init == null) {
      init = function() {};
    }
    return breed.create(num, (function(_this) {
      return function(a) {
        var k, v;
        a.setXY(_this.x, _this.y);
        for (k in _this) {
          if (!__hasProp.call(_this, k)) continue;
          v = _this[k];
          if (k !== "id") {
            a[k] = v;
          }
        }
        init(a);
        return a;
      };
    })(this));
  };

  Agent.prototype.inCone = function(aset, cone, radius, meToo) {
    if (meToo == null) {
      meToo = false;
    }
    return aset.inCone(this.p, this.heading, cone, radius, meToo);
  };

  Agent.prototype.otherEnd = function(l) {
    if (l.end1 === this) {
      return l.end2;
    } else {
      return l.end1;
    }
  };

  Agent.prototype.myLinks = function() {
    var l, _ref;
    return (_ref = this.links) != null ? _ref : (function() {
      var _i, _len, _ref1, _results;
      _ref1 = ABM.links;
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        l = _ref1[_i];
        if ((l.end1 === this) || (l.end2 === this)) {
          _results.push(l);
        }
      }
      return _results;
    }).call(this);
  };

  Agent.prototype.linkNeighbors = function() {
    var l, _i, _len, _ref, _results;
    _ref = this.myLinks();
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      l = _ref[_i];
      _results.push(this.otherEnd(l));
    }
    return _results;
  };

  Agent.prototype.myInLinks = function() {
    var l, _i, _len, _ref, _results;
    _ref = this.myLinks();
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      l = _ref[_i];
      if (l.end2 === this) {
        _results.push(l);
      }
    }
    return _results;
  };

  Agent.prototype.inLinkNeighbors = function() {
    var l, _i, _len, _ref, _results;
    _ref = this.myLinks();
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      l = _ref[_i];
      if (l.end2 === this) {
        _results.push(l.end1);
      }
    }
    return _results;
  };

  Agent.prototype.myOutLinks = function() {
    var l, _i, _len, _ref, _results;
    _ref = this.myLinks();
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      l = _ref[_i];
      if (l.end1 === this) {
        _results.push(l);
      }
    }
    return _results;
  };

  Agent.prototype.outLinkNeighbors = function() {
    var l, _i, _len, _ref, _results;
    _ref = this.myLinks();
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      l = _ref[_i];
      if (l.end1 === this) {
        _results.push(l.end2);
      }
    }
    return _results;
  };

  return Agent;

})();

ABM.Agents = (function(_super) {
  __extends(Agents, _super);

  function Agents() {
    Agents.__super__.constructor.apply(this, arguments);
    this.useSprites = false;
  }

  Agents.prototype.cacheLinks = function() {
    return this.agentClass.prototype.cacheLinks = true;
  };

  Agents.prototype.setUseSprites = function(useSprites) {
    this.useSprites = useSprites != null ? useSprites : true;
  };

  Agents.prototype["in"] = function(array) {
    var o;
    return this.asSet((function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        o = array[_i];
        if (o.breed === this) {
          _results.push(o);
        }
      }
      return _results;
    }).call(this));
  };

  Agents.prototype.create = function(num, init) {
    var i, _i, _results;
    if (init == null) {
      init = function() {};
    }
    _results = [];
    for (i = _i = 1; _i <= num; i = _i += 1) {
      _results.push((function(o) {
        init(o);
        return o;
      })(this.add(new this.agentClass)));
    }
    return _results;
  };

  Agents.prototype.clear = function() {
    while (this.any()) {
      this.last().die();
    }
    return null;
  };

  Agents.prototype.inPatches = function(patches) {
    var array, p, _i, _len;
    array = [];
    for (_i = 0, _len = patches.length; _i < _len; _i++) {
      p = patches[_i];
      array.push.apply(array, p.agentsHere());
    }
    if (this.mainSet != null) {
      return this["in"](array);
    } else {
      return this.asSet(array);
    }
  };

  Agents.prototype.inRect = function(a, dx, dy, meToo) {
    var rect;
    if (meToo == null) {
      meToo = false;
    }
    rect = ABM.patches.patchRect(a.p, dx, dy, true);
    rect = this.inPatches(rect);
    if (!meToo) {
      u.removeItem(rect, a);
    }
    return rect;
  };

  Agents.prototype.inCone = function(a, heading, cone, radius, meToo) {
    var as;
    if (meToo == null) {
      meToo = false;
    }
    as = this.inRect(a, radius, radius, true);
    return Agents.__super__.inCone.call(this, a, heading, cone, radius, meToo);
  };

  Agents.prototype.inRadius = function(a, radius, meToo) {
    var as;
    if (meToo == null) {
      meToo = false;
    }
    as = this.inRect(a, radius, radius, true);
    return Agents.__super__.inRadius.call(this, a, radius, meToo);
  };

  return Agents;

})(ABM.AgentSet);

ABM.Link = (function() {
  Link.prototype.id = null;

  Link.prototype.breed = null;

  Link.prototype.end1 = null;

  Link.prototype.end2 = null;

  Link.prototype.color = [130, 130, 130];

  Link.prototype.thickness = 2;

  Link.prototype.hidden = false;

  Link.prototype.label = null;

  Link.prototype.labelColor = [0, 0, 0];

  Link.prototype.labelOffset = [0, 0];

  function Link(end1, end2) {
    this.end1 = end1;
    this.end2 = end2;
    if (this.end1.links != null) {
      this.end1.links.push(this);
      this.end2.links.push(this);
    }
  }

  Link.prototype.draw = function(ctx) {
    var pt, x, x0, y, y0, _ref, _ref1;
    ctx.save();
    ctx.strokeStyle = u.colorStr(this.color);
    ctx.lineWidth = ABM.patches.fromBits(this.thickness);
    ctx.beginPath();
    if (!ABM.patches.isTorus) {
      ctx.moveTo(this.end1.x, this.end1.y);
      ctx.lineTo(this.end2.x, this.end2.y);
    } else {
      pt = this.end1.torusPt(this.end2);
      ctx.moveTo(this.end1.x, this.end1.y);
      ctx.lineTo.apply(ctx, pt);
      if (pt[0] !== this.end2.x || pt[1] !== this.end2.y) {
        pt = this.end2.torusPt(this.end1);
        ctx.moveTo(this.end2.x, this.end2.y);
        ctx.lineTo.apply(ctx, pt);
      }
    }
    ctx.closePath();
    ctx.stroke();
    ctx.restore();
    if (this.label != null) {
      _ref = u.lerp2(this.end1.x, this.end1.y, this.end2.x, this.end2.y, .5), x0 = _ref[0], y0 = _ref[1];
      _ref1 = ABM.patches.patchXYtoPixelXY(x0, y0), x = _ref1[0], y = _ref1[1];
      return u.ctxDrawText(ctx, this.label, x + this.labelOffset[0], y + this.labelOffset[1], this.labelColor);
    }
  };

  Link.prototype.die = function() {
    this.breed.remove(this);
    if (this.end1.links != null) {
      u.removeItem(this.end1.links, this);
    }
    if (this.end2.links != null) {
      u.removeItem(this.end2.links, this);
    }
    return null;
  };

  Link.prototype.bothEnds = function() {
    return [this.end1, this.end2];
  };

  Link.prototype.length = function() {
    return this.end1.distance(this.end2);
  };

  Link.prototype.otherEnd = function(a) {
    if (this.end1 === a) {
      return this.end2;
    } else {
      return this.end1;
    }
  };

  return Link;

})();

ABM.Links = (function(_super) {
  __extends(Links, _super);

  function Links() {
    Links.__super__.constructor.apply(this, arguments);
  }

  Links.prototype.create = function(from, to, init) {
    var a, _i, _len, _results;
    if (init == null) {
      init = function() {};
    }
    if (to.length == null) {
      to = [to];
    }
    _results = [];
    for (_i = 0, _len = to.length; _i < _len; _i++) {
      a = to[_i];
      _results.push((function(o) {
        init(o);
        return o;
      })(this.add(new this.agentClass(from, a))));
    }
    return _results;
  };

  Links.prototype.clear = function() {
    while (this.any()) {
      this.last().die();
    }
    return null;
  };

  Links.prototype.allEnds = function() {
    var l, n, _i, _len;
    n = this.asSet([]);
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      l = this[_i];
      n.push(l.end1, l.end2);
    }
    return n;
  };

  Links.prototype.nodes = function() {
    return this.allEnds().sortById().uniq();
  };

  Links.prototype.layoutCircle = function(list, radius, startAngle, direction) {
    var a, dTheta, i, _i, _len;
    if (startAngle == null) {
      startAngle = Math.PI / 2;
    }
    if (direction == null) {
      direction = -1;
    }
    dTheta = 2 * Math.PI / list.length;
    for (i = _i = 0, _len = list.length; _i < _len; i = ++_i) {
      a = list[i];
      a.setXY(0, 0);
      a.heading = startAngle + direction * dTheta * i;
      a.forward(radius);
    }
    return null;
  };

  return Links;

})(ABM.AgentSet);
