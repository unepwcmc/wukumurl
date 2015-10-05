$(document).ready(function() {
  $( "#dialog-1" ).dialog({
    autoOpen: false,
    resizeable: false,
    draggable: false,
    modal: true
  });
  $( "#sign-in" ).click(function() {
    $( "#dialog-1" ).dialog( "open" );
  });
})
