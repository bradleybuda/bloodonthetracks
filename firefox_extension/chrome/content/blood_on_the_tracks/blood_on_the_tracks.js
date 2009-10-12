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

      // TODO show nothing if undefined
      // TODO should we be pulling this from Firefox, or from Firebug?
      this.metadata = result;

      var metadataTemplate = domplate({
        tag:
        DIV({style: 'width: 100%; height: 100%'},
            // console on LHS
            DIV({style: 'position: absolute; left: 0px; top: 0px; height: 99%; width: 70%'},
                DIV({style: 'height: 85%; width: 100%; border: 1px solid black;'},
                    "Welcome to the Rails Console"),
                DIV({style: 'height: 14%; width: 100%; border: 1px solid black;'},
                    ">>")),

            // table on RHS
            DIV({style: 'position: absolute; right: 0px; top: 0px; height: 100%; width: 30%'},
                TABLE({border: '1px', width: '100%'},
                      TR(TD({width: '20%'},"Controller"), TD(this.metadata.controller)),
                      TR(TD({width: '20%'},"Action")    , TD(this.metadata.action)),
                      TR(TD({colspan: "2"}, "Instance Variables")),
                      FOR("instance_var", "$instance_vars",
                          TR(TD({width: '20%'},"$instance_var"), TD("???"))))))

      }); 

      var parentNode = panel.panelNode;
      var rootTemplateElement = metadataTemplate.tag.replace({instance_vars: this.metadata.instance_variables}, parentNode, metadataTemplate);
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