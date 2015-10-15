$(document).ready(function() {
  $(".modal").dialog({
    autoOpen: false,
    resizeable: false,
    draggable: false,
    modal: true,
    show: { effect: "slide", direction: "up" },
  });

  $('#datatable').DataTable();

  $("#sign-in-link").click(function() {
    $("#sign-in-modal").dialog('open');
  });

  $("#sign-up-link").click(function(){
    $("#sign-up-modal").dialog('open');
  });

  $("#create-link").click(function(){
    $("#create-link-modal").dialog('open');
  });

  // Tooltips
  $('.tooltip').hover(function() {
    $(this).find('.tooltip-panel').fadeToggle(200);
  }, function() {
    $(this).find('.tooltip-panel').fadeToggle(200);
  });
})
