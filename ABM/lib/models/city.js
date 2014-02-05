// Generated by CoffeeScript 1.7.0
var MyModel, model, u,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

u = ABM.util;

MyModel = (function(_super) {
  __extends(MyModel, _super);

  function MyModel() {
    return MyModel.__super__.constructor.apply(this, arguments);
  }

  MyModel.prototype.setup = function() {
    var p, patch, _i, _len, _ref;
    this.patchBreeds("city_hall road");
    this.agentBreeds("roadMakers");
    this.anim.setRate(1, false);
    _ref = this.patches;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      p = _ref[_i];
      p.color = u.randomGray();
    }
    this.city_hall = this.createCityHall(0, 0);
    patch = u.oneOf(this.city_hall.p.n);
    return this.createRoadMaker(patch.x, patch.y);
  };

  MyModel.prototype.step = function() {
    return console.log(this.anim.toString());
  };

  MyModel.prototype.createCityHall = function(x, y) {
    var agent;
    agent = (this.agents.create(1))[0];
    agent.setXY(x, y);
    agent.color = [255, 0, 0];
    agent.shape = "square";
    agent.size = 1;
    return agent;
  };

  MyModel.prototype.createRoadMaker = function(x, y) {
    var agent;
    agent = (this.roadMakers.create(1))[0];
    agent.setXY(x, y);
    agent.color = [0, 255, 0];
    return agent.size = 1;
  };

  MyModel.prototype.stepRoadMaker = function(agent) {
    var next_patch;
    return next_patch = u.oneOF(agent.p.n);
  };

  return MyModel;

})(ABM.Model);

model = new MyModel("layers", 16, -16, 16, -16, 16);

model.debug();

model.start();
