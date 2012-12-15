Meteor.subscribe 'posts'

selectors =
  post: '.post'
  postLeaveComment: '.post-leave-comment'
  commentAuthorName: '#comment-author-name'
  commentAuthorEmail: '#comment-author-email'
  commentBody: '#comment-body'
  commentPublish: '#comment-publish'
  postAddWrapper: '#post-add-wrapper'
  postAddTitle: '#post-title-input'
  postAddBody: '#post-body-input'

Template.blogPosts.posts = ->
  return Posts.find({active: true})

Template.blogPost.post = ->
  return this

Template.postComment.comment = ->
  date = new Date(this.date)
  this.date = date.toLocaleDateString()
  return this

Template.blogPost.events(
  'click .comment-publish': (e) ->
    commentWrapper = $(e.target).parent(selectors.postLeaveComment)
    Meteor.call 'addComment',
      commentWrapper.find(selectors.commentAuthorName).val(),
      commentWrapper.find(selectors.commentAuthorEmail).val(),
      commentWrapper.find(selectors.commentBody).val(),
      commentWrapper.parent(selectors.post).attr 'data-post-id'

  'click .comment-add': (e) ->
    post = $(e.target).parent(selectors.post)
    if (!post.find(selectors.commentPublish))
      post.append Template.commentAdd

  'blur [contenteditable="true"]': (e) ->
    target = $(e.target)
    id = target.parent(selectors.post).attr 'data-post-id'
    dataKey = target.attr 'data-key'
    html = e.target.innerText
    Meteor.call 'updatePost',
      id,
      dataKey,
      html
)

Template.postAdd.events(
  'click #post-create-new': (e) ->
    postAddWrapper = $(e.target).parent(selectors.postAddWrapper)
    Meteor.call 'createPost',
      postAddWrapper.find(selectors.postAddTitle).val(),
      postAddWrapper.find(selectors.postAddBody).val(),
      true
)