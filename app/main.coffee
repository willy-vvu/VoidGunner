renderer = new PIXI.autoDetectRenderer(window.innerWidth, window.innerHeight, transparent: true)
stage = new PIXI.Stage(0xffffff)

backgroundTexture = new PIXI.Texture.fromImage("images/background_space.png")
background = new PIXI.TilingSprite(backgroundTexture, 6000, 4000)
stage.addChild(background)

container = new PIXI.DisplayObjectContainer()
stage.addChild(container)

$("body").append(renderer.view)


VisualShip = require "VisualShip"
VisualProjectile = require "VisualProjectile"
Utils = require "Utils"
world = []

# Your setup code gos here!
socket = io("/screens")
socket.on "disconnect", ()->
  for entity in world
    container.removeChild(entity)
  world = []
socket.on "update", (added, updated, deleted)->
  for object in added
    if object.type is "ship"
      vship = new VisualShip(object)
      container.addChild(vship)
      Utils.addToArray(world, vship)
    else if object.type is "obstacle" 
      null

    else if object.type is "projectile"
      vproj = new VisualProjectile(object)
      vproj.projectileSprite.tint = Utils.findById(world, object.ownerID)?.ship?.color or 0xffffff
      container.addChild(vproj)
      Utils.addToArray(world, vproj)
  for object in updated
    if object.type is "ship"
      vship = Utils.findById(world, object.id)
      if vship?
        vship.ship.copy(object)

  for object in deleted
    vobj = Utils.findById(world, object.id)
    if vobj?
      container.removeChild(vobj)
      Utils.removeFromArray(world, object)



do resize = ()->
  renderer.resize(window.innerWidth, window.innerHeight)
  container.scale.set(window.innerWidth/16, window.innerWidth/16)
  background.scale.set(window.innerWidth/3000, window.innerWidth/3000)
window.addEventListener("resize", resize)




updatePhysics = ()->
  for entity in world
    entity.update()
    if entity.type is "projectile" and entity.projectile.lifetime?
      if not entity.projectile.lifetime > 0
        container.removeChild(entity)
  world = world.filter (entity)->(if entity.type is "projectile" and entity.projectile.lifetime? then entity.projectile.lifetime>0 else true)

physicsClock = 0
lastUpdate = Date.now()

view = 0
$(window).on "keydown", (event)->
  switch event.keyCode
    when 39 #Right
      view++
    when 37 #Left
      view--

do render = ()->
  container.position.x = -view*window.innerWidth

  deltaTime = Date.now() - lastUpdate
  lastUpdate += deltaTime
  newPhysicsClock = physicsClock+deltaTime
  for i in [1..10]
    if physicsClock < newPhysicsClock
      updatePhysics()
      physicsClock += 1000/60



  # Your render code goes here!

  renderer.render(stage)

  if window.requestAnimationFrame?
    window.requestAnimationFrame(render)
  else
    setTimeout(render, 1000/60)
