


Template.loginTmpl.helpers
        


Template.loginTmpl.events
    "click #call": () ->
        Meteor.call "initMirrorApi", Meteor.user(), (err, res) ->
            console.log err, " and ", res
            if err
                if err.message is "user is revoked [500]"
                    Meteor.logout()
                    
            

    # "click #myLogin": () ->
    #     requestPermissions = ["openid", "profile", "email", 'https://www.googleapis.com/auth/glass.timeline', 'https://www.googleapis.com/auth/glass.location']
        
    #     Meteor.loginWithGoogle
        
    