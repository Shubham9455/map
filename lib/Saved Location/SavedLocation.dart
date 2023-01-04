import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedLocation extends StatefulWidget {
  const SavedLocation({super.key});

  @override
  State<SavedLocation> createState() => _SavedLocationState();
}

class _SavedLocationState extends State<SavedLocation> {
  List<Marker> _markers = [];
  List<String> _lats = [];
  List<String> _longs = [];
  List<String> _address = [];
  bool _loading = false;
  var address = "";
  var lats = 0.0;
  var longs = 0.0;
  final pref = SharedPreferences.getInstance();
  _getLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    debugPrint('location: ${position.latitude} ${position.longitude}');
    final coordinates = new Coordinates(position.latitude, position.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    print("${first.featureName} : ${first.addressLine}");
    setState(() {
      lats = position.latitude;
      longs = position.longitude;
      address = first.addressLine;
    });
  }
  addMarkers() async {
    await pref
        .then((value) => value.getStringList('saved_lats'))
        .then((value){
          debugPrint("saved_lats: $value");
          setState(() => _lats = value!);
        });
    await pref
        .then((value) => value.getStringList('saved_longs'))
        .then((value) => setState(() => _longs = value!));
    await pref
        .then((value) => value.getStringList('saved_address'))
        .then((value) => setState(() => _address = value!));
    debugPrint(_lats.toString());
    setState(() {
      if (_lats.length == 0) {
        lats = 0.0;
        longs = 0.0;
        address = "No Saved Location";
      } else {
        lats = double.parse(_lats[0]);
        longs = double.parse(_longs[0]);
        address = _address[0];
      }
    });
    List<Marker> markers = [];
    for (int i = 0; i < _lats.length; i++) {
      markers.add(Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(double.parse(_lats[i]), double.parse(_longs[i])),
        builder: (ctx) => Container(
          child: IconButton(
            icon: Icon(Icons.location_on),
            color: Colors.red,
            iconSize: 45.0,
            onPressed: () {
              print('Marker tapped');
            },
          ),
        ),
      ));
    }
    setState(() {
      _markers = markers;
    });
    debugPrint("markers: $_markers");
  }

  @override
  void initState() {
    // TODO: implement initState
    _toggleLoding();
    _getLocation();
    addMarkers();
    super.initState();
  }

  _toggleLoding() {
    setState(() {
      _loading = true;
    });
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Location'),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Column(
              children: [
                Flexible(
                  flex: 3,
                  child: FlutterMap(
                    options: MapOptions(
                      center: LatLng(lats, longs),
                      zoom: 9.2,
                    ),
                    nonRotatedChildren: [
                      AttributionWidget.defaultWidget(
                        source: 'OpenStreetMap contributors',
                        onSourceTapped: null,
                      ),
                    ],
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName:
                            'dev.fleaflet.flutter_map.example',
                      ),
                      MarkerLayer(
                        markers: _markers,
                      )
                    ],
                  ),
                )
              ],
            )),
    );
  }
}
