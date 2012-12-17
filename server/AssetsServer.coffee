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
    console.log 'creating asset'
    console.log 'starting the creation'
    if !(asset || title || size || type)
      throw (new Meteor.Error 400, 'Required parameter missing')
    if typeof title != 'string'
      throw (new Meteor.Error 413, 'Title is not a string')
    if typeof size != 'number'
      throw (new Meteor.Error 413, 'Size is not a number')
    if typeof type != 'string'
      throw (new Meteor.Error 413, 'Type is not a string')
    if !this.userId
      throw (new Meteor.Error 403, 'You have to be logged in to create anything. Sorry Charlie.')

    fs = __meteor_bootstrap__.require 'fs'
    root = 'public/'
    folder = 'assets~/'
    path = root + folder + title
    encoding = 'binary'
    fs.writeFile path, asset, encoding, (error) ->
      if error
        console.log 'error', error

    console.log 'writing to mongo'
    Assets.insert(
      date: new Date()
      title: _.escape title
      size: size
      type: _.escape type
      uri: folder + title
      authorId: this.userId
    )

  removeAsset: (id) ->
    folder = 'public/'
    asset = Assets.findOne(id)
    if !asset
      console.log 'no asset available'
    fs = __meteor_bootstrap__.require 'fs'
    fs.unlink folder + asset.uri, (error) ->
      if error
        console.warn 'error: ', error
    Assets.remove asset._id
)