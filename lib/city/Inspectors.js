// Generated by CoffeeScript 1.7.1
var GridRoadInspector, Inspector, NeedsInspector, NodeInspector, PlotInspector, RadialRoadInspector, RoadInspector,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

Inspector = (function() {
  function Inspector() {}

  Inspector.inspectors = null;

  Inspector.default_color = [0, 0, 255];

  Inspector.initialize = function(inspectors, config) {
    this.inspectors = inspectors;
    this.inspectors.setDefault('color', this.default_color);
    NodeInspector.initialize(config.inspectors.node_inspector);
    RoadInspector.initialize();
    GridRoadInspector.initialize(config.inspectors.grid_road_inspector);
    RadialRoadInspector.initialize(config.inspectors.radial_road_inspector);
    return NeedsInspector.initialize();
  };

  Inspector.spawn_road_inspector = function(patch) {
    var inspector;
    inspector = this.spawn_inspector(patch, RadialRoadInspector);
    inspector.init();
    return inspector;
  };

  Inspector.spawn_node_inspector = function(patch) {
    var inspector;
    inspector = this.spawn_inspector(patch, NodeInspector);
    inspector.init();
    return inspector;
  };

  Inspector.spawn_plot_inspector = function(patch) {
    var inspector;
    inspector = this.spawn_inspector(patch, PlotInspector);
    inspector.init();
    return inspector;
  };

  Inspector.spawn_needs_inspector = function(patch, type) {
    var inspector;
    inspector = this.spawn_inspector(patch, NeedsInspector);
    inspector.init(type);
    return inspector;
  };

  Inspector.spawn_inspector = function(patch, klass) {
    var inspector;
    inspector = patch.sprout(1, this.inspectors)[0];
    extend(inspector, FSMAgent, MovingAgent, klass);
    return inspector;
  };

  Inspector.prototype.speed = 0.05;

  return Inspector;

})();

NodeInspector = (function(_super) {
  __extends(NodeInspector, _super);

  function NodeInspector() {
    return NodeInspector.__super__.constructor.apply(this, arguments);
  }

  NodeInspector.prototype.current_message = null;

  NodeInspector.prototype.nodes_under_investigation = [];

  NodeInspector.prototype.inspection_radius = 20;

  NodeInspector.prototype.max_distance_factor = 3;

  NodeInspector.initialize = function(config) {
    this.inspection_radius = config.inspection_radius;
    return this.max_distance_factor = config.max_distance_factor;
  };

  NodeInspector.prototype.init = function() {
    this.inspection_radius = NodeInspector.inspection_radius;
    this.max_distance_factor = NodeInspector.max_distance_factor;
    this._set_initial_state('get_message');
    return this.msg_boards = {
      inspect: MessageBoard.get_board('node_built'),
      connect: MessageBoard.get_board('nodes_unconnected'),
      bulldoze: MessageBoard.get_board('bulldoze_path'),
      construction: MessageBoard.get_board('under_construction')
    };
  };

  NodeInspector.prototype.s_get_message = function() {
    this.current_message = this.msg_boards.inspect.get_message();
    if (this.current_message != null) {
      return this._set_state('go_to_endpoint');
    }
  };

  NodeInspector.prototype.s_go_to_endpoint = function() {
    if (this.path == null) {
      this.path = CityModel.instance.roadAStar.getPath(this, this.current_message.patch);
    }
    this._move(this.path[0]);
    if (this._in_point(this.path[0])) {
      this.path.shift();
      if (this.path.length === 0) {
        this.path = null;
        this.nodes_under_investigation = this._get_close_nodes();
        return this._set_state('inspect_endpoint');
      }
    }
  };

  NodeInspector.prototype.s_inspect_endpoint = function() {
    var node_connected;
    node_connected = this._inspect_node(this.nodes_under_investigation.shift());
    if (node_connected || this.nodes_under_investigation.length === 0) {
      this.nodes_under_investigation = [];
      this.current_message = null;
      return this._set_state('get_message');
    }
  };

  NodeInspector.prototype._inspect_node = function(node) {
    var crosses_block, crosses_plot, patch, path, _i, _len;
    if (node.factor > this.max_distance_factor) {
      path = this._get_terrain_path_to(node.node.p);
      crosses_plot = false;
      for (_i = 0, _len = path.length; _i < _len; _i++) {
        patch = path[_i];
        if (Block.is_block(patch)) {
          crosses_block = true;
          patch.under_construction = true;
          this.msg_boards.construction.post_message({
            patch: patch
          });
        }
        patch.under_construction = true;
      }
      if (crosses_plot) {
        this.msg_boards.bulldoze.post_message({
          path: path
        });
      } else {
        this.msg_boards.connect.post_message({
          path: path
        });
      }
      return true;
    }
    return false;
  };

  NodeInspector.prototype._get_close_nodes = function() {
    var factor, node, nodes, nodes_to_check, _i, _len;
    nodes = [];
    if (this.p.node != null) {
      nodes_to_check = RoadNode.road_nodes.inRadius(this.p.node, this.inspection_radius);
    } else {
      nodes_to_check = RoadNode.road_nodes.inRadius(this, this.inspection_radius);
    }
    for (_i = 0, _len = nodes_to_check.length; _i < _len; _i++) {
      node = nodes_to_check[_i];
      factor = this._get_node_distance_factor(node);
      nodes.push({
        node: node,
        factor: factor
      });
    }
    nodes.sort(function(a, b) {
      if (a.factor < b.factor) {
        return 1;
      } else {
        return -1;
      }
    });
    return nodes;
  };

  NodeInspector.prototype._get_node_distance_factor = function(node) {
    var factor, real_dist, road_dist;
    real_dist = this.distance(node);
    road_dist = Road.get_road_distance(this, node);
    return factor = road_dist / real_dist;
  };

  return NodeInspector;

})(Inspector);

