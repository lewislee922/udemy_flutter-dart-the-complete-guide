import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/your_places_theme.dart';

class MapMarkerPreview extends ConsumerWidget {
  final String? imgLink;

  const MapMarkerPreview({Key? key, this.imgLink}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        clipBehavior: Clip.hardEdge,
        height: MediaQuery.of(context).size.height / 5,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
                color: YourPlacesTheme.colorScheme.primary.withOpacity(0.2))),
        child: SizedBox.expand(
          child: imgLink != null
              ? Image.network(
                  imgLink!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress != null) {
                      return const CircularProgressIndicator();
                    }
                    return child;
                  },
                )
              : Align(
                  alignment: Alignment.center,
                  child: Text("No location chosen",
                      style: YourPlacesTheme.theme.textTheme.titleMedium!
                          .copyWith(
                              color: Theme.of(context).colorScheme.primary)),
                ),
        ));
  }
}
