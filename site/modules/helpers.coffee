property = require './property.coffee'

exports.helpers =
  siteName: -> 'BuzyBees'


exports.dynamicHelpers =
  pageTitle: property.create()

  flashMessages: (req, res) ->
    html = '';

    ['error', 'info'].forEach (type) ->
      messages = req.flash type
      if messages.length > 0
        html += new FlashMessage(type, messages).toHTML();

    html


class FlashMessage
  constructor: (@type, messages) ->
    @messages = if typeof messages == 'string' then [messages] else messages

  icon: ->
    switch @type
      when 'info' then 'ui-icon-info'
      when 'error' then 'ui-icon-alert'

  stateClass: ->
    switch @type
      when 'info' then 'ui-state-highlight'
      when 'error' then 'ui-state-error'

  toHTML: ->
    "<div class='ui-widget flash'>" +
    "<div class='#{this.stateClass()} ui-corner-all'>" +
    "<p><span class='ui-icon #{this.icon()}'></span>#{this.messages.join(", ")}</p>" +
    "</div>" +
    "</div>"


