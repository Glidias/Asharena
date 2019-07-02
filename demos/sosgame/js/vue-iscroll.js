!function(e,t){"object"==typeof exports&&"object"==typeof module?module.exports=t():"function"==typeof define&&define.amd?define([],t):"object"==typeof exports?exports.VueDragScroll=t():e.VueDragScroll=t()}("undefined"!=typeof self?self:this,function(){return function(e){function t(n){if(o[n])return o[n].exports;var r=o[n]={i:n,l:!1,exports:{}};return e[n].call(r.exports,r,r.exports,t),r.l=!0,r.exports}var o={};return t.m=e,t.c=o,t.d=function(e,o,n){t.o(e,o)||Object.defineProperty(e,o,{configurable:!1,enumerable:!0,get:n})},t.n=function(e){var o=e&&e.__esModule?function(){return e.default}:function(){return e};return t.d(o,"a",o),o},t.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)},t.p="/dist/",t(t.s=0)}([function(e,t,o){"use strict";Object.defineProperty(t,"__esModule",{value:!0}),t.dragscroll=void 0;var n=o(1),r=function(e){return e&&e.__esModule?e:{default:e}}(n),i={install:function(e,t){var o=Number(e.version.split(".")[0]),n=Number(e.version.split(".")[1]);if(o<2&&n<1)throw new Error("v-dragscroll supports vue version 2.1 and above. You are using Vue@"+e.version+". Please upgrade to the latest version of Vue.");e.directive("dragscroll",r.default)}};"undefined"!=typeof window&&window.Vue&&(window.VueDragscroll=i,window.Vue.use(i)),t.dragscroll=r.default,t.default=i},function(e,t,o){"use strict";Object.defineProperty(t,"__esModule",{value:!0});var n="function"==typeof Symbol&&"symbol"==typeof Symbol.iterator?function(e){return typeof e}:function(e){return e&&"function"==typeof Symbol&&e.constructor===Symbol&&e!==Symbol.prototype?"symbol":typeof e},r=o(2),i=function(e){return e&&e.__esModule?e:{default:e}}(r),l=["mousedown","touchstart"],d=["mousemove","touchmove"],s=["mouseup","touchend"],u=function(e,t,o){var r=e,u=!0;"boolean"==typeof t.value?u=t.value:"object"===n(t.value)?("string"==typeof t.value.target?(r=e.querySelector(t.value.target))||console.error("There is no element with the current target value."):void 0!==t.value.target&&console.error("The parameter \"target\" should be be either 'undefined' or 'string'."),"boolean"==typeof t.value.active?u=t.value.active:void 0!==t.value.active&&console.error("The parameter \"active\" value should be either 'undefined', 'true' or 'false'.")):void 0!==t.value&&console.error("The passed value should be either 'undefined', 'true' or 'false' or 'object'.");var a=function(){var e=void 0,n=void 0,u=void 0,a=!1,c=!1;r.md=function(o){o.preventDefault();var i=o instanceof window.MouseEvent,l=i?o.pageX:o.touches[0].pageX,d=i?o.pageY:o.touches[0].pageY,s=document.elementFromPoint(l-window.pageXOffset,d-window.pageYOffset),a="nochilddrag"===t.arg,f=t.modifiers.noleft,v=t.modifiers.noright,m=t.modifiers.nomiddle,p=t.modifiers.noback,w=t.modifiers.noforward,h="firstchilddrag"===t.arg,y=s===r,g=s===r.firstChild,b=a?void 0!==s.dataset.dragscroll:void 0===s.dataset.noDragscroll;(y||b&&(!h||g))&&(1===o.which&&f||2===o.which&&m||3===o.which&&v||4===o.which&&p||5===o.which&&w||(u=1,e=i?o.clientX:o.touches[0].clientX,n=i?o.clientY:o.touches[0].clientY,"touchstart"===o.type&&(c=!0)))},r.mu=function(e){u=0,a&&i.default.emitEvent(o,"dragscrollend"),a=!1,"touchend"===e.type&&!0===c?(e.target.click(),c=!1):e.target.focus()},r.mm=function(l){var d=l instanceof window.MouseEvent,s=void 0,c=void 0,f={};if(u){a||i.default.emitEvent(o,"dragscrollstart"),a=!0;var v=r.scrollLeft+r.clientWidth>=r.scrollWidth||0===r.scrollLeft,m=r.scrollTop+r.clientHeight>=r.scrollHeight||0===r.scrollTop;s=-e+(e=d?l.clientX:l.touches[0].clientX),c=-n+(n=d?l.clientY:l.touches[0].clientY),t.modifiers.pass?(r.scrollLeft-=t.modifiers.y?-0:s,r.scrollTop-=t.modifiers.x?-0:c,r===document.body&&(r.scrollLeft-=t.modifiers.y?-0:s,r.scrollTop-=t.modifiers.x?-0:c),(v||t.modifiers.y)&&window.scrollBy(-s,0),(m||t.modifiers.x)&&window.scrollBy(0,-c)):(t.modifiers.x&&(c=-0),t.modifiers.y&&(s=-0),r.scrollLeft-=s,r.scrollTop-=c,r===document.body&&(r.scrollLeft-=s,r.scrollTop-=c)),f.deltaX=-s,f.deltaY=-c,i.default.emitEvent(o,"dragscrollmove",f)}},i.default.addEventListeners(r,l,r.md),i.default.addEventListeners(window,s,r.mu),i.default.addEventListeners(window,d,r.mm)};u?"complete"===document.readyState?a():window.addEventListener("load",a):(i.default.removeEventListeners(r,l,r.md),i.default.removeEventListeners(window,s,r.mu),i.default.removeEventListeners(window,d,r.mm))};t.default={bind:function(e,t,o){u(e,t,o)},update:function(e,t,o,n){JSON.stringify(t.value)!==JSON.stringify(t.oldValue)&&u(e,t,o)},unbind:function(e,t,o){var n=e;i.default.removeEventListeners(n,l,n.md),i.default.removeEventListeners(window,s,n.mu),i.default.removeEventListeners(window,d,n.mm)}}},function(e,t,o){"use strict";Object.defineProperty(t,"__esModule",{value:!0}),t.default={addEventListeners:function(e,t,o){for(var n=0,r=t.length;n<r;n++)e.addEventListener(t[n],o)},removeEventListeners:function(e,t,o){for(var n=0,r=t.length;n<r;n++)e.removeEventListener(t[n],o)},emitEvent:function(e,t,o){if(e.componentInstance)e.componentInstance.$emit(t,o);else{var n=void 0;"function"==typeof window.CustomEvent?n=new window.CustomEvent(t,{detail:o}):(n=document.createEvent("CustomEvent"),n.initCustomEvent(t,!0,!0,o)),e.elm.dispatchEvent(n)}}}}])});
//# sourceMappingURL=vue-dragscroll.min.js.map