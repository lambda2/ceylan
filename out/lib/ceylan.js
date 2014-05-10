
/*

ceylan
https://github.com/lambda2/ceylan

Copyright (c) 2014 André Aubin
Licensed under the MIT license.
 */

(function() {
  'use strict';
  var Ceylan;

  Ceylan = (function() {
    Ceylan.prototype.properties = ['direction', 'boxSizing', 'width', 'height', 'overflowX', 'overflowY', 'borderTopWidth', 'borderRightWidth', 'borderBottomWidth', 'borderLeftWidth', 'paddingTop', 'paddingRight', 'paddingBottom', 'paddingLeft', 'fontStyle', 'fontVariant', 'fontWeight', 'fontStretch', 'fontSize', 'fontSizeAdjust', 'lineHeight', 'fontFamily', 'textAlign', 'textTransform', 'textIndent', 'textDecoration', 'letterSpacing', 'wordSpacing'];

    Ceylan.prototype.binds = [
      {
        char: '@',
        data: [
          {
            label: "lambda2",
            content: "mama mia"
          }, {
            label: "noel",
            content: "noel mia"
          }, {
            label: "moustaki",
            content: "moustaki mia"
          }
        ]
      }
    ];

    function Ceylan(element) {
      this.el = document.querySelector(element);
      console.log(this._getValue(this.el));
      if (this.el) {
        this._trackCaret((function(_this) {
          return function(char, rect, event, self) {
            var bind, k, toadd, _fn, _i, _j, _len, _len1, _ref, _ref1, _results;
            k = event.keyCode;
            console.log("Key pressed : [" + char + "] " + k + " => " + (String.fromCharCode(k)));
            _ref = _this.binds;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              bind = _ref[_i];
              if (bind.char === char) {
                rect.innerHTML = "";
                console.log("Match => " + char);
                _ref1 = bind.data;
                _fn = function(toadd) {
                  var item;
                  item = document.createElement('div');
                  item.innerHTML = toadd.label;
                  item.onclick = (function(_this) {
                    return function(e) {
                      var old;
                      console.log("click");
                      old = self._getValue(self.el);
                      self._setValue(self.el, old.substr(0, self.el.selectionEnd) + toadd.content + old.substr(self.el.selectionEnd));
                      return rect.innerHTML = "";
                    };
                  })(this);
                  console.log("To be added: ", item);
                  return rect.appendChild(item);
                };
                for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                  toadd = _ref1[_j];
                  _fn(toadd);
                }
              } else {
                rect.innerHTML = "";
              }
              _results.push(console.log(bind));
            }
            return _results;
          };
        })(this));
      }
    }

    Ceylan.prototype._coordinatesForTextarea = function(element, position) {
      var computed, coordinates, div, isFirefox, prop, span, style, _i, _len, _ref;
      isFirefox = !(window.mozInnerScreenX === null);
      div = document.createElement('div');
      div.id = 'input-textarea-caret-position-mirror-div';
      document.body.appendChild(div);
      style = div.style;
      if (window.getComputedStyle) {
        computed = getComputedStyle(element);
      } else {
        computed = element.currentStyle;
      }
      style.whiteSpace = 'pre-wrap';
      if (element.nodeName !== 'INPUT') {
        style.wordWrap = 'break-word';
      }
      style.position = 'absolute';
      style.visibility = 'hidden';
      _ref = this.properties;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        prop = _ref[_i];
        style[prop] = computed[prop];
      }
      if (isFirefox) {
        style.width = parseInt(computed.width) - 2 + 'px';
        if (element.scrollHeight > parseInt(computed.height)) {
          style.overflowY = 'scroll';
        } else {
          style.overflow = 'hidden';
        }
      }
      div.textContent = this._getValue(element).substring(0, position);
      if (element.nodeName === 'INPUT') {
        div.textContent = div.textContent.replace(/\s/g, "\u00a0");
      }
      span = document.createElement('span');
      span.textContent = this._getValue(element).substring(position) || '.';
      div.appendChild(span);
      coordinates = {
        top: span.offsetTop + parseInt(computed['borderTopWidth']),
        left: span.offsetLeft + parseInt(computed['borderLeftWidth'])
      };
      document.body.removeChild(div);
      return coordinates;
    };

    Ceylan.prototype._getCaretPositionForDiv = function(item) {
      var caretPos, range, sel, tempEl, tempRange;
      caretPos = 0;
      if (window.getSelection) {
        sel = window.getSelection();
        if (sel.rangeCount) {
          range = sel.getRangeAt(0);
          if (range.commonAncestorContainer.parentNode === item) {
            caretPos = range.endOffset;
          } else {
            console.log("Parent node = ", range.commonAncestorContainer.parentNode, item);
          }
        }
      } else if (document.selection && document.selection.createRange) {
        range = document.selection.createRange();
        if (range.parentElement() === item) {
          tempEl = document.createElement("span");
          item.insertBefore(tempEl, item.firstChild);
          tempRange = range.duplicate();
          tempRange.moveToElementText(tempEl);
          tempRange.setEndPoint("EndToEnd", range);
          caretPos = tempRange.text.length;
        }
      }
      return caretPos;
    };

    Ceylan.prototype._coordinatesForDiv = function(item) {
      var char, coords, ghost, height, offset, our_spy, span, width, x, y;
      offset = this._getCaretPositionForDiv(item);
      item = $(item);
      ghost = item.clone();
      char = ghost.text().substr(offset - 1, 1);
      our_spy = "<span id='ceylan-spy'>" + char + "</span>";
      ghost.html(ghost.text().substr(0, offset - 1) + our_spy + ghost.text().substr(offset));
      x = item.offset().left;
      y = item.offset().top;
      width = item.outerWidth() - 22;
      height = item.outerHeight() - 22;
      ghost.css({
        'position': 'absolute',
        'top': y,
        'left': x,
        'width': width,
        'height': height,
        'opacity': 0,
        'z-index': -100
      });
      item.before(ghost);
      span = ghost.find("#ceylan-spy");
      offset = span.offset();
      console.log("span => ", span);
      if (span.length > 0) {
        coords = {
          left: offset.left - item.scrollLeft(),
          top: offset.top - item.scrollTop()
        };
        console.log(coords);
      }
      ghost.remove();
      return coords;
    };

    Ceylan.prototype._type = function(item) {
      var _ref;
      if ((_ref = item.tagName) === "TEXTAREA" || _ref === "INPUT") {
        return "TEXT";
      } else if (item.contentEditable) {
        return "DIV";
      } else {
        return "UNDEFINED";
      }
    };

    Ceylan.prototype._getValue = function(item) {
      if (this._type(item) === "TEXT") {
        console.log("C'est un textarea");
        return item.value;
      } else if (this._type(item) === "DIV") {
        console.log("C'est une div editable");
        return item.innerHTML;
      } else {
        return null;
      }
    };

    Ceylan.prototype._setValue = function(item, value) {
      if (this._type(item) === "TEXT") {
        item.value = value;
      } else if (this._type(item) === "DIV") {
        item.innerHTML = value;
      }
      return this._getValue(item);
    };

    Ceylan.prototype._trackCaret = function(callback) {
      var event, fontSize, self, _i, _len, _ref;
      self = this;
      console.log(self.el);
      if (self.el) {
        fontSize = getComputedStyle(self.el).getPropertyValue('font-size');
        self.rect = document.createElement('div');
        document.body.appendChild(self.rect);
        self.rect.style.position = 'absolute';
        self.rect.id = "ceylan-dropdown";
        _ref = ['keyup', 'click', 'scroll'];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          event = _ref[_i];
          self.el.addEventListener(event, function() {
            var co;
            console.log(window.getSelection());
            if (self._type(self.el) === "TEXT") {
              co = self._coordinatesForTextarea(self.el, self.el.selectionEnd);
              console.log('(top, left) = (%s, %s)', co.top, co.left);
              self.rect.style.top = self.el.offsetTop - self.el.scrollTop + co.top + 'px';
              return self.rect.style.left = self.el.offsetLeft - self.el.scrollLeft + co.left + 'px';
            } else if (self._type(self.el) === "DIV") {
              co = self._coordinatesForDiv(self.el);
              $(self.rect).css({
                'top': co.top,
                'left': co.left
              });
              return console.log("position set !", co, self.rect);
            }
          });
        }
        return self.el.addEventListener('keyup', function(event) {
          var lastchar, p;
          if (self._type(self.el) === "TEXT") {
            p = self.el.selectionEnd;
          } else if (self._type(self.el) === "DIV") {
            p = window.getSelection().baseOffset;
          }
          lastchar = self._getValue(self.el).substring(p - 1, p);
          return callback(lastchar, self.rect, event, self);
        });
      }
    };

    window.Ceylan = Ceylan;

    return Ceylan;

  })();

}).call(this);