RoadInspector = (function(_super) {
  __extends(RoadInspector, _super);

  function RoadInspector() {
    return RoadInspector.__super__.constructor.apply(this, arguments);
  }

  RoadInspector.construction_points = [];

  RoadInspector.initialize = function() {
    return this.construction_points = [];
  };

  RoadInspector.prototype.s_get_inspection_point = function() {
    this.inspection_point = this._get_point_to_inspect();
    if (this.inspection_point != null) {
      return this._set_state('go_to_inspection_point');
    }
  };

  RoadInspector.prototype.s_go_to_inspection_point = function() {
    if (this.inspection_point == null) {
      this._set_state('get_inspection_point');
      return;
    }
    this._move(this.inspection_point);
    if (this._in_point(this.inspection_point)) {
      return this._set_state('find_new_endpoint');
    }
  };

  RoadInspector.prototype._is_valid_construction_point = function(patch) {
    var construction_dist, road_dist;
    road_dist = Road.get_connectivity(patch);
    construction_dist = RoadInspector._get_construction_dist(patch);
    return road_dist > Road.too_connected_threshold && ((construction_dist == null) || construction_dist > Road.too_connected_threshold);
  };

  RoadInspector.prototype._issue_construction = function(patch) {
    RoadInspector.construction_points.push(patch);
    return this.build_endpoint_board.post_message({
      patch: patch
    });
  };

  RoadInspector._valid_point = function(point) {
    return (point != null) && CityModel.is_on_world(point) && !Road.is_road(CityModel.get_patch_at(point));
  };

  RoadInspector._get_construction_dist = function(patch) {
    var dist_to_point, min_dist, point, _i, _len, _ref;
    min_dist = null;
    _ref = RoadInspector.construction_points;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      point = _ref[_i];
      dist_to_point = ABM.util.distance(patch.x, patch.y, point.x, point.y);
      if ((min_dist == null) || dist_to_point < min_dist) {
        min_dist = dist_to_point;
      }
    }
    return min_dist;
  };

  return RoadInspector;

})(Inspector);

