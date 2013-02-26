var feather = feather || {};

(function(){
    var Notes = Backbone.Collection.extend({
        model: feather.Note,

        url: 'notes',
        
        completed: function() {
            return this.filter(function(note){
                return note.get('complete');
            });
        },

        remaining: function() {
            return this.without.apply(this, this.completed()); 
        },

        comparator: function(note) {
            return -new Date(note.get('updated_at')).getTime();
        }
    });

    feather.Notes = new Notes();
}());
