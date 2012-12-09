Event.prototype.stop = ->
  this.preventDefault()
  this.stopPropagation()