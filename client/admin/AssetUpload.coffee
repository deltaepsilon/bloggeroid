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
    reader.onload = (image) =>
      @handleUpload image
    reader.readAsDataURL file
    @sendToS3 file

  handleUpload: (image) ->
    console.log 'handle upload', image
  sendToS3: (file) ->
    console.log 'send to s3', file
#    size = file.size
#    name = file.name
#    type = file.type


