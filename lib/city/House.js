// Generated by CoffeeScript 1.7.1
var House;

House = (function() {
  function House() {}

  House.breed_name = 'houses';

  House.breed = null;

  House.patchSet = function() {
    var breed, _i, _len, _ref;
    if (this.breed == null) {
      _ref = ABM.patches.breeds;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        breed = _ref[_i];
        if (breed.name === this.breed_name) {
          this.breed = breed;
          break;
        }
      }
    }
    return this.breed;
  };

  House.set_breed = function(patch) {
    this.patchSet().setBreed(patch);
    CityModel.instance.terrainAStar.setWalkable(patch, false);
    return patch.color = [100, 0, 0];
  };

  House.isHouseHere = function(patch) {
    return patch.breed === this.patchSet();
  };

  return House;

})();
