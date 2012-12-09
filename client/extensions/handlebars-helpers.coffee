Handlebars.registerHelper 'isLoggedIn', ->
  return !!Meteor.user() ? 'true' : 'false'

Handlebars.registerHelper 'raw', (html) ->
  return new Handlebars.SafeString(html)
