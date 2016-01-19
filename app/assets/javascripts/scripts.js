$(document).ready(function() {
  // Datatables
  table = $('table.datatable').DataTable();
  initTooltips();

  table.on( 'draw.dt', function () {
    initTooltips();
  } );

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

  $(".sign-in-link").click(function() {
    $("#sign-in-modal").dialog('open');
  });

  $(".sign-up-link").click(function(){
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
  function initTooltips(){
    $('.tooltip').click(function() {
      $(this).find('.tooltip-panel').fadeToggle(200);
      $(this).find('.tooltip-trigger').toggleClass('tooltip-trigger--active');
    });
  }

  // Dropbox
  $('.dropbox-button').click(function(){
    var dropboxButton = this;
    var options = {
      success: function(files) {
        $(dropboxButton).parent().find('#short_url_url').val(files[0].link);
      },
      cancel: function() {
      },
      linkType: "direct",
      multiselect: false,
    };

    Dropbox.choose(options);
  });
})
