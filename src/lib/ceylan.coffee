###

ceylan
https://github.com/lambda2/ceylan

Copyright (c) 2014 André Aubin
Licensed under the MIT license.

###

'use strict'

#console.log(_)
#if not _
#  if not window then _ = require '../../node_modules/underscore/underscore.js'
#  else throw new Error("Requires underscore js lib !")

class Ceylan

  properties: [
    'direction',  #  RTL support
    'boxSizing',
    'width',
    'height',
    'overflowX',
    'overflowY',  #  copy the scrollbar for IE

    'borderTopWidth',
    'borderRightWidth',
    'borderBottomWidth',
    'borderLeftWidth',

    'paddingTop',
    'paddingRight',
    'paddingBottom',
    'paddingLeft',

    #  https:# developer.mozilla.org/en-US/docs/Web/CSS/font
    'fontStyle',
    'fontVariant',
    'fontWeight',
    'fontStretch',
    'fontSize',
    'fontSizeAdjust',
    'lineHeight',
    'fontFamily',

    'textAlign',
    'textTransform',
    'textIndent',
    'textDecoration',  #  might not make a difference, but better be safe

    'letterSpacing',
    'wordSpacing'
  ]
#
#  template: _.template("
#      <div class='ceylan-dropdown'>
#      </div>
#    ")

  constructor: (element) ->
    @el = element

  _coordinates: (element, position) ->
    isFirefox = !(window.mozInnerScreenX == null)

    #  mirrored div
    div = document.createElement('div')
    div.id = 'input-textarea-caret-position-mirror-div'
    document.body.appendChild(div)
    style = div.style

    #  currentStyle for IE < 9
    if window.getComputedStyle
      computed = getComputedStyle(element)
    else
      computed = element.currentStyle

    #  default textarea styles
    style.whiteSpace = 'pre-wrap'
    if element.nodeName != 'INPUT'
      style.wordWrap = 'break-word'  #  only for textarea-s

    #  position off-screen
    style.position = 'absolute'  #  required to return coordinates properly
    style.visibility = 'hidden'  #  not 'display: none' because we want render

    for prop in @properties
      style[prop] = computed[prop]

    if isFirefox
      #  Firefox adds 2 pixels to the padding -
      # https:# bugzilla.mozilla.org/show_bug.cgi?id=753662
      style.width = parseInt(computed.width) - 2 + 'px'
      #  Firefox lies about the overflow property for textareas:
      # https:# bugzilla.mozilla.org/show_bug.cgi?id=984275
      if element.scrollHeight > parseInt(computed.height)
        style.overflowY = 'scroll'
      else
        style.overflow = 'hidden' #  for Chrome to not render a scrollbar;
        # IE keeps overflowY = 'scroll'

    div.textContent = element.value.substring(0, position)
    #  the second special handling for input type="text" vs textarea:
    #  spaces need to be replaced with non-breaking spaces -
    #  http:# stackoverflow.com/a/13402035/1269037
    if element.nodeName == 'INPUT'
      div.textContent = div.textContent.replace(/\s/g, "\u00a0")

    span = document.createElement('span')

    #  Wrapping must be replicated *exactly*, including when a long word gets
    #  onto the next line, with whitespace at the end of the line before (#7).
    #  The  *only* reliable way to do that is to copy the *entire* rest of the
    #  textarea's content into the <span> created at the caret position.
    #  for inputs, just '.' would be enough, but why bother?

    #  || because a completely empty faux span doesn't render at all
    span.textContent = element.value.substring(position) or '.'
    div.appendChild(span)

    coordinates = {
      top: span.offsetTop + parseInt(computed['borderTopWidth']),
      left: span.offsetLeft + parseInt(computed['borderLeftWidth'])
    }

    document.body.removeChild(div)

    coordinates

  _showCaret: ->
    self = @
    for selector in ['input[type="text"]', 'textarea']
      el = document.querySelector(selector)
      console.log(el)
      if el
        fontSize = getComputedStyle(el).getPropertyValue('font-size')

        rect = document.createElement('div')
        document.body.appendChild(rect)
        rect.style.position = 'absolute'
        rect.style.backgroundColor = 'red'
        rect.style.height = fontSize
        rect.style.width = '1px'

        for event in ['keyup', 'click', 'scroll']
          el.addEventListener(event, () ->
            co = self._coordinates(el, el.selectionEnd)
            console.log('(top, left) = (%s, %s)', co.top, co.left)
            rect.style.top = el.offsetTop - el.scrollTop + co.top + 'px'

            rect.style.left = el.offsetLeft - el.scrollLeft + co.left + 'px'
          )

  window.Ceylan = Ceylan