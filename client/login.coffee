





Template.loginTmpl.helpers
    hey: () ->
        "hey"
        


Template.loginTmpl.events
    "click #call": () ->
        Meteor.call "initMirrorApi", Meteor.user()
    