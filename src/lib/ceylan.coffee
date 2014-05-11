###

ceylan
https://github.com/lambda2/ceylan

Copyright (c) 2014 André Aubin
Licensed under the MIT license.

###

'use strict'

class Ceylan

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

    ghost.css({
      'position': 'absolute',
      'top': y,
      'left': x,
      'width': width,
      'height': height,
      'opacity': 0,
      'z-index': -100
    })

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

      self.rect = document.createElement('div')
      document.body.appendChild(self.rect)
      self.rect.style.position = 'absolute'
      self.rect.id = "ceylan-dropdown"

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