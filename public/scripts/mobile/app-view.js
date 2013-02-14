var feather = feather || {};

$(function(){
    feather.AppView = Backbone.View.extend({
        el: '#notes-list',
        
        initialize: function() {
            this.$main = this.$('#notes-list-view');

            this.listenTo(feather.Notes, 'add', this.addOne);
            this.listenTo(feather.Notes, 'reset', this.addAll);
            this.listenTo(feather.Notes, 'all', this.render);

            feather.Notes.fetch();            
        },

        render: function() {
            if(feather.Notes.length) {
                this.$main.show();
            } else {
                this.$main.hide();
            }

            var func = haml.compileHaml({
                sourceUrl: 'templates/feather.mobile.haml'
            });

            var html = func({model: this.model});
            this.$el.html(html);

            return this;
        },

        addOne: function(note) {
            var view = new feather.NoteView({model: note});
            $('#note-list').append(view.render().el);
        },

        addAll: function() {
            $('#note-list').html('');
            feather.Notes.each(this.addOne, this);
        }

    });
});

