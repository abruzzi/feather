$(document).ready(function(){
    $('#login-dialog').dialog({
        autoOpen: false,
        height: 300,
        width: 400,
        modal: true
    });

    $('#signup-dialog').dialog({
        autoOpen: false,
        height: 350,
        width: 400,
        modal: true,
    });

    $('a#login').click(function(){
        $('#login-dialog').dialog('open');
    });

    $('a#signup').click(function(){
        $('#signup-dialog').dialog('open');
    });
});
