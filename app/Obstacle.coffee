# abstract class for in game obstacles


# check syntax
module.exports = class Obstacle
  constructor: ()->
    @type = "obstacle"
    # anchor point?
    @position = new Vector()
    @velocity = new Vector()
    @rotation = 0
    # undefined variables - left to sub classes
    # check syntax
    # @rotation @health (value or infinite) @color
  update: ()->
    @position.add(@velocity)
    @rotation+=0.01