RadialRoadInspector = (function(_super) {
  __extends(RadialRoadInspector, _super);

  function RadialRoadInspector() {
    return RadialRoadInspector.__super__.constructor.apply(this, arguments);
  }

  RadialRoadInspector.ring_increment = 4;

  RadialRoadInspector.ring_radius = 6;

  RadialRoadInspector.min_increment = 3;

  RadialRoadInspector.max_increment = 6;

  RadialRoadInspector.initialize = function(config) {
    this.ring_increment = config.ring_increment;
    this.ring_radius = config.ring_radius;
    this.min_increment = config.min_increment;
    return this.max_increment = config.max_increment;
  };

  RadialRoadInspector.prototype.init = function() {
    this.ring_increment = RadialRoadInspector.ring_increment;
    this.ring_radius = RadialRoadInspector.ring_radius;
    this.min_increment = RadialRoadInspector.min_increment;
    this.max_increment = RadialRoadInspector.max_increment;
    this.radius = ABM.util.randomFloat(2 * Math.PI);
    this.direction = ABM.util.oneOf([-1, 1]);
    this._set_initial_state('get_inspection_point');
    this.build_endpoint_board = MessageBoard.get_board('possible_node');
    return this.nodes_built_board = MessageBoard.get_board('node_built');
  };

  RadialRoadInspector.prototype.s_find_new_endpoint = function() {
    if (this._is_valid_construction_point(this.p)) {
      this._issue_construction(this.p);
      return this._set_state('get_inspection_point');
    } else {
      return this._set_state('get_away_from_road');
    }
  };

  RadialRoadInspector.prototype.s_get_away_from_road = function() {
    if (this.circular_direction == null) {
      this.angle_moved = 0;
      this.circular_direction = ABM.util.oneOf([-1, 1]);
    }
    this._circular_move();
    if (this._is_valid_construction_point(this.p)) {
      this.circular_direction = null;
      this.angle_moved = 0;
      this._set_state('find_new_endpoint');
    }
    if (this._lap_completed()) {
      this._set_state('increment_radius');
      this.circular_direction = null;
      return this.start_angle = null;
    }
  };

  RadialRoadInspector.prototype.s_increment_radius = function() {
    this.ring_radius += this.ring_increment;
    return this._set_state('get_inspection_point');
  };

  RadialRoadInspector.prototype._get_point_to_inspect = function() {
    var arc_length, arc_radians, new_angle, polar_coords, x, y;
    arc_length = ABM.util.randomInt2(this.min_increment, this.max_increment);
    polar_coords = this._get_polar_coords();
    arc_radians = arc_length / this.ring_radius;
    new_angle = polar_coords.angle + arc_radians * this.direction;
    x = Math.round(this.ring_radius * Math.cos(new_angle));
    y = Math.round(this.ring_radius * Math.sin(new_angle));
    return {
      x: x,
      y: y
    };
  };

  RadialRoadInspector.prototype._circular_move = function() {
    var angle, angle_increment, point, polar_coords;
    polar_coords = this._get_polar_coords();
    angle_increment = (this.speed / polar_coords.radius) * this.circular_direction;
    this.angle_moved += Math.abs(angle_increment);
    angle = polar_coords.angle + angle_increment;
    point = this._point_from_polar_coords(polar_coords.radius, angle);
    return this._move(point);
  };

  RadialRoadInspector.prototype._point_from_polar_coords = function(radius, angle) {
    var point;
    point = {
      x: radius * Math.cos(angle),
      y: radius * Math.sin(angle)
    };
    return point;
  };

  RadialRoadInspector.prototype._get_polar_coords = function() {
    var polar_coords;
    polar_coords = {
      angle: Math.atan2(this.y, this.x),
      radius: ABM.util.distance(0, 0, this.x, this.y)
    };
    return polar_coords;
  };

  RadialRoadInspector.prototype._lap_completed = function() {
    return this.angle_moved >= 2 * Math.PI;
  };

  return RadialRoadInspector;

})(RoadInspector);

