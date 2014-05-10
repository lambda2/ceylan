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

#  properties: [
#    'direction',  #  RTL support
#    'boxSizing',
#    'width',
#    'height',
#    'overflowX',
#    'overflowY',  #  copy the scrollbar for IE
#
#    'borderTopWidth',
#    'borderRightWidth',
#    'borderBottomWidth',
#    'borderLeftWidth',
#
#    'paddingTop',
#    'paddingRight',
#    'paddingBottom',
#    'paddingLeft',
#
#    #  https:# developer.mozilla.org/en-US/docs/Web/CSS/font
#    'fontStyle',
#    'fontVariant',
#    'fontWeight',
#    'fontStretch',
#    'fontSize',
#    'fontSizeAdjust',
#    'lineHeight',
#    'fontFamily',
#
#    'textAlign',
#    'textTransform',
#    'textIndent',
#    'textDecoration',  #  might not make a difference, but better be safe
#
#    'letterSpacing',
#    'wordSpacing'
#  ]

  binds:[
    {
      char: '@'
      data: [
        {
          label: "lambda2"
          content: "mama mia"
        },
        {
          label: "noel"
          content: "noel mia"
        },
        {
          label: "moustaki"
          content: "moustaki mia"
        }
      ]
    }
  ]
#
#  template: _.template("
#      <div class='ceylan-dropdown'>
#      </div>
#    ")

  constructor: (element) ->
    @el = document.querySelector(element)
    $(@el).after("<span class='cursor'></span>")
    console.log(@_getValue(@el))
    if @el
      @_trackCaret((char, rect, event, self) =>
        #console.log("callback !",event, rect, self)
        k = event.keyCode
        console.log("Key pressed : [#{char}] #{k} => #{String.fromCharCode(k)}")
        for bind in @binds
          if bind.char is char
            rect.innerHTML = ""
            console.log("Match => #{char}")
            for toadd in bind.data
              do (toadd) ->
                item = document.createElement('div')
                item.innerHTML = toadd.label
                item.onclick = (e) =>
                  console.log("click")
                  old = self._getValue(self.el)
                  self._setValue(self.el, old.substr(0, self.el.selectionEnd) + toadd.content + old.substr(self.el.selectionEnd))
                  rect.innerHTML = ""
                console.log("To be added: ", item)
                rect.appendChild(item)
          else
            rect.innerHTML = ""
          console.log(bind)
      )

#  _coordinatesForTextarea: (element, position) ->
#    isFirefox = !(window.mozInnerScreenX == null)
#
#    #  mirrored div
#    div = document.createElement('div')
#    div.id = 'input-textarea-caret-position-mirror-div'
#    document.body.appendChild(div)
#    style = div.style
#
#    #  currentStyle for IE < 9
#    if window.getComputedStyle
#      computed = getComputedStyle(element)
#    else
#      computed = element.currentStyle
#
#    #  default textarea styles
#    style.whiteSpace = 'pre-wrap'
#    if element.nodeName != 'INPUT'
#      style.wordWrap = 'break-word'  #  only for textarea-s
#
#    #  position off-screen
#    style.position = 'absolute'  #  required to return coordinates properly
#    style.visibility = 'hidden'  #  not 'display: none' because we want render
#
#    for prop in @properties
#      style[prop] = computed[prop]
#
#    if isFirefox
#      #  Firefox adds 2 pixels to the padding -
#      # https:# bugzilla.mozilla.org/show_bug.cgi?id=753662
#      style.width = parseInt(computed.width) - 2 + 'px'
#      #  Firefox lies about the overflow property for textareas:
#      # https:# bugzilla.mozilla.org/show_bug.cgi?id=984275
#      if element.scrollHeight > parseInt(computed.height)
#        style.overflowY = 'scroll'
#      else
#        style.overflow = 'hidden' #  for Chrome to not render a scrollbar;
#        # IE keeps overflowY = 'scroll'
#
#    div.textContent = @_getValue(element).substring(0, position)
#    #  the second special handling for input type="text" vs textarea:
#    #  spaces need to be replaced with non-breaking spaces -
#    #  http:# stackoverflow.com/a/13402035/1269037
#    if element.nodeName == 'INPUT'
#      div.textContent = div.textContent.replace(/\s/g, "\u00a0")
#
#    span = document.createElement('span')
#
#    #  Wrapping must be replicated *exactly*, including when a long word gets
#    #  onto the next line, with whitespace at the end of the line before (#7).
#    #  The  *only* reliable way to do that is to copy the *entire* rest of the
#    #  textarea's content into the <span> created at the caret position.
#    #  for inputs, just '.' would be enough, but why bother?
#
#    #  || because a completely empty faux span doesn't render at all
#    span.textContent = @_getValue(element).substring(position) or '.'
#    div.appendChild(span)
#
#    coordinates = {
#      top: span.offsetTop + parseInt(computed['borderTopWidth']),
#      left: span.offsetLeft + parseInt(computed['borderLeftWidth'])
#    }
#
#    document.body.removeChild(div)
#
#    coordinates

  _getCaretPositionForDiv: (item) ->
    caretPos = 0
    if window.getSelection
      sel = window.getSelection()
      if sel.rangeCount
        range = sel.getRangeAt(0)
        if range.commonAncestorContainer.parentNode == item
          caretPos = range.endOffset
        else
          console.log("Parent node = ", range.commonAncestorContainer.parentNode, item)
    else if document.selection and document.selection.createRange
      range = document.selection.createRange()
      if range.parentElement() == item
        tempEl = document.createElement("span")
        item.insertBefore(tempEl, item.firstChild)
        tempRange = range.duplicate()
        tempRange.moveToElementText(tempEl)
        tempRange.setEndPoint("EndToEnd", range)
        caretPos = tempRange.text.length
    caretPos

