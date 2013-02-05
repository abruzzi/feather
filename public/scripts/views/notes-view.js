Feather.NotesView = Backbone.View.extend({
    initialize: function() {
    
    },

    renderForm: function() {
    
    },

    render: function() {
        this.collection.each(function(item){
            this.renderNote(item);
        }, this);

        return this;
    },

    renderNote: function(item) {
        var note = new Feather.NoteView({
            model: item
        });

        this.$el.append(note.render().el);
    }
});
