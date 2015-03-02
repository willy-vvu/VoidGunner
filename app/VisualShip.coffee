Ship = require "Ship"
module.exports = class VisualShip extends PIXI.DisplayObjectContainer
  constructor: (ship)->
    super
    @ship = new Ship({})
    @ship.copy(ship)
    @id = ship.id
    @type = "ship"
    
    @shipContainer = new PIXI.DisplayObjectContainer()
    texture = PIXI.Texture.fromImage("images/Spaceship.png")
    @shipSprite = new PIXI.Sprite(texture)
    @shipSprite.anchor.set(0.5, 0.5)
    @shipSprite.scale.set(1/500, 1/500)
    @shipSprite.tint = @ship.color
    @shipContainer.addChild(@shipSprite)

    texture = PIXI.Texture.fromImage("images/shieldy.png")
    @shieldSprite = new PIXI.Sprite(texture)
    @shieldSprite.anchor.set(0.5, 0.5)
    @shieldSprite.scale.set(1.3/450, 1.3/450)
    @addChild(@shieldSprite)
    @shieldSprite.blendMode = PIXI.blendModes.ADD

    texture = PIXI.Texture.fromImage("images/shield hitY.png")
    @shieldHit = new PIXI.Sprite(texture)
    @shieldHit.anchor.set(0.5, 0.5)
    @shieldHit.scale.set(1.5/500, 1.5/500)
    @addChild(@shieldHit)
    @shieldHit.blendMode = PIXI.blendModes.ADD

    #@shieldSprite.tint = @ship.color
    @position.x = @ship.position.x
    @position.y = @ship.position.y
    @shipContainer.rotation = @ship.rotation

    flameTextures = (PIXI.Texture.fromImage(image) for image in [
        "images/flame2.png"
        "images/flame3.png"
        "images/flame.png"
        "images/flame4.png"
        "images/flame5.png"
        "images/flame6.png"
    ])
    console.log flameTextures
    @flameCounter = 0
    @flameSprites = (new PIXI.Sprite(texture) for texture in flameTextures)
    for sprite in @flameSprites
        sprite.anchor.set(0.5, 0)
        sprite.scale.set(0.8/500, 0.8/500)
        sprite.rotation = -Math.PI/2
        sprite.position.x = -0.85
        sprite.visible = false
        sprite.blendMode = PIXI.blendModes.ADD
        @shipContainer.addChild(sprite)
    @addChild(@shipContainer)
    @nameTag = new PIXI.Text(@ship.name, { font: "100px Akashi", align: "center", fill: "#FFFFFF"})
    @nameTag.anchor.set(0.5, 0.5)
    @nameTag.position.set(0, -0.8)
    @nameTag.scale.set(1/200, 1/200)
    @addChild(@nameTag)

  update: ()->
    @ship.update()
    @nameTag.setText("#{@ship.name} #{@ship.reputation}")
    if @flameCounter++%5 is 0
        randomly = Math.floor(Math.random()*@flameSprites.length)
        for sprite,i in @flameSprites
            sprite.visible = i is randomly
    @shieldHit.alpha = Math.min(Math.max(0,1.2-@ship.capacitor/10),1)
    @shieldSprite.alpha = @ship.health/100
    @position.x = 0.9*@position.x + 0.1*@ship.position.x
    @position.y = 0.9*@position.y + 0.1*@ship.position.y
    newRotation = @shipContainer.rotation-Math.PI*2
    if Math.abs(newRotation - @ship.rotation) < Math.abs(@shipContainer.rotation - @ship.rotation)
      @shipContainer.rotation = newRotation
    newRotation = @shipContainer.rotation+Math.PI*2
    if Math.abs(newRotation - @ship.rotation) < Math.abs(@shipContainer.rotation - @ship.rotation)
      @shipContainer.rotation = newRotation
    @shipContainer.rotation = 0.9*@shipContainer.rotation + 0.1*@ship.rotation