#
#              $('div.editor').bind('keyup click', function() {
#
#                  var offset = getCaretPosition(this),
#                  $org = $(this),
#                  $el = $org.clone(),
#                  char = $el.text().substr(offset-1, 1);
#
#                if (char == '@')
#                {
#                var html = '<span class="ins_str">' + char + '</span>';
#                $el.html($el.text().substr(0, offset - 1) + html + $el.text().substr(offset));
#
#                var x = $org.offset().left,
#                  y = $org.offset().top,
#                  width = $org.outerWidth() - 22,
#                  height = $org.outerHeight() - 22;
#
#                $el.css({
#                  'position': 'absolute',
#                  'top': y,
#                  'left': x,
#                  'width': width,
#                  'height': height,
#                  'opacity': 0
#                });
#                $org.before($el);
#
#                var $span = $el.find('span.ins_str');
#                if ($span.length > 0)
#                {
#                var offset = $span.offset(),
#                char_x = offset.left - $(this).scrollLeft(),
#                char_y = offset.top - $(this).scrollTop();
#
#                $('span.cursor').css({
#                  'left': char_x,
#                  'top': char_y
#                });
#              }
#
#              console.log($span.offset(), $span.position());
#
#              $el.remove();
#              }
#              else
#              {
#              // Use a regex to see if we are in the context of a valid username beginning with @, if not reset the caret
#              }
#          }).bind('scroll', function() {
#
#          $('span.cursor').css({
#            'left': 0,
#            'top': 0
#          });
#          });
#

  _coordinatesForDiv: (item) ->
    offset = @_getCaretPositionForDiv(item)
    item = $(item)
    ghost = item.clone()
    char = ghost.text().substr(offset - 1, 1)
    our_spy = "<span id='ceylan-spy'>#{char}</span>"
    ghost.html(ghost.text().substr(0, offset - 1) + our_spy + ghost.text().substr(offset))
    x = item.offset().left
    y = item.offset().top
    width = item.outerWidth() - 22
    height = item.outerHeight() - 22    # 22 ? Wat ?

    #    ghost.style.position = 'absolute'
    #    ghost.style.top = y + 'px'
    #    ghost.style.left = x + 'px'
    #    ghost.style.width = width + 'px'
    #    ghost.style.height = height + 'px'
    #    ghost.style.opacity = 0
    ghost.css({
      'position': 'absolute',
      'top': y,
      'left': x,
      'width': width,
      'height': height,
      'opacity': 0,
      'z-index': -100
    })


    #    parentDiv = item.parentNode
    #    parentDiv.insertBefore(ghost, item)
    item.before(ghost)

    span = ghost.find("#ceylan-spy")
    offset = span.offset()
    console.log("span => ", span)
    if span.length > 0
      coords = {
        left: offset.left - item.scrollLeft()
        top: offset.top - item.scrollTop()
      }
      console.log(coords)

    char_x = offset.left - $(item).scrollLeft()
    char_y = offset.top - $(item).scrollTop()
    $('span.cursor').css({
      'left': char_x,
      'top': char_y
    });
    ghost.remove()
    coords

  _type: (item) ->
    if item.tagName in ["TEXTAREA", "INPUT"]
      return "TEXT"
    else if item.contentEditable
      return "DIV"
    else return "UNDEFINED"

  _getValue: (item) ->
    if @_type(item) is "TEXT"
      console.log("C'est un textarea")
      return item.value
    else if @_type(item) is "DIV"
      console.log("C'est une div editable")
      return item.innerHTML
    else
      return null

  _setValue: (item, value) ->
    if @_type(item) is "TEXT"
      item.value = value
    else if @_type(item) is "DIV"
      item.innerHTML = value
    return @_getValue(item)

  _trackCaret: (callback)->
    self = @
    console.log(self.el)
    if self.el
#      fontSize = getComputedStyle(self.el).getPropertyValue('font-size')

      self.rect = document.createElement('div')
      document.body.appendChild(self.rect)
      self.rect.style.position = 'absolute'
      self.rect.id = "ceylan-dropdown"

#      for event in ['keyup', 'click', 'scroll']
#        self.el.addEventListener(event, () ->
#          console.log(window.getSelection())
#          if self._type(self.el) is "TEXT"
#            co = self._coordinatesForTextarea(self.el, self.el.selectionEnd)
#            console.log('(top, left) = (%s, %s)', co.top, co.left)
#            self.rect.style.top = self.el.offsetTop - self.el.scrollTop + co.top + 'px'
#            self.rect.style.left = self.el.offsetLeft - self.el.scrollLeft + co.left + 'px'
#          else if self._type(self.el) is "DIV"
#            co = self._coordinatesForDiv(self.el)
#            $(self.rect).css({
#              'top': co.top,
#              'left': co.left
#            })
#            console.log("position set !", co, self.rect)
#        )
      self.el.addEventListener('keyup', (event) ->
        co = self._coordinatesForDiv(self.el)
        if self._type(self.el) is "TEXT"
          p = self.el.selectionEnd
        else if self._type(self.el) is "DIV"
          p = window.getSelection().baseOffset
        lastchar = self._getValue(self.el).substring(p - 1, p)
        callback(lastchar, self.rect, event, self)
      )

  window.Ceylan = Ceylan