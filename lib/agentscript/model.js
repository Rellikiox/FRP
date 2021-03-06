// Generated by CoffeeScript 1.7.1
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

ABM.Animator = (function() {
  function Animator(model, rate, multiStep) {
    this.model = model;
    this.rate = rate != null ? rate : 30;
    this.multiStep = multiStep != null ? multiStep : false;
    this.animateDraws = __bind(this.animateDraws, this);
    this.animateSteps = __bind(this.animateSteps, this);
    this.reset();
  }

  Animator.prototype.setRate = function(rate, multiStep) {
    this.rate = rate;
    this.multiStep = multiStep != null ? multiStep : false;
    return this.resetTimes();
  };

  Animator.prototype.start = function() {
    if (!this.stopped) {
      return;
    }
    this.resetTimes();
    this.stopped = false;
    return this.animate();
  };

  Animator.prototype.stop = function() {
    this.stopped = true;
    if (this.animHandle != null) {
      cancelAnimFrame(this.animHandle);
    }
    if (this.timeoutHandle != null) {
      clearTimeout(this.timeoutHandle);
    }
    if (this.intervalHandle != null) {
      clearInterval(this.intervalHandle);
    }
    return this.animHandle = this.timerHandle = this.intervalHandle = null;
  };

  Animator.prototype.resetTimes = function() {
    this.startMS = this.now();
    this.startTick = this.ticks;
    return this.startDraw = this.draws;
  };

  Animator.prototype.reset = function() {
    this.stop();
    return this.ticks = this.draws = 0;
  };

  Animator.prototype.step = function() {
    this.ticks++;
    return this.model.step();
  };

  Animator.prototype.draw = function() {
    this.draws++;
    return this.model.draw();
  };

  Animator.prototype.once = function() {
    this.step();
    return this.draw();
  };

  Animator.prototype.now = function() {
    return (typeof performance !== "undefined" && performance !== null ? performance : Date).now();
  };

  Animator.prototype.ms = function() {
    return this.now() - this.startMS;
  };

  Animator.prototype.ticksPerSec = function() {
    var elapsed;
    if ((elapsed = this.ticks - this.startTick) === 0) {
      return 0;
    } else {
      return Math.round(elapsed * 1000 / this.ms());
    }
  };

  Animator.prototype.drawsPerSec = function() {
    var elapsed;
    if ((elapsed = this.draws - this.startDraw) === 0) {
      return 0;
    } else {
      return Math.round(elapsed * 1000 / this.ms());
    }
  };

  Animator.prototype.toString = function() {
    return "ticks: " + this.ticks + ", draws: " + this.draws + ", rate: " + this.rate + " " + (this.ticksPerSec()) + "/" + (this.drawsPerSec());
  };

  Animator.prototype.animateSteps = function() {
    this.step();
    if (!this.stopped) {
      return this.timeoutHandle = setTimeout(this.animateSteps, 10);
    }
  };

  Animator.prototype.animateDraws = function() {
    if (this.drawsPerSec() <= this.rate) {
      if (!this.multiStep) {
        this.step();
      }
      this.draw();
    }
    if (!this.stopped) {
      return this.animHandle = requestAnimFrame(this.animateDraws);
    }
  };

  Animator.prototype.animate = function() {
    if (this.multiStep) {
      this.animateSteps();
    }
    return this.animateDraws();
  };

  return Animator;

})();

ABM.models = {};

