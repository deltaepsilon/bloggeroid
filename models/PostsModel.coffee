# Posts data model, loaded on client and server
#Post:
#  date: Date
#  title: escaped string
#  body: raw string -- no escaping html
#  authorName: escaped author name
#  authorId: User._id
#  active: boolean
#  revision: uuid
#  comments: [
#   {
#     commenterName: escaped string
#     commenterEmail: escaped string
#     date: Date
#     body: escaped text
#   }
#  ]




Posts = new Meteor.Collection "posts"

Posts.allow(
  insert: (userId, post) ->
    return false;
  update: (userId, post) ->
    if userId != post.authorId
      return false
    return true
  remove: (userId, post) ->
    if userId != post.authorId
      return false
    return true
)

Meteor.methods(
  createPost: (title, body, active) ->
    if !(title || body || active)
      return (throw new Meteor.Error 400, 'Required parameter missing')
    if typeof title != 'string'
      return (throw new Meteor.Error 413, 'Title is not a string')
    if typeof body != 'string'
      return (throw new Meteor.Error 413, 'Body is not a string')
    if typeof active != 'boolean'
      return (throw new Meteor.Error 413, 'Active is not a boolean')

    user = Meteor.user()
    if !this.userId || !user
      return (throw new Meteor.Error 403, 'You have to be logged in to post anything. Sorry Charlie.');

    return Posts.insert(
      date: new Date()
      title: _.escape title
      body: _.escape body
      active: active
      authorName: user && user.username || 'test'
      authorId: this.userId
      comments: []
    )
  updatePost: (postId, dataKey, content) ->
    if !(postId || dataKey || content)
      throw new Meteor.Error 400, 'Required parameter missing'
    if typeof content != 'string'
      throw new Meteor.Error 413, 'Post content is not a string'
    if !this.userId
      throw new Meteor.Error 403, 'You have to be logged in to post anything. Sorry Charlie.'
    updateSet = {}
    updateSet[dataKey] = content
    Posts.update postId,
      $set:
        updateSet

  addComment: (commenterName, commenterEmail, body, postId) ->
    if !(commenterName || commenterEmail || body || post)
      throw new Meteor.Error 400, 'Required parameter missing'
    if typeof commenterName != 'string'
      throw new Meteor.Error 400, 'Comment author name missing'
    if typeof commenterEmail != 'string'
      throw new Meteor.Error 400, 'Comment author email missing'
    if typeof body != 'string'
      throw new Meteor.Error 400, 'Comment body missing'
    if typeof postId != 'string'
      throw new Meteor.Error 400, 'Post ID missing... cannot assign comment to the post', postId

    emailRegex = new RegExp(/^([\w\.\-]+)@([\w\-]+)((\.(\w){2,3})+)$/i)
    if !emailRegex.test commenterEmail
      throw new Meteor.Error 413, 'Email does not appear to be valid'

    Posts.update postId,
      $addToSet:
        comments:
          commenterName: _.escape commenterName
          commenterEmail: _.escape commenterEmail
          date: new Date()
          body: _.escape body
)