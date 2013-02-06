Feather.NotesView = Backbone.View.extend({
    className: 'notes-container',

    initialize: function() {
        this.renderForm(); 
        this.render();
        this.collection.on("add", this.render, this);
    },

    renderForm: function() {
        var form = new Feather.FormView({
            model: this.collection
        });
        this.$el.append(form.render().el); 
    },

    render: function() {
        this.$el.find('.note').remove();
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
