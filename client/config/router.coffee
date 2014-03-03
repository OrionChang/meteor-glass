Router.map () ->
  this.route 'home',
    path: '/'
    action: () ->

		Deps.autorun ->
		    if Meteor.userId() isnt undefined
		        Meteor.subscribe "timeline_items", Meteor.userId()