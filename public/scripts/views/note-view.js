Feather.NoteView = Backbone.View.extend({
    className: 'note',

    events: {
        'click .delete': 'deleteNote'
    },

    render: function() {
        var func = haml.compileHaml({
            sourceUrl: 'templates/note.haml'
        });
        var html = func({model: this.model});
        this.$el.html(html);

        return this;
    },

    deleteNote: function(event){
        this.model.destroy();
        this.remove();
    }
})