GridRoadInspector = (function(_super) {
  __extends(GridRoadInspector, _super);

  function GridRoadInspector() {
    return GridRoadInspector.__super__.constructor.apply(this, arguments);
  }

  GridRoadInspector.open_list = [];

  GridRoadInspector.closed_list = [];

  GridRoadInspector.initialize = function(config) {
    this.open_list = [];
    this.closed_list = [];
    this.horizontal_grid_size = config.horizontal_grid_size;
    return this.vertical_grid_size = config.vertical_grid_size;
  };

  GridRoadInspector.prototype.horizontal_grid_size = 8;

  GridRoadInspector.prototype.vertical_grid_size = 8;

  GridRoadInspector.prototype.init = function() {
    this.horizontal_grid_size = GridRoadInspector.horizontal_grid_size;
    this.vertical_grid_size = GridRoadInspector.vertical_grid_size;
    if (GridRoadInspector.open_list.length === 0) {
      GridRoadInspector.open_list.push(CityModel.instance.city_hall);
    }
    this._set_initial_state('get_inspection_point');
    return this.build_endpoint_board = MessageBoard.get_board('possible_node');
  };

  GridRoadInspector.prototype.s_populate_open_list = function() {
    this._populate_open_list();
    return this._set_state('get_inspection_point');
  };

  GridRoadInspector.prototype.s_find_new_endpoint = function() {
    if (this._is_valid_construction_point(this.p)) {
      this._issue_construction(this.p);
    }
    return this._set_state('populate_open_list');
  };

  GridRoadInspector.prototype._get_point_to_inspect = function() {
    var node;
    node = GridRoadInspector.open_list.shift();
    GridRoadInspector.closed_list.push(node);
    return node;
  };

  GridRoadInspector.prototype._populate_open_list = function() {
    var node, _i, _len, _ref, _results;
    _ref = this._get_possible_nodes();
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      node = _ref[_i];
      if (!(__indexOf.call(GridRoadInspector.closed_list, node) >= 0) && !(__indexOf.call(GridRoadInspector.open_list, node) >= 0)) {
        _results.push(GridRoadInspector.open_list.push(node));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  GridRoadInspector.prototype._get_possible_nodes = function() {
    var point, points;
    points = [
      {
        x: this.p.x,
        y: this.p.y + this.vertical_grid_size
      }, {
        x: this.p.x + this.horizontal_grid_size,
        y: this.p.y
      }, {
        x: this.p.x,
        y: this.p.y - this.vertical_grid_size
      }, {
        x: this.p.x - this.horizontal_grid_size,
        y: this.p.y
      }
    ];
    ABM.util.shuffle(points);
    return (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = points.length; _i < _len; _i++) {
        point = points[_i];
        _results.push(CityModel.get_patch_at(point));
      }
      return _results;
    })();
  };

  return GridRoadInspector;

})(RoadInspector);

