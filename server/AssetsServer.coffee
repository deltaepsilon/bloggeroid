Meteor.publish 'assets', ->
  return Assets.find(
    $or: [
      authorId: this.userId
    ]
  ,
    sort:
        date: -1
  )

BASE = null
getBase = ->
  if !BASE
    require = __meteor_bootstrap__.require
    path = require 'path'
    #    Set up AWS path
    base = path.resolve '.'
    if base == '/'
      base = path.dirname global.require.main.filename
    BASE = base
  return BASE

getParams = ->
  require = __meteor_bootstrap__.require
  path = require 'path'
  base = getBase()
  return require(path.resolve base + '/server/parameters.json')

loadAWS = ->
  require = __meteor_bootstrap__.require
  fs = require 'fs'
  path = require 'path'

  base = getBase()
  awsPath = '/node_modules/aws-sdk'
  publicPath = path.resolve base + '/public/' + awsPath
  staticPath = path.resolve base + '/static/' + awsPath

  #    The AWS-SDK has an old version of libxmljs.  Upgrade it using picaron's workaround found here: https://github.com/polotek/libxmljs/issues/144
  if fs.existsSync publicPath
    aws = require publicPath
  else if fs.existsSync staticPath
    aws = require staticPath

  #    Configure AWS
  aws.config.loadFromPath(path.resolve base + '/server/aws.json')
  return aws


Meteor.methods(
  createAsset: (blob, title, size, type) ->
    if !(blob || title || size || type)
      throw (new Meteor.Error 400, 'Required parameter missing')
    if typeof title != 'string'
      throw (new Meteor.Error 413, 'Title is not a string')
    if typeof size != 'number'
      throw (new Meteor.Error 413, 'Size is not a number')
    if typeof type != 'string'
      throw (new Meteor.Error 413, 'Type is not a string')
    if !this.userId
      throw (new Meteor.Error 403, 'You have to be logged in to create anything. Sorry Charlie.')


    require = __meteor_bootstrap__.require
    fs = require 'fs'
    path = require 'path'

    base = getBase()
    aws = loadAWS()
    s3 = new aws.S3()

#    Grab bucket params
    params = getParams()

    userId = this.userId
    root = 'public/'
    folder = 'assets~/'
    path = root + folder
    filePath = path + title
    uri = folder + title
    encoding = 'binary'
    fs.writeFile filePath, blob, encoding, (error) ->
      if error
        throw (new Meteor.Error error)
      else
        s3Title = params.aws.s3.path + Date.now() + '_' + title
        callback = (error, data) ->
          if error
            throw (new Meteor.Error error)
          else
            Fiber(()->
              Assets.insert(
                date: new Date()
                title: _.escape title
                size: size
                type: _.escape type
                uri: uri
                s3:
                  eTag: data.ETag,
                  key: s3Title
                  uri: params.aws.s3.uri + s3Title
                authorId: userId
              )
              fs.unlink filePath, (error) ->
                if error
                  throw (new Meteor.Error 404, 'File not found')
            ).run()

        body = fs.readFileSync filePath

#       Put the s3 object
        s3.client.putObject
          Bucket: params.aws.s3.bucketName
          Key: s3Title
          ContentEncoding: encoding
          ContentType: type
          Body: body
          StorageClass: params.aws.s3.storageClass
          CacheControl: params.aws.s3.cacheControl,
          ACL: params.aws.s3.acl
        , callback

  removeAsset: (id) ->
    asset = Assets.findOne(id)
    if !asset
      throw (new Meteor.Error 404, 'Asset not found. Could not be deleted.')
    require = __meteor_bootstrap__.require
    fs = require 'fs'

    aws = loadAWS()
    s3 = new aws.S3()
    s3.client.listBuckets (error, data) ->
      console.log 'buckets: ', data
    params = getParams()


    callback = (error, data) ->
      console.log 'inside callback error, data', error, data
      if error
        throw (new Meteor.Error error)
      else
        console.log 'enable fiber'
        Fiber(() ->
          console.log 'inside fiber'
          Assets.remove asset._id
        ).run()


#        s3 delete does not work right now.  AWS-SDK is throwing nasty errors
    console.log
      Bucket: params.aws.s3.bucketName
      Key: asset.s3.key
    s3.client.deleteObject
      Bucket: params.aws.s3.bucketName
      Key: asset.s3.key
    , callback
)