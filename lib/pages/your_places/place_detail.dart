import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/pages/your_places/new_place_map.dart';

import '../../main_page.dart';
import '../../models/place.dart';
import '../../models/your_places_theme.dart';
import '../../provider.dart';

class PlaceDetail extends ConsumerWidget {
  final Place place;

  const PlaceDetail({super.key, required this.place});

  static Page page(Place place) => MaterialPage(
      key: const ValueKey('placedetail'),
      name: 'placedetail',
      child: PlaceDetail(place: place));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainNavigationBar(
        backgroundColor: YourPlacesTheme.colorScheme.background,
        extendBodyBehindAppBar: false,
        appBarLeading: IconButton(
            onPressed: () => ref.read(appState).selectPlace(null),
            icon: const Icon(Icons.arrow_back)),
        appBarTitle: Text(place.title,
            style: YourPlacesTheme.theme.textTheme.titleLarge),
        child: Stack(
          children: [
            SizedBox.expand(
                child: Image.file(
              place.image,
              fit: BoxFit.cover,
            )),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      clipBehavior: Clip.hardEdge,
                      width: MediaQuery.of(context).size.width / 3,
                      height: MediaQuery.of(context).size.width / 3,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => NewPlaceMap(
                                    location: place.location.toLatLng(),
                                    readOnly: true))),
                        child: Image.network(
                          'https://maps.googleapis.com/maps/api/staticmap?center=${place.location.latitude},${place.location.longitude}&markers=${place.location.latitude},${place.location.longitude}&zoom=15&size=400x400&key=${dotenv.get("MAPAPI")}',
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress != null) {
                              return const CircularProgressIndicator();
                            }
                            return child;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Text(place.location.address,
                        textAlign: TextAlign.center,
                        style: YourPlacesTheme.theme.textTheme.titleMedium!)
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
