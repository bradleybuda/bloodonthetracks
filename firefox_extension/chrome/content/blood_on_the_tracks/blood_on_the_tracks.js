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

  function BloodOnTheTracksPanel() {}
  BloodOnTheTracksPanel.prototype = extend(Firebug.Panel, {
    name: "BloodOnTheTracks",
    title: "Rails",


    initialize: function() {
      Firebug.Panel.initialize.apply(this, arguments);

      httpRequestObserver.register();

      Firebug.Console.log("Rails initialized");
      Firebug.Console.log(this);
    },

    show: function() {
      Firebug.Console.log("Rails tab visible");
      // Check the response headers for the current page to see if
      // this is a Rails app running the BOTT plugin

      Firebug.Console.log(httpRequestObserver.lastRequestId);
    },

    shutdown: function() {
      Firebug.Panel.shutdown.apply(this, arguments);

      Firebug.Console.log("Rails shutdown");

      httpRequestObserver.unregister();
    }
    
  });

  Firebug.registerPanel(BloodOnTheTracksPanel);

}});