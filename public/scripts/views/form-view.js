Feather.FormView = Backbone.View.extend({
    events: {
        'click .save': 'saveNote'
    },

    render: function(){
        var func = haml.compileHaml({
            sourceUrl: 'templates/form.haml'
        });

        this.$el.html(func());
    
        return this;
    },

    gatherNoteInfo: function(){
        var content = $('#content', this.el).val().trim();

        return {
            content: content
        };
    },

    saveNote: function(event){
        var contact = this.gatherNoteInfo(); 
        this.model.add(contact); 
    }
});