PlotInspector = (function(_super) {
  __extends(PlotInspector, _super);

  function PlotInspector() {
    return PlotInspector.__super__.constructor.apply(this, arguments);
  }

  PlotInspector.prototype.init = function() {
    this._set_initial_state('get_message');
    this.patches_to_check = [];
    return this.msg_boards = {
      inspect: MessageBoard.get_board('possible_plot'),
      created: MessageBoard.get_board('plot_created')
    };
  };

  PlotInspector.prototype.s_get_message = function() {
    this.current_message = this.msg_boards.inspect.get_message();
    if (this.current_message != null) {
      this.inspection_point = this.current_message.patch;
      return this._set_state('go_to_point');
    }
  };

  PlotInspector.prototype.s_go_to_point = function() {
    if (this.inspection_point == null) {
      this._set_state('s_get_message');
      return;
    }
    this._move(this.inspection_point);
    if (this._in_point(this.inspection_point)) {
      return this._set_state('check_possible_plots');
    }
  };

  PlotInspector.prototype.s_check_possible_plots = function() {
    if (this.patches_to_check.length === 0) {
      this.patches_to_check = this._get_patches_to_check();
    }
    this._check_patch(this.patches_to_check.shift());
    if (this.patches_to_check.length === 0) {
      return this._set_state('get_message');
    }
  };

  PlotInspector.prototype._get_patches_to_check = function() {
    var i, invalid, j, p, patches, _i, _j, _ref, _ref1;
    patches = (function() {
      var _i, _len, _ref, _results;
      _ref = this.p.n;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        if (!Road.is_road(p)) {
          _results.push(p);
        }
      }
      return _results;
    }).call(this);
    invalid = [];
    for (i = _i = _ref = patches.length - 1; _i >= 0; i = _i += -1) {
      for (j = _j = 0, _ref1 = patches.length - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; j = 0 <= _ref1 ? ++_j : --_j) {
        if (i === j) {
          break;
        }
        if (this._adyacent(patches[i], patches[j])) {
          invalid.push(patches[j]);
        }
      }
    }
    return (function() {
      var _k, _len, _results;
      _results = [];
      for (_k = 0, _len = patches.length; _k < _len; _k++) {
        p = patches[_k];
        if (!ABM.util.contains(invalid, p)) {
          _results.push(p);
        }
      }
      return _results;
    })();
  };

  PlotInspector.prototype._adyacent = function(patch_a, patch_b) {
    var adyacent, horizontal;
    horizontal = Math.abs(patch_a.x - patch_b.x) === 1 && patch_a.y === patch_b.y;
    adyacent = horizontal || patch_a.x === patch_b.x && Math.abs(patch_a.y - patch_b.y) === 1;
    return adyacent;
  };

  PlotInspector.prototype._check_patch = function(patch) {
    var plot, possible_plot;
    if (patch == null) {
      return;
    }
    if (Plot.is_part_of_plot(patch)) {
      if (patch.plot.under_construction) {
        Plot.destroy_plot(patch.plot);
      } else {
        return;
      }
    }
    if (!this._any_edge_visible(patch)) {
      possible_plot = this._get_plot(patch);
      if (possible_plot != null) {
        plot = Plot.make_plot(possible_plot);
        return this.msg_boards.created.post_message({
          plot: plot
        });
      }
    }
  };

  PlotInspector.prototype._any_edge_visible = function(patch) {
    var current_patch, edge, offset, offsets, _i, _len;
    current_patch = patch;
    offsets = [
      {
        x: 0,
        y: 1
      }, {
        x: 1,
        y: 0
      }, {
        x: 0,
        y: -1
      }, {
        x: -1,
        y: 0
      }
    ];
    edge = false;
    for (_i = 0, _len = offsets.length; _i < _len; _i++) {
      offset = offsets[_i];
      current_patch = patch;
      while (!edge) {
        current_patch = this._get_path_with_offset(current_patch, offset);
        if ((current_patch != null) && Road.is_road(current_patch)) {
          break;
        }
        if ((current_patch == null) || current_patch.isOnEdge()) {
          edge = true;
        }
      }
      if (edge) {
        break;
      }
    }
    return edge;
  };

  PlotInspector.prototype._get_path_with_offset = function(patch, offset) {
    var point;
    point = {
      x: patch.x + offset.x,
      y: patch.y + offset.y
    };
    return CityModel.get_patch_at(point);
  };

  PlotInspector.prototype._get_plot = function(patch) {
    var closed_list, invalid, n, open_list, p, _i, _len, _ref;
    closed_list = [];
    open_list = [patch];
    invalid = false;
    while (open_list.length > 0) {
      p = open_list.shift();
      if (p.isOnEdge() || p.under_construction) {
        invalid = true;
        break;
      }
      _ref = p.n4;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        n = _ref[_i];
        if (!Road.is_road(n) && !ABM.util.contains(open_list, n) && !ABM.util.contains(closed_list, n)) {
          open_list.push(n);
        }
      }
      closed_list.push(p);
    }
    if (!invalid) {
      return closed_list;
    } else {
      return null;
    }
  };

  return PlotInspector;

})(Inspector);

