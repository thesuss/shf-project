//
// JsSpace is the js-namespace-rails gem that provides a standard way to call
//  javascript based on the controller and action.

// @see https://github.com/falm/js-namespace-rails
//
JsSpace.on('companies', {

    init: function () {

        console.log('common logic of companies in here');


        // Try HTML5 geolocation.
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function (position) {
                var pos = {
                    lat: position.coords.latitude,
                    lng: position.coords.longitude
                };

//                var mapBounds = map.getBounds();

//                addMarker(pos, map, 'YOU ARE HERE', null);
//                mapBounds.extend(pos);
//                map.setCenter(pos);
//                map.panTo(pos);

                // promise...

                console.info("Found You!  " + position.coords.latitude + ', ' + position.coords.longitude);

            }, function () {
                userLocationError();
            });
        } else {
            // Browser doesn't support Geolocation
            console.info("Geolocation is not supported by your browser.");  // FIXME must translate i18n
        }

    },

    index: function () {
        console.log('logic of companies.index action in here');
    }


});


function userLocationError(error) {
    console.info("Error with navigator.geolocation");

    if (error !== undefined &&  error.code !== undefined) {
        switch (error.code) {
            case error.PERMISSION_DENIED:
                alert("User denied the request for Geolocation.");
                break;
            case error.POSITION_UNAVAILABLE:
                alert("Location information is unavailable.");
                break;
            case error.TIMEOUT:
                alert("The request to get user location timed out.");
                break;
            case error.UNKNOWN_ERROR:
                alert("An unknown error occurred.");
                break;
        }
    }
}
