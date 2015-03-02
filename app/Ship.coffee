Vector = require "./Vector"

module.exports = class Ship
  constructor: (options)->
    @type = "ship"
    @position = new Vector(8, 4.5)
    @velocity = new Vector()
    @rotation = -Math.PI/2
    # health 0 - 100
    @health = 100
    # capacitor 0 - 100
    # if under 100, unable to heal
    @capacitor = 100
    #
    @name = options.name or "Orion"
    @color = options.color or 0
    @reputation = 0
    @shooting = false
    @targetVelocity = new Vector()

  update: ()->
    @position.add(@velocity)
    if @position.y<0
      @position.y = 0
    if @position.y>9
      @position.y = 9
    @velocity.x = @velocity.x * 0.9 + @targetVelocity.x * 0.1
    @velocity.y = @velocity.y * 0.9 + @targetVelocity.y * 0.1
    if @capacitor < 100
      @capacitor = Math.min(100, @capacitor + 20/60)
      # health will not increaase until capacitor is zero
    else if @health < 100
      @health = Math.min(100, @health + 15/60)
      
  copy: (object)->
    @position.copy(object.position)
    @velocity.copy(object.velocity)
    @targetVelocity.copy(object.targetVelocity)
    @rotation = object.rotation
    # health 0 - 100
    @health = object.health
    # capacitor 0 - 100
    # if under 100, unable to heal
    @capacitor = object.capacitor
    #
    @name = object.name
    @color = object.color
    @reputation = object.reputation
