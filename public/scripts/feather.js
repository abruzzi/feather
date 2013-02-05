$(document).ready(function(){
    var container = $("#content");
    var notes = new Feather.Notes();
    
    var view = new Feather.NotesView({
        collection: notes
    });

    container.append(view.el);
});
