$(document).ready(function(){
    function render_notes(){
        var container = $("#notes-container");
        $.ajax({
            url: '/notes.json',
            type: 'GET',
            success: function(notes){

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

                container.html('').append(ul);
            },
            error: function(error){
                container.html(error); 
            }
        })
    }

    $('#submit').click(function(){
        alert('clicked');
        var content = $("#note").val();
        $.ajax({
            url: '/notes',
            type: 'POST',
            data: {'content': content},
            success: function(data){
                render_notes(); 
            },
            error: function(error){
            
            }
        })
    }); 
});
