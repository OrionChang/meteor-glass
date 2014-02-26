
animal = (hey) ->
  run: () ->
    alert hey







Template.loginTmpl.helpers
    hey: () ->
        "hey"

    test: () ->
    	# a = new animal("bar")
    	# a.run()

    	"fine"
        


Template.loginTmpl.events
    "click #call": () ->
        Meteor.call "initMirrorApi", Meteor.user()
    