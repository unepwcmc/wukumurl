$(document).ready(function() {
  $(".modal").dialog({
    autoOpen: false,
    resizeable: false,
    draggable: false,
    modal: true,
    show: { effect: "slide", direction: "up" },
  });

  $("#sign-in-link").click(function() {
    $("#sign-in-modal").dialog('open');
  });

  $("#sign-up-link").click(function(){
    $("#sign-up-modal").dialog('open');
  });
})
