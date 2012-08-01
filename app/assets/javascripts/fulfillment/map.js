$(document).ready(function(){
  var usLocation = new google.maps.LatLng(37.09024, -95.71289);

  var mapOptions = {
    zoom: 2,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    center: usLocation
  }

  var map = new google.maps.Map(document.getElementById("map_container"), mapOptions);

  var markerClusterer = new MarkerClusterer(map, Array(), {'maxZoom':10});

  var geocoder = new google.maps.Geocoder();

  var Delivery = function(origin, destination, shipped, shipperFullName, expectedDeliveryDate, link){
    var self = this;
    var base = 'http://chart.apis.google.com/chart?cht=mm&chs=24x32&';
    var targetImage = base + 'chco=FFFFFF,DD8CFF,000000&ext=.png';
    var sourceImage = base + 'chco=AAFDAA,11BEEE,000333&ext=.png';

    var makeContent = function(){
      return "<ul><li>Address: " + address + "</li><li>Shipped: " + shipped + "</li><li>Shipping Service: " + shipperFullName + "</li><li>Expected Delivery Date: " + expectedDeliveryDate + "</li></ul><a href=" + link + ">view</a>";
    }

    var pinTarget = function(position){
      var marker = new google.maps.Marker({
        position: position,
        map: map,
        icon: targetImage
      });
      markerClusterer.addMarker(marker);
      var infoWindow = new google.maps.InfoWindow({
        content: content,
        disableAutoPan: true,
      });
      infoWindow.open(map, marker);
    }

    var pinSource = function(position){
      var marker = new google.maps.Marker({
        position: position,
        map: map,
        icon: sourceImage
      });
      markerClusterer.addMarker(marker);
    }

    var address = address;
    var shipped = shipped;
    var shipperFullName = shipperFullName;
    var expectedDeliveryDate = expectedDeliveryDate;
    var content = makeContent();
    pinSource(origin);
    pinTarget(destination);

    var path = [origin, destination];

    var route = new google.maps.Polyline({
      path: path,
      strokeColor: '#008000',
      strokeOpacity: 1.0,
      strokeWeight: 2
    });

    route.setMap(map);
  }

  var v1 = new google.maps.LatLng(38.1,39.2);
  var v2 = new google.maps.LatLng(40.7,50.8);
  var v3 = new google.maps.LatLng(45.6,96.3);
  var v4 = new google.maps.LatLng(35.4,23.4);
  var v5 = new google.maps.LatLng(-19.3,-14.6);
  var v6 = new google.maps.LatLng(32.11,32.222);
  var v7 = new google.maps.LatLng(0.34,-60.56);
  var v8 = new google.maps.LatLng(1.5,1.6);


  d = new Delivery(v1,v2, 'Yes','someshipper', 'somedate','linkpath');
  e = new Delivery(v3,v4,'7318 Black Swan Place, Carlsbad, CA', 'Yes','someshipper', 'somedate','linkpath');
  f = new Delivery(v5,v6,'7319 Black Swan Place, Carlsbad, CA', 'Yes','someshipper', 'somedate','linkpath');
  g = new Delivery(v7,v8,'7320 Black Swan Place, Carlsbad, CA', 'Yes','someshipper', 'somedate','linkpath');

});