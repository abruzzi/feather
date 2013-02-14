var feather = feather || {};

(function(){
    feather.NoteEditView = Backbone.View.extend({
        el: '#note-edit',

        render: function() {
            var func = haml.compileHaml({
                sourceUrl: 'templates/note-edit.mobile.haml'
            });

            var html = func({model: this.model});
            this.$el.html(html);

            return this;
        }
    });
})();
