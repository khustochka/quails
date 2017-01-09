$(function() {
  $(document).on("click", ".facebook-login", function(e) {
    e.preventDefault();
    FB.login(function(response) {
      if (response.authResponse) {
        $('#connect').html('Connected! Hitting OmniAuth callback (GET /auth/facebook/callback)...');
        // since we have cookies enabled, this request will allow omniauth to parse
        // out the auth code from the signed request in the fbsr_XXX cookie

        // FIXME: WORKAROUND FOR CHROME + test app!
        var cookie_name = "fbsr_" + $("meta[property='fb:app_id']").attr('content');

        //var match = document.cookie.match(new RegExp(cookie_name + '=([^;]+)'));
        //if(match == null) {
        document.cookie = cookie_name + "=" + response.authResponse.signedRequest + ";path=/";
        //}
        console.log("For some reason this does not work in Chrome, cookie is not created. "+
            "See https://github.com/mkdynamic/omniauth-facebook/issues/165");
        // It also says it should work for Test users but I failed.
        // END WORKAROUND

        $.get('/auth/facebook/callback', function(data, status, xhr) {
          //$('#connect').html('Connected! Callback complete.');
          //$('#results').html(JSON.stringify(json));
//                    FB.api('/me', function(response) {
//                        console.log('Successful login for: ' + JSON.stringify(response));
//                    });
          $(".comment_author_panel").html(data);
          //console.log(data);
          $("<input>", {type: "hidden", name: "commenter[provider]", value: "facebook"}).appendTo($("#new_comment"));
        });
      }
    }, { scope: 'public_profile,email', state: 'abc123' });
  });
});
