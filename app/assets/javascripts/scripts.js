$(document).ready(function() {
  // Datatables
  $('#datatable').DataTable();

  // Modal windows
  $(".modal").dialog({
    autoOpen: false,
    resizeable: false,
    draggable: false,
    modal: true,
    show: { effect: "slide", direction: "up" },
  });

  $(".history-modal").dialog({
    width: "600px"
  });

  $("#sign-in-link").click(function() {
    $("#sign-in-modal").dialog('open');
  });

  $("#sign-up-link").click(function(){
    $("#sign-up-modal").dialog('open');
  });

  $("#create-link").click(function(){
    $("#create-link-modal").dialog('open');
  });

  $(".edit-link").click(function(){
    var short_url_id = $(this).data("id");
    $("#edit-link-modal-" + short_url_id).dialog('open');
  });

  $(".history-link").click(function(){
    var short_url_id = $(this).data("id");
    //alert(short_url_id);
    $("#change-history-modal-" + short_url_id).dialog('open');
  });

  // Tooltips
  $('.tooltip').hover(function() {
    $(this).find('.tooltip-panel').fadeToggle(200);
  }, function() {
    $(this).find('.tooltip-panel').fadeToggle(200);
  });

  // Dropbox
  $('.dropbox-button').click(function(){
    var options = {
      success: function(files) {
        alert("Here's the file link: " + files[0].link)
      },
      cancel: function() {
      },
      linkType: "direct",
      multiselect: false,
      extensions: ['.pdf', '.doc', '.docx'],
    };

    Dropbox.choose(options);
  });
})
