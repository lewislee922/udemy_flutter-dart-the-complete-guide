import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../main_page.dart';
import '../../models/your_places_theme.dart';

class NewPlaceMap extends StatefulWidget {
  final LatLng? location;
  final bool readOnly;

  const NewPlaceMap({Key? key, required this.location, this.readOnly = false})
      : super(key: key);

  @override
  State<NewPlaceMap> createState() => _NewPlaceMapState();
}

class _NewPlaceMapState extends State<NewPlaceMap> {
  LatLng? _selectedPlace;

  @override
  void initState() {
    super.initState();
    _selectedPlace = widget.location;
  }

  @override
  Widget build(BuildContext context) {
    return MainNavigationBar(
      extendBodyBehindAppBar: false,
      appBarTitle:
          Text(widget.readOnly ? "Your location" : "Pick your location"),
      backgroundColor: YourPlacesTheme.colorScheme.primary,
      appBarLeading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back)),
      actions: widget.readOnly
          ? null
          : [
              IconButton(
                  onPressed: () =>
                      Navigator.of(context).pop<LatLng?>(_selectedPlace),
                  icon: const Icon(Icons.save))
            ],
      child: GoogleMap(
        onTap: widget.readOnly
            ? null
            : (argument) => setState(() => _selectedPlace = argument),
        markers: _selectedPlace != null
            ? {
                Marker(
                    markerId: const MarkerId('selected'),
                    position: _selectedPlace!)
              }
            : const <Marker>{},
        initialCameraPosition: CameraPosition(
            target: widget.location ?? const LatLng(25.105497, 121.597366),
            zoom: 14),
      ),
    );
  }
}
