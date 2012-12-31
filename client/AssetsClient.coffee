Meteor.subscribe 'assets'

selectors =
  asset: '.asset'

Template.assetsList.assets = ->
  return Assets.find({authorId: this.userId})

Template.assetDescription.asset = ->
  return this

Template.assetDescription.events(
  'click .asset-remove': (e) ->
    target = $(e.target)
    id = target.parent(selectors.asset).attr('id')
    Meteor.call 'removeAsset', id, (error) ->
      if error
        console.warn 'error: ', error
)

Template.assetUpload.events(
  'drop #asset-upload-dropzone': (e) ->
    e.stop()
    $(e.target).removeClass 'dropzone-hover'
    new AssetUpload(e)

  'dragenter #asset-upload-dropzone': (e) ->
    e.stop()
    $(e.target).addClass 'dropzone-hover'

  'dragleave #asset-upload-dropzone': (e) ->
    e.stop()
    $(e.target).removeClass 'dropzone-hover'

  'dragover #asset-upload-dropzone': (e) ->
    e.stop();
)

class AssetUpload
  constructor: (e) ->
    @fileList = e.dataTransfer.files
    i = @fileList.length
    while i--
      @uploadFile @fileList[i]

  uploadFile: (file) ->
    reader = new FileReader()
    reader.onload = (e) =>
      @sendToServer file, reader
    reader.readAsBinaryString file

  sendToServer: (file, reader) ->
    Meteor.call 'createAsset', reader.result, file.name, file.size, file.type


