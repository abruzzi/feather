var feather = feather || {};

$(function(){
    feather.AppView = Backbone.View.extend({
        el: '#notes',

        events: {
            'keypress #new-note': 'createOnEnter'
        },

        initialize: function() {
            this.$input = this.$('#new-note');
            this.$main = this.$('#main');

            this.listenTo(feather.Notes, 'add', this.addOne);
            this.listenTo(feather.Notes, 'reset', this.addAll);
            this.listenTo(feather.Notes, 'all', this.render);

            feather.Notes.fetch();
        },

        renderIndicator: function() {
            var indicator = this.$('#indicator');
            indicator.empty();

            var completed = feather.Notes.completed().length;
            var remaining = feather.Notes.remaining().length;

            var comp = $('<span>')
                .addClass('badge badge-success')
                .text('completed: ' + completed);

            var rema = $('<span>')
                .addClass('badge badge-warning')
                .text('remaining: ' + remaining);

            comp.appendTo(indicator);
            rema.appendTo(indicator);

            if (feather.Notes.length) {
                indicator.show();
            } else {
                indicator.hide();
            }

        },

        render: function() {
            this.renderIndicator();

            if (feather.Notes.length) {
                this.$main.show();
            } else {
                this.$main.hide();
            }
        },

        addOne: function(note) {
            var view = new feather.NoteView({model: note});
            $('#note-list').append(view.render().el);
        },

        addAll: function() {
            $('#note-list').html('');
            feather.Notes.each(this.addOne, this);
        },

        collectAttributes: function() {
            return {
                content: this.$input.val().trim(),
                complete: false
            };
        },

        createOnEnter: function(event) {
            if(event.which !== ENTRN_KEY || !this.$input.val().trim() ) {
                return;
            }

            feather.Notes.create(this.collectAttributes());
            this.$input.val('');
        }
    });    
});
