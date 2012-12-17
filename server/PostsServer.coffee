Meteor.publish 'posts', ->
  return Posts.find(
    $or: [
      active: true
#      Comment out authorID to allow logged in users to read all posts.
#      authorId: this.userId
    ]
  ,
    sort:
        date: -1
  )

Meteor.startup ->
  console.log 'starting up'
  if Posts.find().count() == 0
    console.log 'empty'
    Meteor.call 'createPost', 'First Post', 'This is a post body text field', true, (error) ->
      if error
        console.warn 'error: ', error