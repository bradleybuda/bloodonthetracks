FBL.ns(function() { with (FBL) {

  var httpRequestObserver = {
    observe: function(subject, topic, data) {
      if (topic == "http-on-examine-response") {
        var httpChannel = subject.QueryInterface(Components.interfaces.nsIHttpChannel);
        this.lastRequestId = httpChannel.getResponseHeader("X-BOTT-Request-Id");
      }
    },

    get observerService() {
      return Components.classes["@mozilla.org/observer-service;1"]
        .getService(Components.interfaces.nsIObserverService);
    },

    register: function()
    {
      this.observerService.addObserver(this, "http-on-examine-response", false);
    },

    unregister: function()
    {
      this.observerService.removeObserver(this, "http-on-examine-response");
    }
  };

  // Module
  Firebug.BloodOnTheTracks = extend(Firebug.Module, {
    initialize: function () {
      httpRequestObserver.register();
    },
    shutdown: function() {
      httpRequestObserver.unregister();
    },
    showPanel: function(browser, panel) {
      // TODO check to see which panel this is
      if (panel.name != "BloodOnTheTracks")
        return;

      // Check the response headers for the current page to see if
      // this is a Rails app running the BOTT plugin
      var requestId = httpRequestObserver.lastRequestId;

      // TODO should probably not be happening in showPanel...
      // fetch some information on the request from the server
      // TODO un-hardcode
      // TODO use XHR?
      var url = 'http://localhost:3000/blood_on_the_tracks/' + requestId;
      var xhr = new XMLHttpRequest();
      xhr.open("GET", url, false);
      xhr.send();
      var result = JSON.parse(xhr.responseText);
        //Firebug.Console.log(result);

      // TODO show nothing if undefined
      // TODO should we be pulling this from Firefox, or from Firebug?
      this.metadata = result;

      var metadataTemplate = domplate({
        foo:
        DIV({style: 'position: absolute; right: 0px; top: 0px; height: 100%; width: 30%'},
            TABLE({border: '1px', width: '100%'},
                  TR(TD("Request ID"), TD(Firebug.BloodOnTheTracks.metadata.request_id)),
                  TR(TD("Controller"), TD(Firebug.BloodOnTheTracks.metadata.controller)),
                  TR(TD("Action")    , TD(Firebug.BloodOnTheTracks.metadata.action))
                 )
           )
      });

      var parentNode = panel.panelNode;
      var rootTemplateElement = metadataTemplate.foo.append({}, parentNode, metadataTemplate);
    }
  });

  // Panel
  function BloodOnTheTracksPanel() {}
  BloodOnTheTracksPanel.prototype = extend(Firebug.Panel, {
    name: "BloodOnTheTracks",
    title: "Rails",
    initialize: function () {
      Firebug.Panel.initialize.apply(this, arguments);
    },
    show: function() {
    }
  });

  Firebug.registerModule(Firebug.BloodOnTheTracks);
  Firebug.registerPanel(BloodOnTheTracksPanel);

}});