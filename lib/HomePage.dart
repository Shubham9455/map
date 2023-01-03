// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart';
// import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter/services.dart';




class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var longitude = 82.9847398;
  var latitude = 25.2639147;
  var _search = '';
  var address = "";
  bool _loading = true;
  @override
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
      latitude = position.latitude;
      longitude = position.longitude;
      address = first.addressLine;
    });
  }

  _getLocationBysearch(String s){
    Geolocator().placemarkFromAddress(s).then((value) => {
      setState(() {
        latitude = value[0].position.latitude;
        longitude = value[0].position.longitude;
        address = value[0].name;
      })
    });
  }
  @override
  _toggleLoding(){
    setState(() {
      _loading = true;
    });
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _loading = false;
      });
    });
  }

  void initState() {
    // TODO: implement initState
    
  
    _toggleLoding();
    _getLocation();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[50],
      appBar: AppBar(
        title: const Text("MAPS"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _toggleLoding();
          _getLocation();
        },
        child: const Icon(Icons.location_searching),
      ),
      body: _loading?
      Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      )
      :Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(15),
            child: Center(
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  labelText: 'Search',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      if(_search!=null && _search!=""){
                        _toggleLoding();
                        debugPrint("search: $_search");
                        _getLocationBysearch(_search);
                      }
                    },
                  ),
                ),

                onChanged: (value) => setState(() {
                  _search = value;
                }),
                onEditingComplete: () => {
                  if(_search!=null && _search!=""){_toggleLoding(),
                  debugPrint("search: $_search"),
                  _getLocationBysearch(_search),}
                },
                
              ),
          ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Center(
              child: Text(
                address,
                style: const TextStyle(fontSize: 15,fontFamily: 'Roboto'),
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: Center(
                child: FlutterMap(
              options: MapOptions(
                center: LatLng( latitude,longitude),
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
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                ),
                
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 50.0,
                      height: 50.0,
                      point: LatLng(latitude, longitude),
                      builder: (ctx) => Container(
                        child: const Icon(Icons.location_on, size: 50, color: Colors.red,)
                      ),
                    ),
                  ],
                )
              ],
            )),
          ),
        ],
      ),
    );
  }
}
