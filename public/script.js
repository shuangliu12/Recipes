$(document).ready(function(){
    $('form').focus(function(){
        $(this).css('outline-color','#FF0000')
    });
});

$(document).ready(function() {
    $("#menu").accordion({collapsible: true, active: false});
});
