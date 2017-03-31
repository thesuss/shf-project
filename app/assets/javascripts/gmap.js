var map;

// default position (latitude, longitude) = Sweden
var defaultLatitude = 59.3293235;
var defaultLongitude = 18.0685808;

var defaultZoom = 5;

function showGMap(marker_json, zoomLevel) {

    var zoomTo = defaultZoom;

   zoomLevel == null ?  zoomTo = defaultZoom : zoomTo = zoomLevel;

    handler = Gmaps.build('Google');

    handler.buildMap({ internal: {id: 'map'}}, function(){

        markers = handler.addMarkers( marker_json );

        handler.bounds.extendWith(markers);
        handler.fitMapToBounds();
        handler.getMap().setZoom(zoomTo);

    });

    var selection;
   // geolocateUser();

}



function geolocateUser(lat, lng) {
    var latitude;
    var longitude;

/*
    Gmaps.geolocate({

        success: function (position) {
            latitude = position.coords.latitude;
            longitude = position.coords.longitude;
            map.setCenter(latitude, longitude);
        },

        error: function (error) {
            alert('Geolocation failed: ' + error.message);
        },

        not_supported: function () {
            alert('Your browser does not support geolocation');
        }
    });

*/

}
