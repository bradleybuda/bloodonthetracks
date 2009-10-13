FBL.ns(function() { with (FBL) {

String.prototype.htmlEntities = function () {
   return this.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
};

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
      var url = 'http://localhost:3000/blood_on_the_tracks/' + requestId + '/metadata';
      var xhr = new XMLHttpRequest();
      xhr.open("GET", url, false);
      xhr.send();
      var metadata = JSON.parse(xhr.responseText);

      // extract instance var keys
      var instance_variables = []
      for (var ivar_name in metadata.instance_variables_pretty) {
        instance_variables.push({name: ivar_name, value: metadata.instance_variables_pretty[ivar_name]});
      }

      var metadataTemplate = domplate({
        tag:
        DIV({style: 'width: 100%; height: 100%'},
            // console on LHS
            DIV({style: 'position: absolute; left: 0px; top: 0px; height: 99%; width: 70%'},
                DIV({id: 'railsCommandLog', style: 'height: 90%; width: 100%; border: 1px solid black; padding: 3px;'},
                    SPAN(STRONG("Welcome to the Rails Console")), BR()),
                INPUT({id: 'railsCommand', onkeypress: "$onKeyPress", type: 'text', style: "position: absolute; left: 0px; bottom: 0px; width: 99%;"})),

            // table on RHS
            DIV({style: 'position: absolute; right: 0px; top: 0px; height: 100%; width: 30%'},
                TABLE({border: '1px', width: '100%'},
                      TR(TD({width: '20%'},"Controller"), TD(metadata.controller)),
                      TR(TD({width: '20%'},"Action")    , TD(metadata.action)),
                      TR(TD({colspan: "2"}, "Instance Variables")),
                      FOR("instance_var", "$instance_vars",
                          TR(TD({width: '20%'},"$instance_var.name"), TD("$instance_var.value")))))),
        onKeyPress: function(event){
          if (event.keyCode == 13) { // enter key

            // TODO up arrow!

            // write command to log
            var commandText = panel.document.getElementById('railsCommand').value;
            panel.document.getElementById('railsCommandLog').innerHTML += "<span><strong>" + commandText.htmlEntities() + "</strong></span><br/>";
            panel.document.getElementById('railsCommand').value = '';

            // make HTTP request
            var url = 'http://localhost:3000/blood_on_the_tracks/' + requestId + '/eval';
            var xhr = new XMLHttpRequest();
            var request = JSON.stringify({command: commandText})
            xhr.open("POST", url, false);
            xhr.send(request);

            // handle response
            var response = JSON.parse(xhr.responseText);
            var resultText = response.result;
            if (response.error)
              panel.document.getElementById('railsCommandLog').innerHTML += "<span style='color:red;'>" + resultText.htmlEntities() + "</span><br/>";
            else
              panel.document.getElementById('railsCommandLog').innerHTML += "<span>" + resultText.htmlEntities() + "</span><br/>";
          }
        }
      }); 

      var parentNode = panel.panelNode;
      var rootTemplateElement = metadataTemplate.tag.replace({instance_vars: instance_variables}, parentNode, metadataTemplate);
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