NeedsInspector = (function(_super) {
  __extends(NeedsInspector, _super);

  function NeedsInspector() {
    return NeedsInspector.__super__.constructor.apply(this, arguments);
  }

  NeedsInspector.under_construction = null;

  NeedsInspector.initialize = function() {
    return this.under_construction = {};
  };

  NeedsInspector.prototype.init = function(need) {
    var base_color;
    this.need = need;
    base_color = GenericBuilding.info[this.need].hsl_color;
    this.color = Colors.lighten(base_color, 0.3).map(function(f) {
      return Math.round(f);
    });
    this.visited_plots = [];
    this._set_initial_state('wait_for_population');
    return this.boards = {
      building_needed: MessageBoard.get_board('building_needed')
    };
  };

  NeedsInspector.prototype.s_wait_for_population = function() {
    if (House.population > this._need_threshold()) {
      return this._set_state('get_target_plot');
    }
  };

  NeedsInspector.prototype.s_get_target_plot = function() {
    var plot, plot_list;
    plot_list = (function() {
      var _i, _len, _ref, _results;
      _ref = Plot.plots;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        plot = _ref[_i];
        if (!(this._is_visited(plot))) {
          _results.push(plot);
        }
      }
      return _results;
    }).call(this);
    if (plot_list.length > 0) {
      this.target_plot = ABM.util.oneOf(plot_list);
      this.visited_plots.push(this.target_plot);
    } else {
      this.target_plot = ABM.util.oneOf(this.visited_plots);
    }
    if (this.target_plot != null) {
      return this._set_state('go_to_plot');
    }
  };

  NeedsInspector.prototype.s_go_to_plot = function() {
    if (this.target_point == null) {
      this.target_point = this._get_closest_plot_block(this.target_plot);
    }
    this._move(this.target_point);
    if (this._in_point(this.target_point)) {
      this.target_point = null;
      return this._set_state('circle_plot');
    }
  };

  NeedsInspector.prototype.s_circle_plot = function() {
    var block;
    if (this.plot_circumference == null) {
      this.plot_circumference = this._get_plot_path(this.target_plot);
      this.target_plot = null;
      this.inspected_blocks = {};
    }
    this._move(this.plot_circumference[0]);
    if (this._in_point(this.plot_circumference[0])) {
      block = this.plot_circumference.shift();
      if (!(block.id in this.inspected_blocks)) {
        this._inspect_block(block);
      }
      if (this.plot_circumference.length === 0) {
        this.plot_circumference = null;
        return this._set_state('make_decision');
      }
    }
  };

  NeedsInspector.prototype.s_make_decision = function() {
    var best_fit;
    if (this.possible_blocks == null) {
      this.possible_blocks = this._sort_by_best_fit(this.inspected_blocks);
      this.inspected_blocks = {};
    }
    best_fit = this.possible_blocks.shift();
    if ((best_fit != null) && this._valid_construction(best_fit)) {
      this._notify_building_need(best_fit);
      best_fit = null;
    }
    if (best_fit == null) {
      this.possible_blocks = null;
      return this._set_state('get_target_plot');
    }
  };

  NeedsInspector.prototype._is_visited = function(plot) {
    return this.visited_plots.some(function(visited_plot) {
      return visited_plot.id === plot.id;
    });
  };

  NeedsInspector.prototype._get_closest_plot_block = function(plot) {
    var block, closest_block, dist_to_block, min_dist, _i, _len, _ref;
    min_dist = null;
    closest_block = null;
    _ref = plot.blocks;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      block = _ref[_i];
      dist_to_block = ABM.util.distance(this.p.x, this.p.y, block.x, block.y);
      if ((min_dist == null) || min_dist > dist_to_block) {
        min_dist = dist_to_block;
        closest_block = block;
      }
    }
    return closest_block;
  };

  NeedsInspector.prototype._number_of_neighbours = function(block) {
    var b;
    return ((function() {
      var _i, _len, _ref, _results;
      _ref = block.n4;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        b = _ref[_i];
        if (Block.is_block(b)) {
          _results.push(b);
        }
      }
      return _results;
    })()).length;
  };

  NeedsInspector.prototype._get_plot_path = function(plot) {
    var _traverse;
    _traverse = function(node, current_nodes) {
      var neighbour, _i, _len, _ref;
      current_nodes.push(node);
      _ref = node.n4;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        neighbour = _ref[_i];
        if (!(__indexOf.call(current_nodes, neighbour) >= 0) && Block.is_block(neighbour) && neighbour.plot === plot) {
          current_nodes = _traverse(neighbour, current_nodes);
        }
      }
      return current_nodes;
    };
    return _traverse(this.p, []);
  };

  NeedsInspector.prototype._inspect_block = function(possible_block) {
    var block, blocks_in_radius, covered, dist, _i, _len;
    blocks_in_radius = Block.blocks.inRadius(this.p, this._need_radius());
    covered = 0;
    for (_i = 0, _len = blocks_in_radius.length; _i < _len; _i++) {
      block = blocks_in_radius[_i];
      if (House.has_house(block)) {
        if (House.has_house(block)) {
          dist = block.dist_to_need(this.need);
          if ((dist == null) || dist > this._need_threshold()) {
            covered += block.building.citizens;
          }
        }
      }
    }
    return this.inspected_blocks[possible_block.id] = {
      block: possible_block,
      need_covered: covered
    };
  };

  NeedsInspector.prototype._sort_by_best_fit = function(blocks_dict) {
    var id, info;
    return ((function() {
      var _results;
      _results = [];
      for (id in blocks_dict) {
        info = blocks_dict[id];
        if (this._over_threshold(info.need_covered)) {
          _results.push(info);
        }
      }
      return _results;
    }).call(this)).sort(function(a, b) {
      return b.need_covered - a.need_covered;
    });
  };

  NeedsInspector.prototype._valid_construction = function(block_info) {
    var is_valid;
    is_valid = this._over_threshold(block_info.need_covered);
    is_valid = is_valid && this._away_from_others(block_info.block);
    return is_valid && GenericBuilding.fits_here(block_info.block, this.need);
  };

  NeedsInspector.prototype._over_threshold = function(covered) {
    return covered >= this._need_threshold();
  };

  NeedsInspector.prototype._away_from_others = function(block) {
    var buildings_of_type;
    buildings_of_type = GenericBuilding.get_of_subtype(this.need);
    if (this.need in NeedsInspector.under_construction) {
      buildings_of_type = buildings_of_type.concat(NeedsInspector.under_construction[this.need]);
    }
    return !buildings_of_type.some((function(_this) {
      return function(building) {
        return ABM.util.distance(block.x, block.y, building.x, building.y) < _this._need_radius();
      };
    })(this));
  };

  NeedsInspector.prototype._notify_building_need = function(block_info) {
    this.boards.building_needed.post_message({
      block: block_info.block,
      building_type: this.need
    });
    if (!(this.need in NeedsInspector.under_construction)) {
      NeedsInspector.under_construction[this.need] = [];
    }
    return NeedsInspector.under_construction[this.need].push(block_info.block);
  };

  NeedsInspector.prototype._need_radius = function() {
    return GenericBuilding.info[this.need].radius;
  };

  NeedsInspector.prototype._need_threshold = function() {
    return GenericBuilding.info[this.need].threshold;
  };

  return NeedsInspector;

})(Inspector);

CityModel.register_module(Inspector, ['inspectors'], []);
