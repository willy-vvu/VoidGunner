Vector = require "./Vector"

module.exports = class Projectile
  constructor: ()->
    @type = "projectile"
    @position = new Vector()
    @velocity = new Vector()
    @id = ""+Math.random()
   # @hit = false
    #power = damage dealt to shield
    #@power = 20
    # Lifetime in seconds
    @lifetime = 5
    ## \/\/\/\/
    #@color = ####
    @ownerID = ""

  update: ()->
    @position.add(@velocity)
    @lifetime = Math.max(0, @lifetime - 1/60)

  copy: (object)->
    @position.copy(object.position)
    @velocity.copy(object.velocity)
    @id = object.id
    @lifetime = object.lifetime
    @ownerID = object.ownerID