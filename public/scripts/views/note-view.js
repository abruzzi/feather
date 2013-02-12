var feather = feather || {};

$(function(){
    feather.NoteView = Backbone.View.extend({
        className: 'note',

        tagName: 'li',

        events: {
            'click .toggle': 'toggleCompleted',
            'dblclick label': 'edit',
            'keypress .edit': 'updateOnEnter',
            'blur .edit': 'close',
            'click .destroy': 'clear'
        },

        initialize: function() {
            this.listenTo(this.model, 'change', this.render);   
            this.listenTo(this.model, 'destroy', this.remove);   
            this.listenTo(this.model, 'visible', this.toggleVisible);   
        },

        render: function() {
            var func = haml.compileHaml({
                sourceUrl: 'templates/note.haml'
            });

            var html = func({model: this.model});
            this.$el.html(html);
            this.$el.toggleClass('completed', this.model.get('complete'));

            this.$input = this.$('.edit');

            return this;
        },

        toggleCompleted: function() {
            this.model.toggle();
        },

        edit: function() {
            this.$el.addClass('editing');
            this.$input.focus();
        },

        close: function() {
            var val = this.$input.val().trim();
            if(val) {
                this.model.save({content: val});   
            } else {
                this.clear();
            }

            this.$el.removeClass('editing');
        },

        updateOnEnter: function(event) {
            if(event.which === ENTRN_KEY) {
                this.close();
            }
        },

        clear: function() {
            this.model.destroy();
        },

        deleteNote: function(event){
            this.model.destroy();
            this.remove();
        }
    });
});
