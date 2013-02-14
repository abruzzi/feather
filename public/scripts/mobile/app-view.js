var feather = feather || {};

$(function(){
    feather.AppView = Backbone.View.extend({
        el: '#notes-list',
        
        initialize: function() {
            this.listenTo(feather.Notes, 'add', this.addOne);
            this.listenTo(feather.Notes, 'reset', this.addAll);
            this.listenTo(feather.Notes, 'all', this.render);

            feather.Notes.fetch();            
        },

        addOne: function(note) {
            var view = new feather.NoteView({model: note});
            $('#notes-list').append(view.render().el);
            $('#notes-list').listview('refresh');
        },

        addAll: function() {
            $('#notes-list').html('');
            feather.Notes.each(this.addOne, this);
        }
    });
});

