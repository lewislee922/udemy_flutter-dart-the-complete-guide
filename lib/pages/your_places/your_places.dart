import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/main_page.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/models/your_places_theme.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/provider.dart';

class YourPlace extends ConsumerWidget {
  const YourPlace({super.key});

  static Page page() => const MaterialPage(
      key: ValueKey('yourplaces'), name: 'yourplaces', child: YourPlace());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainNavigationBar(
      backgroundColor: YourPlacesTheme.colorScheme.background,
      extendBodyBehindAppBar: false,
      appBarTitle: Text('Your Places',
          style: YourPlacesTheme.theme.textTheme.titleLarge),
      actions: [
        IconButton(
            onPressed: () => ref.read(appState).changeNewPlaceVisiblity(),
            icon: const Icon(Icons.add))
      ],
      child: FutureBuilder(
          future: ref.watch(yourPlaceLocalService).getAll(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data!;
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () => ref.read(appState).selectPlace(data[index]),
                      key: ValueKey(data[index].id),
                      leading: Container(
                        width: 30,
                        height: 30,
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: Image.file(data[index].image),
                      ),
                      title: Text(
                        data[index].title,
                        style: YourPlacesTheme.theme.textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        data[index].location.address,
                        style: YourPlacesTheme.theme.textTheme.titleSmall,
                      ),
                    );
                  });
            }
            return const Center(
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(),
              ),
            );
            // return Center(
            //     child: Text("No Places",
            //         style: YourPlacesTheme.theme.textTheme.titleMedium),
            //   );
          }),
    );
  }
}
