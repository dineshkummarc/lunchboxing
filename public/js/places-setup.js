var defaultBounds = new google.maps.LatLngBounds(
  new google.maps.LatLng(45.511159,-122.65686),
  new google.maps.LatLng(45.550004,-122.719393));

var input = document.getElementById('locationName');
var options = {
  bounds: defaultBounds,
  types: ['establishment']
};

autocomplete = new google.maps.places.Autocomplete(input, options);

google.maps.event.addListener(autocomplete, 'place_changed', function(){
  var place = autocomplete.getPlace();
  var name = place.name
  var address = place.formatted_address
  $('#locationName').val ( name )
  $('#locationAddress').val( address );
  console.log(place.formatted_address);
});

