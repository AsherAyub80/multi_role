import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMaps extends StatefulWidget {
  const GoogleMaps({super.key});

  @override
  State<GoogleMaps> createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {
  LatLng mycurrentLocation = LatLng(24.8806, 67.1625);

  late GoogleMapController googleMapController;
  Set<Marker> marker = {};

  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;

  @override
  initState() {
    customMarker();
    super.initState();
  }

  void customMarker() {
    BitmapDescriptor.asset(ImageConfiguration(), 'assets/tracking.png')
        .then((icon) {
      setState(() {
        customIcon = icon;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: GoogleMap(
        myLocationButtonEnabled: false,
        markers: marker,
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: mycurrentLocation,
        ),
        // markers: {
        //   Marker(
        //     markerId: MarkerId('Marker Id'),
        //     position: mycurrentLocation,
        //     draggable: true,
        //     onDrag: (value) {},
        //     infoWindow: InfoWindow(
        //         title: 'Title of Marker', snippet: 'More info about marker'),
        //         icon:customIcon,
        //   ),

        // },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () async {
          Position position = await currentPosition();
          googleMapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  zoom: 15,
                  target: LatLng(position.latitude, position.longitude))));
          marker.clear();
          marker.add(Marker(
            markerId: MarkerId('This is my location'),
            position: LatLng(position.latitude, position.longitude),
            draggable: true,
            onDrag: (value) {},
            infoWindow: InfoWindow(
                title: 'Title of Marker', snippet: 'More info about marker'),
            icon: customIcon,
          ));
          setState(() {});
        },
        child: Icon(
          Icons.my_location,
          size: 30,
        ),
      ),
    );
  }

  Future<Position> currentPosition() async {
    bool serviceEnable;
    LocationPermission permission;

    serviceEnable = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnable) {
      return Future.error('Location service are disable');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error('Location Permission Denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location Permission Denied Permenantaly');
    }
    Position position = await Geolocator.getCurrentPosition();
    return position;
  }
}
