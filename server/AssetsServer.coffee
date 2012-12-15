Meteor.publish 'assets', ->
  return Assets.find(
    $or: [
      authorId: this.userId
    ]
  ,
    sort:
        date: -1
  )

Meteor.methods(
  createAsset: (asset, title, size, type) ->
    console.log 'starting the creation'
    if !(asset || title || size || type)
      console.log '1'
      throw (new Meteor.Error 400, 'Required parameter missing')
    if typeof title != 'string'
      console.log '2'
      throw (new Meteor.Error 413, 'Title is not a string')
    if typeof size != 'number'
      console.log '3'
      throw (new Meteor.Error 413, 'Size is not a number')
    if typeof type != 'string'
      console.log '4'
      throw (new Meteor.Error 413, 'Type is not a string')
    if !this.userId
      console.log '5'
      throw (new Meteor.Error 403, 'You have to be logged in to create anything. Sorry Charlie.')

    fs = __meteor_bootstrap__.require 'fs'
    root = 'public/'
    folder = 'assets/'
    path = root + folder + title
    encoding = 'binary'
    fs.writeFile path, asset, encoding
    console.log 'writing to mongo'
    return Assets.insert(
      date: new Date()
      title: _.escape title
      size: size
      type: _.escape type
      uri: folder + title
      authorId: this.userId
    )

  removeAsset: (id) ->
    console.log 'id', id
    folder = 'public/'
    asset = Assets.findOne(id)
    if !asset
      console.log 'no asset available'
#      return (throw (new Meteor.Error 500, 'Failed to find file'))
    fs = __meteor_bootstrap__.require 'fs'
    fs.unlink folder + asset.uri
#    , (error) ->
#      if error
#        console.log 'unlink error:', error
#        return (throw (new Meteor.Error 500, 'Failed to unlink file in filesystem'))
#      else
#        console.log 'no error'
    Assets.remove asset._id
)