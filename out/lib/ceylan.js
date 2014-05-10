
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

    function Ceylan(element) {
      this.el = element;
    }

    Ceylan.prototype._coordinates = function(element, position) {
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
      div.textContent = element.value.substring(0, position);
      if (element.nodeName === 'INPUT') {
        div.textContent = div.textContent.replace(/\s/g, "\u00a0");
      }
      span = document.createElement('span');
      span.textContent = element.value.substring(position) || '.';
      div.appendChild(span);
      coordinates = {
        top: span.offsetTop + parseInt(computed['borderTopWidth']),
        left: span.offsetLeft + parseInt(computed['borderLeftWidth'])
      };
      document.body.removeChild(div);
      return coordinates;
    };

    Ceylan.prototype._showCaret = function() {
      var el, event, fontSize, rect, selector, self, _i, _len, _ref, _results;
      self = this;
      _ref = ['input[type="text"]', 'textarea'];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        selector = _ref[_i];
        el = document.querySelector(selector);
        console.log(el);
        if (el) {
          fontSize = getComputedStyle(el).getPropertyValue('font-size');
          rect = document.createElement('div');
          document.body.appendChild(rect);
          rect.style.position = 'absolute';
          rect.style.backgroundColor = 'red';
          rect.style.height = fontSize;
          rect.style.width = '1px';
          _results.push((function() {
            var _j, _len1, _ref1, _results1;
            _ref1 = ['keyup', 'click', 'scroll'];
            _results1 = [];
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              event = _ref1[_j];
              _results1.push(el.addEventListener(event, function() {
                var co;
                co = self._coordinates(el, el.selectionEnd);
                console.log('(top, left) = (%s, %s)', co.top, co.left);
                rect.style.top = el.offsetTop - el.scrollTop + co.top + 'px';
                return rect.style.left = el.offsetLeft - el.scrollLeft + co.left + 'px';
              }));
            }
            return _results1;
          })());
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    window.Ceylan = Ceylan;

    return Ceylan;

  })();

}).call(this);
