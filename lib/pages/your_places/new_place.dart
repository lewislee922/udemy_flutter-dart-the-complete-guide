import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/models/place.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/pages/your_places/map_marker_preview.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/pages/your_places/new_place_map.dart';

import '../../main_page.dart';
import '../../provider.dart';
import '../../models/your_places_theme.dart';
import '../../pages/your_places/place_image_picker.dart';
import '../../widgets/shared/simple_error_dialog.dart';

class NewPlace extends ConsumerStatefulWidget {
  const NewPlace({super.key});

  static Page page() => const MaterialPage(
      key: ValueKey('newplace'), name: 'newplace', child: NewPlace());

  @override
  NewPlaceState createState() => NewPlaceState();
}

class NewPlaceState extends ConsumerState<NewPlace> {
  late LatLng? _selectedPlace;
  late File? _selectedImage;
  late TextEditingController _controller;

  Future<LocationData> _getUserLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw UnsupportedError(
            "Location Service not enabled or avaliable, please check your device settings");
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw UnsupportedError(
            "Application need your permission to get location, please enable in settings");
      }
    }

    locationData = await location.getLocation();
    return locationData;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _selectedPlace = null;
    _selectedImage = null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainNavigationBar(
        backgroundColor: YourPlacesTheme.colorScheme.background,
        extendBodyBehindAppBar: false,
        appBarLeading: IconButton(
            onPressed: () => ref.read(appState).changeNewPlaceVisiblity(),
            icon: const Icon(Icons.arrow_back)),
        appBarTitle: Text('Add new Place',
            style: YourPlacesTheme.theme.textTheme.titleLarge),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(label: Text("Title")),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: PlaceImagePicker(
                    selectType: Platform.isIOS || Platform.isAndroid
                        ? ImageSource.camera
                        : ImageSource.gallery,
                    onSelected: (p0) {
                      if (p0 != null) {
                        _selectedImage = File(p0.path);
                      } else {
                        _selectedImage = null;
                      }
                    },
                  ),
                ),
                MapMarkerPreview(
                    imgLink: _selectedPlace != null
                        ? 'https://maps.googleapis.com/maps/api/staticmap?center=${_selectedPlace!.latitude}, ${_selectedPlace!.longitude}&markers=${_selectedPlace!.latitude}, ${_selectedPlace!.longitude}&zoom=15&size=400x400&key=${dotenv.get("MAPAPI")}'
                        : null),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                          onPressed: () async {
                            try {
                              final location = await _getUserLocation();
                              if (location.latitude != null &&
                                  location.longitude != null) {
                                _selectedPlace = LatLng(
                                    location.latitude!, location.longitude!);
                              } else {
                                _selectedPlace = null;
                              }
                              setState(() => _selectedPlace);
                            } on UnsupportedError catch (e) {
                              showDialog(
                                  context: context,
                                  builder: (context) => SimpleErrorDialog(
                                      message: e.message ?? "",
                                      title: "Location service Error"));
                            }
                          },
                          icon: const Icon(Icons.location_pin),
                          label: const Text("Get location")),
                      SizedBox(
                          width:
                              (Platform.isIOS || Platform.isAndroid) ? 16 : 0),
                      Platform.isIOS || Platform.isAndroid
                          ? TextButton.icon(
                              onPressed: () async {
                                try {
                                  if (_selectedPlace == null) {
                                    _getUserLocation().then((value) async {
                                      final location = value;
                                      final result = await Navigator.of(context)
                                          .push<LatLng?>(MaterialPageRoute(
                                              builder: (context) => NewPlaceMap(
                                                  location: LatLng(
                                                      location.latitude!,
                                                      location.longitude!))));
                                      _selectedPlace = result;
                                      setState(() => _selectedPlace);
                                    });
                                  } else {
                                    final result = await Navigator.of(context)
                                        .push<LatLng?>(MaterialPageRoute(
                                            builder: (context) => NewPlaceMap(
                                                location: LatLng(
                                                    _selectedPlace!.latitude,
                                                    _selectedPlace!
                                                        .longitude))));
                                    _selectedPlace = result;
                                    setState(() => _selectedPlace);
                                  }
                                } on UnsupportedError {}
                              },
                              icon: const Icon(Icons.map),
                              label: const Text("Select on map"),
                            )
                          : const SizedBox()
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (_selectedPlace != null &&
                        _selectedImage != null &&
                        _controller.text != "") {
                      final client = Dio();
                      String address = "";
                      try {
                        final response = await client.get(
                            "https://maps.googleapis.com/maps/api/geocode/json",
                            queryParameters: {
                              "latlng":
                                  "${_selectedPlace!.latitude},${_selectedPlace!.longitude}",
                              "result_type": "street_address",
                              "location_type": "ROOFTOP",
                              "key": dotenv.get("MAPAPI")
                            });

                        if (response.statusCode == 200) {
                          final data = response.data;
                          address = data['results'][0]['formatted_address'];
                        }
                      } on DioException {}
                      final directory = await getApplicationSupportDirectory();
                      final newFile = File(p.join(
                          directory.path, p.basename(_selectedImage!.path)));
                      newFile
                          .writeAsBytesSync(_selectedImage!.readAsBytesSync());
                      ref.read(yourPlaceLocalService).add(Place(
                          null,
                          _controller.text,
                          newFile,
                          PlaceLocation(
                              latitude: _selectedPlace!.latitude,
                              longitude: _selectedPlace!.longitude,
                              address: address)));
                      ref.read(appState).changeNewPlaceVisiblity();
                    }
                  },
                  label: const Text("Add Place"),
                  icon: const Icon(Icons.add),
                )
              ],
            ),
          ),
        ));
  }
}
