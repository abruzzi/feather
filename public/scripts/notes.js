$(document).ready(function(){
    function render_notes(notes){
        var container = $("#notes-container");

        var ul = $("<ul></ul>").attr({
            "data-role": "listview",
            "data-inset": "true"
        });

        for(var p in notes){
            var note = notes[p];
            var li = $("<li></li>").addClass('ui-btn');
            var content = $("<h3></h3>").text(note.content);
            var timestamp = $("<p></p>").text('created at: '+note.created_at);
            content.appendTo(li);
            timestamp.appendTo(li);
            li.appendTo(ul);
        }

        container.remove().append(ul);
    }

    $('#submit').click(function(){
        var content = $("#note").val();
        $.ajax({
            url: '/notes',
            type: 'POST',
            data: content,
            success: function(data){
                render_notes(data); 
            },
            error: function(error){
            
            }
        })
    }); 
});
