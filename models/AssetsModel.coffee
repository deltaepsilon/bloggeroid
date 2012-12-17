# Assets data model, loaded on client and server
#Asset:
#  date: Date
#  title: escaped string
#  size: integer (bytes)
#  type: string (mime type)
#  uri: string

#  authorId: User._id



Assets = new Meteor.Collection "assets"

Assets.allow(
  insert: () ->
    return false;
  update: (asset) ->
    if this.userId != asset.authorId
      return false
    return true
  remove: (asset) ->
    if this.userId != asset.authorId
      return false
    return true
)