Handlebars.registerHelper 'formattedDate', (dateString) ->
  date = new Date(dateString)
  return date.toLocaleDateString()

Handlebars.registerHelper 'isLoggedIn', ->
  return !!Meteor.user() ? 'true' : 'false'

Handlebars.registerHelper 'raw', (html) ->
  return new Handlebars.SafeString(html)

Handlebars.registerHelper 'isImage', (type) ->
  regex = /image\/\w+/
  cleaned = type.replace('&#x2F;', '/')
  if regex.test(cleaned)
    return cleaned
  return false

Handlebars.registerHelper 'isVideo', (type) ->
  regex = /video\/\w+/
  cleaned = type.replace('&#x2F;', '/')
  if regex.test(cleaned)
    return cleaned
  return false

Handlebars.registerHelper 'isAudio', (type) ->
  regex = /audio\/\w+/
  cleaned = type.replace('&#x2F;', '/')
  if regex.test(cleaned)
    return cleaned
  return false