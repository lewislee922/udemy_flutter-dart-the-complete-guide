import 'dart:io';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Place {
  Place(String? uid, this.title, this.image, this.location)
      : id = uid ?? _uuid.v4();

  final String id;
  final String title;
  final File image;
  final PlaceLocation location;

  toMap() => {
        'id': id,
        'title': title,
        'image': image.path,
        'lat': location.latitude,
        'lng': location.longitude,
        'address': location.address
      };

  factory Place.fromMap(Map<String, Object?> map) => Place(
        map['id']! as String,
        map['title']! as String,
        File(map['image']! as String),
        PlaceLocation(
            latitude: map['lat']! as double,
            longitude: map['lng']! as double,
            address: map['address']! as String),
      );
}

class PlaceLocation {
  final double latitude;
  final double longitude;
  final String address;

  PlaceLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  LatLng? toLatLng() => LatLng(latitude, longitude);
}
