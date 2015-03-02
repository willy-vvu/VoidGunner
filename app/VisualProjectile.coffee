Projectile = require "Projectile"
module.exports = class VisualProjectil extends PIXI.DisplayObjectContainer
  constructor: (projectile)->
    super
    @projectile = new Projectile({})
    @projectile.copy(projectile)
    @id = projectile.id
    @type = "projectile"
    texture = PIXI.Texture.fromImage("images/Projectile.png")
    @projectileSprite = new PIXI.Sprite(texture)
    @projectileSprite.anchor.set(0.5, 0.5)
    @projectileSprite.scale.set(1/428, 1/428)
    @projectileSprite.blendMode = PIXI.blendModes.ADD
    # @projectileSprite.tint = @projectile.color
    @addChild(@projectileSprite)
    @position.x = @projectile.position.x
    @position.y = @projectile.position.y
    @rotation = Math.atan2(@projectile.velocity.y, @projectile.velocity.x)

  update: ()->
    @projectile.update()
    @position.x = @projectile.position.x
    @position.y = @projectile.position.y
