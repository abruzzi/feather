var Feather = Feather || {};
Feather.Note = Backbone.Model.extend({
    defaults: {
        content: 'Something need to be noted here',
        complete: false
    },
    validate: function(attrs) {
        if(attrs.content.length === 0) {
            return "content can not be empty"
        }
    }
});
