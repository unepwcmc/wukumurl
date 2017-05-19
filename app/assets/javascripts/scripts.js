$(document).ready(function() {
  // Datatables
  table = $('table.datatable').DataTable();
  initTooltips();
  initModals();

  table.on( 'draw.dt', function () {
    initTooltips();
    initModals();
  } );

  $(".sign-in-link").click(function() {
    $("#sign-in-modal").dialog('open');
  });

  $(".sign-up-link").click(function(){
    $("#sign-up-modal").dialog('open');
  });

  $("#create-link").click(function(){
    $("#create-link-modal").dialog('open');
  });

  // Modals
  function initModals() {
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

    $(".copy-link-modal").dialog({
      autoOpen: true,
      width: "400px"
    });
  }

  // Tooltips
  function initTooltips(){
    // The tooltips themselves
    $('.tooltip').unbind('click').click(function() {
      $(this).find('.tooltip-panel').fadeToggle(200);
      $(this).find('.tooltip-trigger').toggleClass('tooltip-trigger--active');
    });

    // Individual link history modal
    $(".history-link").unbind('click').click(function(){
      var short_url_id = $(this).data("id");
      $("#change-history-modal-" + short_url_id).dialog('open');

    });

    // Individual edit link modal
    $(".edit-link").unbind('click').click(function(){
      var short_url_id = $(this).data("id");
      $("#edit-link-modal-" + short_url_id).dialog('open');
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

  // OneDrive
  $('.onedrive-button').click(function(){
    var oneDriveButton = this;
    var msAppId = $(this).data("ms-app-id");
    var odOptions = {
      clientId: "INSERT-APP-ID-HERE",
      action: "share",
      multiSelect: false,
      openInNewWindow: true,
      advanced: {},
      success: function(files) {
        $(oneDriveButton).parent().find('#short_url_url').val(value[0].webUrl);
      },
      cancel: function() { /* cancel handler */ },
      error: function(e) { /* error handler */ }
    }

    OneDrive.open(odOptions);
  });

  // Map switching
  //
  $('.toggle-map-button').click(function(e){
    e.preventDefault();
    $('#map').toggle();
    $('.visits-by-country-table').toggle();
    var text = $(this).text();
    $(this).text(text == "Switch to List view" ? "Switch to Map view" : "Switch to List view");
  });

  // Copy to clipboard
  var clipboard = new Clipboard('#copy-link-button');

  clipboard.on('success', function(e) {
    $('#copy-link-modal').dialog('close');
  });
});


