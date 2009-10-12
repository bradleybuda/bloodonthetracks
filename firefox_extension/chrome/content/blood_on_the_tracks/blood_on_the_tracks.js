FBL.ns(function() { with (FBL) {

function BloodOnTheTracksPanel() {}
BloodOnTheTracksPanel.prototype = extend(Firebug.Panel,
{
    name: "BloodOnTheTracks",
    title: "Rails",

    initialize: function() {
      Firebug.Panel.initialize.apply(this, arguments);
    },
});

Firebug.registerPanel(BloodOnTheTracksPanel);

}});