ABM.Model = (function() {
  Model.prototype.contextsInit = {
    patches: {
      z: 10,
      ctx: "2d"
    },
    drawing: {
      z: 20,
      ctx: "2d"
    },
    links: {
      z: 30,
      ctx: "2d"
    },
    agents: {
      z: 40,
      ctx: "2d"
    },
    spotlight: {
      z: 50,
      ctx: "2d"
    }
  };

  function Model(div, size, minX, maxX, minY, maxY, isTorus, hasNeighbors) {
    var ctx, k, v, _ref;
    if (size == null) {
      size = 13;
    }
    if (minX == null) {
      minX = -16;
    }
    if (maxX == null) {
      maxX = 16;
    }
    if (minY == null) {
      minY = -16;
    }
    if (maxY == null) {
      maxY = 16;
    }
    if (isTorus == null) {
      isTorus = false;
    }
    if (hasNeighbors == null) {
      hasNeighbors = true;
    }
    ABM.model = this;
    this.setWorld(size, minX, maxX, minY, maxY, isTorus, hasNeighbors);
    this.contexts = ABM.contexts = {};
    (this.div = document.getElementById(div)).setAttribute('style', "position:relative");
    _ref = this.contextsInit;
    for (k in _ref) {
      if (!__hasProp.call(_ref, k)) continue;
      v = _ref[k];
      this.contexts[k] = ctx = u.createLayer(this.div, this.world.pxWidth, this.world.pxHeight, v.z, v.ctx);
      if (ctx.canvas != null) {
        this.setCtxTransform(ctx);
      }
      u.elementTextParams(ctx, "10px sans-serif", "center", "middle");
    }
    this.drawing = ABM.drawing = this.contexts.drawing;
    this.drawing.clear = (function(_this) {
      return function() {
        return u.clearCtx(_this.drawing);
      };
    })(this);
    this.contexts.spotlight.globalCompositeOperation = "xor";
    this.anim = new ABM.Animator(this);
    this.refreshLinks = this.refreshAgents = this.refreshPatches = true;
    this.patches = ABM.patches = new ABM.Patches(ABM.Patch, "patches");
    this.agents = ABM.agents = new ABM.Agents(ABM.Agent, "agents");
    this.links = ABM.links = new ABM.Links(ABM.Link, "links");
    this.debugging = false;
    this.modelReady = false;
    this.globalNames = null;
    this.globalNames = u.ownKeys(this);
    this.globalNames.set = false;
    this.startup();
    u.waitOnFiles((function(_this) {
      return function() {
        _this.modelReady = true;
        _this.setup();
        if (!_this.globalNames.set) {
          return _this.globals();
        }
      };
    })(this));
  }

  Model.prototype.setWorld = function(size, minX, maxX, minY, maxY, isTorus, hasNeighbors) {
    var maxXcor, maxYcor, minXcor, minYcor, numX, numY, pxHeight, pxWidth;
    if (isTorus == null) {
      isTorus = false;
    }
    if (hasNeighbors == null) {
      hasNeighbors = true;
    }
    numX = maxX - minX + 1;
    numY = maxY - minY + 1;
    pxWidth = numX * size;
    pxHeight = numY * size;
    minXcor = minX - .5;
    maxXcor = maxX + .5;
    minYcor = minY - .5;
    maxYcor = maxY + .5;
    return ABM.world = this.world = {
      size: size,
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      minXcor: minXcor,
      maxXcor: maxXcor,
      minYcor: minYcor,
      maxYcor: maxYcor,
      numX: numX,
      numY: numY,
      pxWidth: pxWidth,
      pxHeight: pxHeight,
      isTorus: isTorus,
      hasNeighbors: hasNeighbors
    };
  };

  Model.prototype.setCtxTransform = function(ctx) {
    ctx.canvas.width = this.world.pxWidth;
    ctx.canvas.height = this.world.pxHeight;
    ctx.save();
    ctx.scale(this.world.size, -this.world.size);
    return ctx.translate(-this.world.minXcor, -this.world.maxYcor);
  };

  Model.prototype.globals = function(globalNames) {
    if (globalNames != null) {
      this.globalNames = globalNames;
      return this.globalNames.set = true;
    } else {
      return this.globalNames = u.removeItems(u.ownKeys(this), this.globalNames);
    }
  };

  Model.prototype.setFastPatches = function() {
    return this.patches.usePixels();
  };

  Model.prototype.setMonochromePatches = function() {
    return this.patches.monochrome = true;
  };

  Model.prototype.setCacheAgentsHere = function() {
    return this.patches.cacheAgentsHere();
  };

  Model.prototype.setCacheMyLinks = function() {
    return this.agents.cacheLinks();
  };

  Model.prototype.setCachePatchRect = function(radius, meToo) {
    if (meToo == null) {
      meToo = false;
    }
    return this.patches.cacheRect(radius, meToo);
  };

  Model.prototype.startup = function() {};

  Model.prototype.setup = function() {};

  Model.prototype.step = function() {};

  Model.prototype.start = function() {
    u.waitOn(((function(_this) {
      return function() {
        return _this.modelReady;
      };
    })(this)), ((function(_this) {
      return function() {
        return _this.anim.start();
      };
    })(this)));
    return this;
  };

  Model.prototype.stop = function() {
    return this.anim.stop();
  };

  Model.prototype.once = function() {
    if (!this.anim.stopped) {
      this.stop();
    }
    return this.anim.once();
  };

  Model.prototype.reset = function(restart) {
    var k, v, _ref;
    if (restart == null) {
      restart = false;
    }
    console.log("reset: anim");
    this.anim.reset();
    console.log("reset: contexts");
    _ref = this.contexts;
    for (k in _ref) {
      v = _ref[k];
      if (v.canvas != null) {
        v.restore();
        this.setCtxTransform(v);
      }
    }
    console.log("reset: patches");
    this.patches = ABM.patches = new ABM.Patches(ABM.Patch, "patches");
    console.log("reset: agents");
    this.agents = ABM.agents = new ABM.Agents(ABM.Agent, "agents");
    this.links = ABM.links = new ABM.Links(ABM.Link, "links");
    u.s.spriteSheets.length = 0;
    console.log("reset: setup");
    this.setup();
    if (this.debugging) {
      this.setRootVars();
    }
    if (restart) {
      return this.start();
    }
  };

  Model.prototype.draw = function(force) {
    if (force == null) {
      force = this.anim.stopped;
    }
    if (force || this.refreshPatches || this.anim.draws === 1) {
      this.patches.draw(this.contexts.patches);
    }
    if (force || this.refreshLinks || this.anim.draws === 1) {
      this.links.draw(this.contexts.links);
    }
    if (force || this.refreshAgents || this.anim.draws === 1) {
      this.agents.draw(this.contexts.agents);
    }
    if (this.spotlightAgent != null) {
      return this.drawSpotlight(this.spotlightAgent, this.contexts.spotlight);
    }
  };

  Model.prototype.setSpotlight = function(spotlightAgent) {
    this.spotlightAgent = spotlightAgent;
    if (this.spotlightAgent == null) {
      return u.clearCtx(this.contexts.spotlight);
    }
  };

  Model.prototype.drawSpotlight = function(agent, ctx) {
    u.clearCtx(ctx);
    u.fillCtx(ctx, [0, 0, 0, 0.6]);
    ctx.beginPath();
    ctx.arc(agent.x, agent.y, 3, 0, 2 * Math.PI, false);
    return ctx.fill();
  };

  Model.prototype.createBreeds = function(s, agentClass, breedSet) {
    var Breed, b, breed, breeds, c, _i, _len, _ref;
    breeds = [];
    breeds.classes = {};
    breeds.sets = {};
    _ref = s.split(" ");
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      b = _ref[_i];
      c = Breed = (function(_super) {
        __extends(Breed, _super);

        function Breed() {
          return Breed.__super__.constructor.apply(this, arguments);
        }

        return Breed;

      })(agentClass);
      breed = this[b] = new breedSet(c, b, agentClass.prototype.breed);
      breeds.push(breed);
      breeds.sets[b] = breed;
      breeds.classes["" + b + "Class"] = c;
    }
    return breeds;
  };

  Model.prototype.patchBreeds = function(s) {
    return this.patches.breeds = this.createBreeds(s, ABM.Patch, ABM.Patches);
  };

  Model.prototype.agentBreeds = function(s) {
    return this.agents.breeds = this.createBreeds(s, ABM.Agent, ABM.Agents);
  };

  Model.prototype.linkBreeds = function(s) {
    return this.links.breeds = this.createBreeds(s, ABM.Link, ABM.Links);
  };

  Model.prototype.asSet = function(a, setType) {
    if (setType == null) {
      setType = ABM.AgentSet;
    }
    return ABM.AgentSet.asSet(a, setType);
  };

  Model.prototype.debug = function(debugging) {
    this.debugging = debugging != null ? debugging : true;
    u.waitOn(((function(_this) {
      return function() {
        return _this.modelReady;
      };
    })(this)), ((function(_this) {
      return function() {
        return _this.setRootVars();
      };
    })(this)));
    return this;
  };

  Model.prototype.setRootVars = function() {
    root.ps = this.patches;
    root.p0 = this.patches[0];
    root.as = this.agents;
    root.a0 = this.agents[0];
    root.ls = this.links;
    root.l0 = this.links[0];
    root.dr = this.drawing;
    root.u = ABM.util;
    root.cx = this.contexts;
    root.an = this.anim;
    root.gl = this.globals;
    root.dv = this.div;
    root.root = root;
    return root.app = this;
  };

  return Model;

})();
