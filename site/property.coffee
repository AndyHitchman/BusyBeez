exports.creator = () -> 
  value = null
  {
      get: 
        () ->
          value
      set: 
        (new_value) ->
          value = new_value
  }

exports.create = () ->
  () -> exports.creator()

