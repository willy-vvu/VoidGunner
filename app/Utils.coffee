module.exports = class Utils
  @removeFromArray = (array, object)->
    if object?
      for obj, i in array
        if object.id is obj.id
          array.splice(i, 1)
          return true
    return false
  @addToArray = (array, object)->
    if object?
      for obj, i in array
        if object.id is obj.id
          return false
      array.push(object)
      return true
    return false
  @findById = (array, id)->
    for obj, i in array
      if id is obj.id
        return obj
    return null