$(document).ready(function(){
    var container = $("#content");
    var notes = new Feather.Notes();
    
    notes.fetch({
        success: function(){
            container.append(new Feather.NotesView({
                collection: notes
            }).el);
        }
    });
});
