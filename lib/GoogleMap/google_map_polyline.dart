import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapPolyline extends StatefulWidget {
  const GoogleMapPolyline({super.key});

  @override
  State<GoogleMapPolyline> createState() => _GoogleMapPolylineState();
}

LatLng mycurrentLocation = LatLng(24.8806, 67.1625);

// late GoogleMapController googleMapController;
Set<Marker> marker = {};
final Set<Polyline> polyline = {};

List<LatLng> pointOnMap = [
  const LatLng(24.875797, 67.163707),
  const LatLng(24.879191, 67.151919),
  const LatLng(24.881917, 67.152117),

  // const LatLng(24.881917, 67.152117),
  // const LatLng(24.881917, 67.152117),
  // const LatLng(24.881917, 67.152117),
  // const LatLng(24.881917, 67.152117),
];

class _GoogleMapPolylineState extends State<GoogleMapPolyline> {
  @override
  void initState() {
    for (var i = 0; i < pointOnMap.length; i++) {
      marker.add(
        Marker(
          markerId: MarkerId(
            i.toString(),
          ),
          infoWindow: InfoWindow(
              title: 'Place around my Country', snippet: 'So beautiful'),
          icon: BitmapDescriptor.defaultMarker,
          position: pointOnMap[i],
        ),
      );
      setState(() {
        polyline.add(Polyline(
            polylineId: PolylineId('Id'),
            points: pointOnMap,
            color: Colors.blue));
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        polylines: polyline,
        myLocationButtonEnabled: false,
        markers: marker,
        // onMapCreated: (GoogleMapController controller) {
        //   googleMapController = controller;
        // },
        initialCameraPosition: CameraPosition(
          zoom: 14,
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
    );
  }
}
