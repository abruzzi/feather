Feather.NotesView = Backbone.View.extend({
    initialize: function() {
        this.renderForm(); 
        this.render();
    },

    renderForm: function() {
        var form = new Feather.FormView({
            model: this.collection
        });
        this.$el.append(form.render().el); 
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
