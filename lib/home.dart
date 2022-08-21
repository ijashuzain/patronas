import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:petronas/models/gas_station.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List<GasStation> gasStations = [];
  TextEditingController _keywordController = TextEditingController();

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  _searchPlaces(loc.LocationData location,String keyword) async {
    var response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${location.latitude},${location.longitude}&name=$keyword&radius=5000&types=gas_station&rankBy=distance&sensor=true&key=AIzaSyAEOZDJ65B0F4Yl1jhrr_sMuf6phS0-1z8"),
    );
    gasStations = [];
    List results = jsonDecode(response.body)['results'];
    results.forEach((element) {
      GasStation gasStation = GasStation.fromJson(element);
      gasStations.add(gasStation);
    });

    log(gasStations.toString());
  }

  Future<loc.LocationData?> getLocation() async {
    loc.Location _location = loc.Location();
    try {
      final loc.LocationData location = await _location.getLocation();
      _kGooglePlex = CameraPosition(
          target: LatLng(location.latitude!, location.longitude!), zoom: 14);
      setState(() {});
      return location;
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  _refresh() async {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      var currentLocation = await getLocation();
      if (currentLocation != null) {
        await _searchPlaces(currentLocation,_keywordController.text);
      }
    });
  }

  @override
  void initState() {
    _keywordController.text = "Patronas";
    _refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Petronas Locations"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _refresh();
        },
        child: const Icon(Icons.refresh),
      ),
      body: SizedBox(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _keywordController,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GoogleMap(
                  initialCameraPosition: _kGooglePlex,
                  myLocationEnabled: true,
                  onMapCreated: (controller){
                    controller.animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex));
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  child: ListView.builder(
                    itemCount: gasStations.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Image.network(gasStations[index].icon!),
                        ),
                        title: Text(gasStations[index].name!),
                        subtitle: Text(gasStations[index].businessStatus!),
                      );
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
