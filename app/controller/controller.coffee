names = [
  "Andromeda"
  "Antlia"
  "Apus"
  "Aquarius"
  "Aquila"
  "Ara"
  "Aries"
  "Auriga"
  "Boötes"
  "Caelum"
  "Camelopardalis"
  "Cancer"
  "Canis"
  "Capricornus"
  "Carina"
  "Cassiopeia"
  "Centaurus"
  "Cepheus"
  "Cetus"
  "Chamaeleon"
  "Circinus"
  "Columba"
  "Corvus"
  "Crater"
  "Crux"
  "Cygnus"
  "Delphinus"
  "Dorado"
  "Draco"
  "Equuleus"
  "Eridanus"
  "Fornax"
  "Gemini"
  "Grus"
  "Hercules"
  "Horologium"
  "Hydra"
  "Hydrus"
  "Indus"
  "Lacerta"
  "Leo"
  "Lepus"
  "Libra"
  "Lupus"
  "Lynx"
  "Lyra"
  "Mensa"
  "Microscopium"
  "Monoceros"
  "Musca"
  "Norma"
  "Octans"
  "Ophiuchus"
  "Orion"
  "Pavo"
  "Pegasus"
  "Perseus"
  "Phoenix"
  "Pictor"
  "Pisces"
  "Puppis"
  "Pyxis"
  "Reticulum"
  "Sagitta"
  "Sagittarius"
  "Scorpius"
  "Sculptor"
  "Scutum"
  "Serpens"
  "Sextans"
  "Taurus"
  "Telescopium"
  "Triangulum"
  "Tucana"
  "Ursa"
  "Vela"
  "Virgo"
  "Volans"
  "Vulpecula"
]
newName = names[Math.floor(Math.random()*names.length)]
$('#playername').val(newName)


socket = null
# socket.on "test", ()->
#   alert("hello  world")

Vector = require("Vector")

$(".colorpicker").on "click", ()->
  color = $(event.target).attr("id")
  $(".colorpicker").removeClass("selected")
  $(this).addClass("selected")

$form = $("#form")
$controller = $("#controller")
$joysticks = $("#leftJoy, #rightJoy")
$rightJoy = $("#rightJoy")
$leftJoy = $("#leftJoy")
$submit = $("#submit")
$leave = $("#leave")
options = {
  name: newName
  color: 0xff0000
}


$(".name").on "input", ()->
  options.name = $(this).val()

$(".colorpicker").on "click", ()->
  options.color = parseInt($(this).attr("data-color"), 16)

$submit.on "click", ()->
  if not socket?
    socket = io("/controllers", multiplex: no)
    socket.on "connect", ()->
      if socket?
        socket.emit "join", options
        $form.hide()
        $controller.show()
        $joysticks.find(".fore").css(top:100, left:100)
    socket.on "disconnect", ()->
      if socket?
        $form.show()
        $controller.hide()
        socket = null

$leave.on "click", ()->
  socket.disconnect()

right = new Vector()
left = new Vector()
sendJoystick = (x, y, rightJoy)->
  if socket?
    vector = if rightJoy then right else left
    vector.set(x, y)
    length = vector.length()
    vector.normalize().multiplyScalar(Math.min(length, 1))
    socket.emit((if rightJoy then "right" else "left"), vector)
    $nub = $(this).find(".fore")
    $nub.css("top", vector.y*50+100)
    $nub.css("left", vector.x*50+100)

rightKey = {
  up: 0
  down: 0
  left: 0
  right: 0
}
leftKey = {
  up: 0
  down: 0
  left: 0
  right: 0
}

handleKey = (keyCode, down)->
  rightNeedsUpdate = false
  leftNeedsUpdate = false
  switch keyCode
    when 38 #Up
      rightKey.up = down
      rightNeedsUpdate = true
    when 40 #Down
      rightKey.down = down
      rightNeedsUpdate = true
    when 37 #Left
      rightKey.left = down
      rightNeedsUpdate = true
    when 39 #Right
      rightKey.right = down
      rightNeedsUpdate = true
    when 87 #W
      leftKey.up = down
      leftNeedsUpdate = true
    when 65 #A
      leftKey.left = down
      leftNeedsUpdate = true
    when 83 #S
      leftKey.down = down
      leftNeedsUpdate = true
    when 68 #D
      leftKey.right = down
      leftNeedsUpdate = true
  if leftNeedsUpdate
    sendJoystick.call($leftJoy,leftKey.right-leftKey.left, leftKey.down-leftKey.up, false)
  if rightNeedsUpdate
    sendJoystick.call($rightJoy,rightKey.right-rightKey.left, rightKey.down-rightKey.up, true)

$(window).on "keydown", (event)->
  handleKey(event.keyCode, 1)

$(window).on "keyup", (event)->
  handleKey(event.keyCode, 0)

$joysticks.on "touchstart", (event)->
  $this = $(this)
  rightJoy = $this.is("#rightJoy")
  if event.originalEvent.targetTouches.length
    offset = $this.offset()
    sendJoystick.call(this, 
      (event.originalEvent.targetTouches[0].pageX - offset.left - 100)/100,
      -(event.originalEvent.targetTouches[0].pageY - offset.top - 100)/100,
      rightJoy)
  event.preventDefault()
  $this.on "touchmove", (event)->
    if event.originalEvent.targetTouches.length
      offset = $this.offset()
      sendJoystick.call(this, 
        (event.originalEvent.targetTouches[0].pageX - offset.left - 100)/100,
        (event.originalEvent.targetTouches[0].pageY - offset.top - 100)/100,
        rightJoy)
    event.preventDefault()
  $this.on "touchend touchleave", ()->
    sendJoystick.call(this, 0, 0, rightJoy)
    $this.off "touchmove touchend"
    event.preventDefault()



