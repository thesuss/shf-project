// Don't load until after the code in the window has loaded.
//  because we have to be sure that jquery, google maps etc. javascripts have been loaded


// Display a dynamic Google map
//  centerCoordinates: the initial center for the map.
//   (= Stockholm if none given  [59.32932349999999, 18.0685808])
//  markers = an array of markers to display on the map
//  icon = the icon to use for each of the markers
//
//  If there is only 1 marker for the map, center the map on that marker
//  else display all of the markers,and so the center is automatically
//   determined by the center of all of them.
//

// markers default value is [] to be used if markers is null

function initCenteredMap(centerCoordinates, markers = [], icon) {

    var mapCenter = {lat: 59.3293235, lng: 18.0685808};

    if (centerCoordinates === null) {
        // try to get the user's coordinates
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function (position) {
                mapCenter = new google.maps.LatLng(position.coords.latitude,
                    position.coords.longitude);
            });
        }
    }
    else {
        mapCenter = centerCoordinates;
    }

    var map = new google.maps.Map(document.getElementById('map'), {
        center: mapCenter,
        zoom: 13
    });


    addMarkerClustererToMap(map, markers);

}




function addMarkerClustererToMap (map, locations) {

    markers = [];

    var infoWindow = new google.maps.InfoWindow();

    locations.forEach(addMarker);

    // For each location create a marker and add an event listener to open infoWindow
    function addMarker(location, index){

        var marker = new google.maps.Marker({
            position: {lat: location.latitude, lng: location.longitude}
        });

        // don't create a pop-up box if there's no text to display
        if (location.text !== ""){
            marker.addListener('click', function() {
                infoWindow.setContent(location.text.trim());
                infoWindow.open(map, marker);
            });
        }

        markers[index] = marker;
    }

    var markerCluster = new MarkerClusterer(map, markers, {
        imagePath: 'map-markers/m'
    });

    // fit the map center and zoom to see all markers, if markers exist
    if (markers.length > 1) {
        var bounds = new google.maps.LatLngBounds();
        addBound = (marker) => bounds.extend(marker.position);
        markers.forEach(addBound);
        map.fitBounds(bounds);
    }

}

