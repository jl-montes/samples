
 console.log("loading initMap")
 function initMap() {
        var uluru = {lat: 32.861089, lng: -96.9586285};
        var map = new google.maps.Map(document.getElementById('map'), {
          zoom: 18,
          center: uluru
        });
        var marker = new google.maps.Marker({
          position: uluru,
          title: 'Hair by Ofelia - Inside Phenix Salon Suites',
          map: map
        });
 }