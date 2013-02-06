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

    // var user_info = $("#userinfo");
    // user_info.append(new Feather.UserInfoView({
    //     model: {
    //         name: 'juntao',
    //         email: 'jtqiu@thoughtworks.com'
    //     } 
    // }).el);
});
