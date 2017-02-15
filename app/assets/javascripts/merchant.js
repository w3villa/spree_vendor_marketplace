//= require jquery.raty.js
//= require noty/jquery.noty
//= require noty/layouts/topCenter
//= require noty/themes/default

$.ajaxSetup({
  headers: {
    'X-Spree-Token': $('meta[name="csrf-token"]').attr('content')
  }
});


$(document).ready(function() {
  var Store = function(){
    this.init();
  }
  Store.prototype = {
    init: function() {
      this.lastMarker = null;
      this.showNoty();
      this.bindAddLocation();
      this.previewMap();
      this.saveLocation();
      this.selectAll();
    },

    selectAll: function() {
      $('#select-all').click(function() 
      {
        if ($(this).prop('checked')) {
         $('.asin-holder').prop('checked', true); 
        } else {
          $('.asin-holder').prop('checked', false); 
        }
      });
    },

    showNoty: function() {
      $.noty.defaults = {
        layout: 'topCenter',
        theme: 'defaultTheme', // or 'relax'
        type: 'alert',
        text: '', // can be html or string
        dismissQueue: true, // If you want to use queue feature set this true
        template: '<div class="noty_message"><span class="noty_text"></span><div class="noty_close"></div></div>',
        animation: {
            open: {height: 'toggle'}, // or Animate.css class names like: 'animated bounceInLeft'
            close: {height: 'toggle'}, // or Animate.css class names like: 'animated bounceOutLeft'
            easing: 'swing',
            speed: 500 // opening & closing animation speed
        },
        timeout: 35000, // delay for closing event. Set false for sticky notifications
        force: false, // adds notification to the beginning of queue when set to true
        modal: false,
        maxVisible: 5, // you can set max visible notification for dismissQueue true option,
        killer: false, // for close all notifications before show
        closeWith: ['click'], // ['click', 'button', 'hover', 'backdrop'] // backdrop click will close all notifications
        callback: {
          onShow: function() {},
          afterShow: function() {},
          onClose: function() {},
          afterClose: function() {},
          onCloseClick: function() {},
        },
        buttons: false // an array of buttons
      };
      if ( !! noty_option) {
        noty(noty_option);
      }
    },

    getLatLng: function() {
      var latitude, longitude;
      var mapPreview = $("#map-preview");

      if(mapPreview.length != 0) {
        var isLocated = mapPreview.data("is_located");
        if(isLocated){
          latitude = parseFloat(mapPreview.data("latitude"));
          longitude = parseFloat(mapPreview.data("longitude"));
        } else {
          latitude = 40.7142700;
          longitude = -74.0059700;
        }
        return(new google.maps.LatLng(latitude, longitude));  
      } else {
        return(false);
      }
    },

    getInfoWindow: function(map, marker) {
      var infowindow = new google.maps.InfoWindow({content  : "<b>"+$("#company-name").text()+"</b><div>"+$("#full-address").text()+"</div>"})
      google.maps.event.addListener(marker, 'click', function() {
        infowindow.open(map, marker);
      });
    },

    previewMap: function() {
      var latLng = this.getLatLng();
      if(latLng) {
        var mapOptions = {
          center: latLng,
          zoom: 8,
          mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        map = new google.maps.Map(document.getElementById("map-preview"), mapOptions);
        this.markOnMap(map, latLng);  
      }
    },

    markOnMap: function(map, latLng) {
      if($("#map-preview").data("is_located")) {
        var marker = new google.maps.Marker({
          position: latLng,
          map: map
        });
        this.lastMarker = marker;
        this.getInfoWindow(map, marker);  
      }
    },

    addSearchBoxInMap: function(map) {

      var input = $("<input>").attr({type: "text", id: "pac-input", class: "controls form-control map-search", placeholder: "Search a location..."})[0];
      var searchBox = new google.maps.places.SearchBox(input);
      map.controls[google.maps.ControlPosition.TOP].push(input);
      // Bias the SearchBox results towards current map's viewport.
      map.addListener('bounds_changed', function() {
        searchBox.setBounds(map.getBounds());
      });
      var markers = [];

      searchBox.addListener('places_changed', function() {
        var places = searchBox.getPlaces();

        if (places.length == 0) {
          return;
        }

        // Clear out the old markers.
        markers.forEach(function(marker) {
          marker.setMap(null);
        });
        markers = [];

        // For each place, get the icon, name and location.
        var bounds = new google.maps.LatLngBounds();
        places.forEach(function(place) {
          if (!place.geometry) {
            console.log("Returned place contains no geometry");
            return;
          }
          var icon = {
            url: place.icon,
            size: new google.maps.Size(71, 71),
            origin: new google.maps.Point(0, 0),
            anchor: new google.maps.Point(17, 34),
            scaledSize: new google.maps.Size(25, 25)
          };

          // Create a marker for each place.
          markers.push(new google.maps.Marker({
            map: map,
            icon: icon,
            title: place.name,
            position: place.geometry.location
          }));

          if (place.geometry.viewport) {
            // Only geocodes have viewport.
            bounds.union(place.geometry.viewport);
          } else {
            bounds.extend(place.geometry.location);
          }
        });
        map.fitBounds(bounds);
      });

      // google.maps.event.addListener(searchBox, 'places_changed', function() {

      //   var places = searchBox.getPlaces();

      //   for (var i = 0, marker; marker = markers[i]; i++) {
      //     marker.setMap(null);
      //   }

      //   markers = [];

      //   var bounds = new google.maps.LatLngBounds();

      //   for (var i = 0, place; place = places[i]; i++) {
      //     var image = {
      //       url: place.icon,
      //       size: new google.maps.Size(71, 71),
      //       origin: new google.maps.Point(0, 0),
      //       anchor: new google.maps.Point(17, 34),
      //       scaledSize: new google.maps.Size(25, 25)
      //     };

      //     bounds.extend(place.geometry.location);
      //   }

      //   map.fitBounds(bounds);
      // });

      // google.maps.event.addListener(map, 'bounds_changed', function() {
      //   var bounds = map.getBounds();
      //   searchBox.setBounds(bounds);
      // });

    },

    setMapAttributes: function() {
      var latLng = this.getLatLng();
      var that = this;
      var mapOptions = {
        center: latLng,
        zoom: 2,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      var map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
      that.myMap = map;
      this.addSearchBoxInMap(map);
      google.maps.event.trigger(map, 'resize');
      map.setZoom(map.getZoom());
      this.markOnMap(map, latLng);
      google.maps.event.addListener(map, 'click', function(e) {
        that.setLocation(e.latLng, map);
      });
    },

    saveLocation: function() {
      $(document).on("click", "#save-location", function(event) {
        var $this = $(event.target);
        if(this.lastMarker) {
          noty({text: "Please select the location", type: "error"});
        } else {
          var lat = myCompany.lastMarker.position.lat()
          var lng = myCompany.lastMarker.position.lng()
          var latlng = new google.maps.LatLng(lat, lng);
          var geocoder = geocoder = new google.maps.Geocoder();
          geocoder.geocode({ 'latLng': latlng }, function (results, status) {
              if (status == google.maps.GeocoderStatus.OK) {
                  if (results[1]) {
                    var string =[];
                    var array = results[1].formatted_address.split(",");
                    $.ajax({
                      url: "/api/v1/merchant_stores/"+$this.data("store_id")+"/update_location",
                      method: "put",
                      data: { "merchant_store[latitude]": myCompany.lastMarker.position.lat(), "merchant_store[longitude]": myCompany.lastMarker.position.lng(),"merchant_store[street_number]": array[array.length-4], "merchant_store[city]": array[array.length-3],"merchant_store[state]": array[array.length-2], "merchant_store[country]": array[array.length-1]},
                      success: function(data, status) {
                        if(data.success) {
                          $("#map-preview").data("latitude", myCompany.lastMarker.position.lat());
                          $("#map-preview").data("longitude", myCompany.lastMarker.position.lng());
                          $("#map-preview").data("is_located", true);
                          myCompany.previewMap();
                          noty({text: "Location updated successfully", type: "information"});
                          $('.modal').modal('hide');
                          var x = location.pathname;
                          location.assign(x);
                        } else {
                          noty({text: data.message, type: "error"});
                        }
                      }
                    }); 
                  }
              }
          }); 
        }
        return(false);
      });
    },

    setLocation: function(latLng, map) {
      if(this.lastMarker) {
        this.lastMarker.setMap(null);
      } 
      var marker = new google.maps.Marker({
        position: latLng,
        map: map
      });
      this.lastMarker = marker;
      this.getInfoWindow(map, marker);
    },

    bindAddLocation: function() {
      var that = this;
      $("#add-location").bind("click", function() {
        $("#map-dialog").modal('show');
        that.setMapAttributes();
        return(false);
      });
      $("#map-dialog").on("shown.bs.modal", function() {
        that.setMapAttributes();
      });
    }
  }
  
  var myCompany = new Store();
});