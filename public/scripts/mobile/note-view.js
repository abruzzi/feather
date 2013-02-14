var feather = feather || {};

(function(){
    feather.NoteView = Backbone.View.extend({
        el: '.standard-note',

        render: function() {
            var func = haml.compileHaml({
                sourceUrl: 'templates/note.mobile.haml'
            });

            var html = func({model: this.model});
            this.$el.html(html);

            return this;
        }
    });    
})();

