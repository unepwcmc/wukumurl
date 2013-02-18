window.WcmcIoWidget = (function() {

  function WcmcIoWidget(domSelector) {
    this.domElement = $(domSelector);
    this.domElement.addClass('wcmc-io-widget');
    this.renderForm();
  }

  WcmcIoWidget.prototype.renderForm = function() {
    this.domElement.html("<form>\n    <input id=\"url-to-shorten\" type=\"text\" placeholder=\"Paste a link to shorten\">\n    <button id=\"shorten-link-btn\" class=\"btn\" type=\"submit\">Shorten</button>\n  </form>");
    var _this = this;
    return this.domElement.on('submit', 'form', function(e) {
      var url;
      e.preventDefault();
      url = _this.domElement.find('#url-to-shorten').val();

      $.ajax({
        url: 'http://wcmc.io/',
        type: 'POST',
        data: {
          url: url
        }
      }).done(function(shortUrl) {
        _this.showNew(shortUrl);
      }).fail(function() {
        _this.failure();
      });
      return false;
    });
  };

  WcmcIoWidget.prototype.showNew = function(shortUrl) {
    this.domElement.prepend("<span class='new-link-notice'>\n  Your shortened link is:\n  <a href=\"http://wcmc.io/" + shortUrl.short_name + "\">wcmc.io/" + shortUrl.short_name + "</a>\n</span>");
  };

  WcmcIoWidget.prototype.failure = function(response) {
    var error, errorMsg, field, _ref;
    errorMsg = "";
    _ref = $.parseJSON(response.responseText);
    for (field in _ref) {
      error = _ref[field];
      errorMsg += "" + field + " " + error + "\n";
    }
    alert(errorMsg);
  };

  return WcmcIoWidget;

})();
