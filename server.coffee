express = require "express"
app = express()
app.use("/", express.static(__dirname + "/public"))
socketio = require "socket.io"

Ship = require "./app/Ship"
Projectile = require "./app/Projectile"
Vector = require "./app/Vector"
Utils = require "./app/Utils"
tempVector = new Vector()
world = []
addedQueue = []
updateQueue = []
removeQueue = []
server = app.listen(80)
io = socketio.listen(server)

controllers = io.of("/controllers")
screens = io.of("/screens")

players = 0
controllers.on "connect", (socket)->
  socket.on "join", (options)->
    options.name = options.name[..10]
    socket.ship = new Ship(options)
    socket.ship.id = socket.id
    # Use controllers.sockets
    if Utils.addToArray world, socket.ship
      players++
      console.log "#{players} player#{if players is 1 then '' else 's'} connected"
      Utils.addToArray(addedQueue, socket.ship)

  socket.on "left", (data)->
    vector = tempVector.copy(data)
    length = vector.length()
    vector.normalize().multiplyScalar(Math.min(length, 1))
    if socket.ship?
      socket.ship.targetVelocity.copy(vector).multiplyScalar(5/60)

  socket.on "right", (data)->
    vector = tempVector.copy(data)
    length = vector.length()
    vector.normalize().multiplyScalar(Math.min(length, 1))
    if socket.ship?
      if length is 0
        socket.ship.shooting = false
      else
        socket.ship.shooting = true
        socket.ship.rotation = Math.atan2(vector.y, vector.x)


  socket.on "disconnect", ()->
    # Remove ship from world
    if socket.ship?
      players--
      console.log "#{players} player#{if players is 1 then '' else 's'} connected"
      Utils.removeFromArray world, socket.ship
      Utils.addToArray(removeQueue, socket.ship)

screens.on "connect", (socket)->
  socket.emit "update", world, [], []

updatePhysics = ()->
  ticks++
  for entity in world
    entity.update()
    if entity instanceof Ship
      if entity.health<=0
        Utils.addToArray(removeQueue, entity)
      else
        for entity2 in world when entity2 instanceof Projectile
          if entity2.lifetime > 0 and entity2.ownerID isnt entity.id and entity2.position.distanceTo(entity.position) < 1
            Utils.addToArray(removeQueue, entity2)
            entity2.lifetime = 0
            entity.capacitor = 0
            entity.health -= 10
            if entity.health <= 0
              killer = Utils.findById(world, entity2.ownerID)
              if killer?
                killer.reputation += entity.reputation + 1
                entity.reputation = 0
        # If you're shooting, then spawn projectiles at your location, and copying your rotation
        if entity.shooting and ticks%12 is 0
          projectile = new Projectile()
          projectile.position.copy(entity.position)
          projectile.velocity.set(
            Math.cos(entity.rotation),
            Math.sin(entity.rotation)
          ).multiplyScalar(7/60)
          projectile.ownerID = entity.id
          if Utils.addToArray(world, projectile)
            Utils.addToArray(addedQueue, projectile)
      Utils.addToArray(updateQueue, entity)
  # Clean dead projectiles
  world = world.filter (entity)->
    if entity.lifetime?
      return entity.lifetime>0
    return true

  for ship in removeQueue when ship instanceof Ship
    for socket in controllers.sockets
      if socket?.ship? and socket.ship is ship
        socket.disconnect()


physicsClock = 0
ticks = 0
lastUpdate = Date.now()

do networkStuff = ()->
  deltaTime = Date.now() - lastUpdate
  lastUpdate += deltaTime
  newPhysicsClock = physicsClock+deltaTime
  for i in [1..10]
    if physicsClock < newPhysicsClock
      updatePhysics()
      physicsClock += 1000/60
  
  for socket in screens.sockets
    if socket?.volatile?
      socket.volatile.emit "update", addedQueue, updateQueue, removeQueue
  addedQueue=[]
  updateQueue=[]
  removeQueue=[]

  setTimeout(networkStuff, 1000/30)