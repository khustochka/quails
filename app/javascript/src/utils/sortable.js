// Lightweight sortable lists using native HTML drag-and-drop.
//
// Usage:
//   new Sortable(listElement, {
//     connectWith: otherListElement,  — allow dragging between lists (optional, element or array)
//     placeholderClass: "drag-placeholder", — CSS class for the drop placeholder (default)
//     draggingClass: "dragging",      — CSS class added to the item being dragged (default)
//     onUpdate: function(list) {}     — called after a drop changes the list contents
//   })

export default class Sortable {
  constructor(list, options) {
    this.list = list;
    this.options = Object.assign({
      placeholderClass: "drag-placeholder",
      draggingClass: "dragging"
    }, options);

    this.placeholder = document.createElement("li");
    this.placeholder.className = this.options.placeholderClass;
    this.dragItem = null;

    this._allLists = [this.list].concat(this._resolveConnected());
    this._makeItemsDraggable();
    this._bindEvents();
  }

  _resolveConnected() {
    var c = this.options.connectWith;
    if (!c) return [];
    return Array.isArray(c) ? c : [c];
  }

  _makeItemsDraggable() {
    var self = this;
    this._allLists.forEach(function(list) {
      Array.from(list.children).forEach(function(li) {
        li.draggable = true;
      });
    });
  }

  _bindEvents() {
    var self = this;

    this._allLists.forEach(function(list) {
      list.addEventListener("dragover", function(e) {
        e.preventDefault();
        var target = e.target.closest("li");
        if (target && target !== self.dragItem && target !== self.placeholder) {
          var rect = target.getBoundingClientRect();
          var after = e.clientY > rect.top + rect.height / 2;
          target.parentNode.insertBefore(self.placeholder, after ? target.nextSibling : target);
        } else if (!list.contains(self.placeholder) && list.querySelectorAll("li:not(."+self.options.placeholderClass+")").length === 0) {
          list.appendChild(self.placeholder);
        }
      });

      list.addEventListener("drop", function(e) {
        e.preventDefault();
        if (self.dragItem && self.placeholder.parentNode) {
          self.placeholder.parentNode.insertBefore(self.dragItem, self.placeholder);
          self.placeholder.remove();
          self._fireUpdate();
        }
      });
    });

    this._onDragStart = function(e) {
      var li = e.target.closest("li");
      if (!li || !self._ownsItem(li)) return;
      self.dragItem = li;
      li.classList.add(self.options.draggingClass);
      e.dataTransfer.effectAllowed = "move";
    };

    this._onDragEnd = function() {
      if (self.dragItem) self.dragItem.classList.remove(self.options.draggingClass);
      if (self.placeholder.parentNode) self.placeholder.remove();
      self.dragItem = null;
    };

    document.addEventListener("dragstart", this._onDragStart);
    document.addEventListener("dragend", this._onDragEnd);
  }

  _ownsItem(li) {
    for (var i = 0; i < this._allLists.length; i++) {
      if (this._allLists[i].contains(li)) return true;
    }
    return false;
  }

  _fireUpdate() {
    if (typeof this.options.onUpdate === "function") {
      this.options.onUpdate(this.list);
    }
  }
}
