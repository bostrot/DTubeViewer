window.addEventListener("scroll", bringmenu);
function bringmenu() {
    if (document.body.scrollTop > 5 || document.documentElement.scrollTop > 5) {
        $(".borderless").fadeOut();
    } else {
        $(".borderless").fadeIn();
    }
}

 /*$(function() {			
    //Enable swiping...
    $("html").swipe( {
        //Generic swipe handler for all directions
        swipe:function(event, direction, distance, duration, fingerCount, fingerData) {
            console.log("You swiped " + direction );
            if (direction === "right") {
                $(".sidebar").fadeIn();
            } else if (direction === "left") {
                $(".sidebar").fadeOut();
            }
        },
        //Default is 75px, set to 0 for demo so any distance triggers swipe
       threshold:0
    });
});
    
__meteor_runtime_config__ = JSON.parse(decodeURIComponent("%7B%22meteorRelease%22%3A%22METEOR%401.4.4.1%22%2C%22meteorEnv%22%3A%7B%22NODE_ENV%22%3A%22production%22%2C%22TEST_METADATA%22%3A%22%7B%7D%22%7D%2C%22PUBLIC_SETTINGS%22%3A%7B%7D%2C%22ROOT_URL%22%3A%22http%3A%2F%2Flocalhost%3A3000%2F%22%2C%22ROOT_URL_PATH_PREFIX%22%3A%22%22%2C%22appId%22%3A%22150zjr3301zki1vu3if5%22%2C%22autoupdateVersion%22%3A%22f99492306a9c2e8b74ec8d57b6be22b8eb19f240%22%2C%22autoupdateVersionRefreshable%22%3A%22e86b152ee079afa62b62b6d5106ea59d50331e9d%22%2C%22autoupdateVersionCordova%22%3A%22none%22%7D"));
//./DTube_files/5dc5a53d5860a33ba782b146e2a90263acd13978.js
$.getScript("./DTube_files/5dc5a53d5860a33ba782b146e2a90263acd13978.js", function() {
Meteor.disconnect()
 });*/