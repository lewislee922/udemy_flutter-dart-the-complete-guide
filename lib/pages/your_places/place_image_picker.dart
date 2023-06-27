import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/your_places_theme.dart';

class PlaceImagePicker extends StatefulWidget {
  final Function(XFile?)? onSelected;
  final ImageSource selectType;

  const PlaceImagePicker({Key? key, this.onSelected, required this.selectType})
      : super(key: key);

  @override
  State<PlaceImagePicker> createState() => _PlaceImageState();
}

class _PlaceImageState extends State<PlaceImagePicker> {
  XFile? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      height: MediaQuery.of(context).size.height / 3,
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
              color: YourPlacesTheme.colorScheme.primary.withOpacity(0.2))),
      child: _selectedImage == null
          ? TextButton.icon(
              onPressed: () async {
                final image = await ImagePicker()
                    .pickImage(source: widget.selectType, maxWidth: 600);
                widget.onSelected?.call(image);
                setState(() {
                  _selectedImage = image;
                });
              },
              icon: const Icon(Icons.camera),
              label: const Text('Take Picture'))
          : Stack(
              children: [
                Center(
                    child: Image.memory(
                        File(_selectedImage!.path).readAsBytesSync())),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    alignment: Alignment.bottomRight,
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton.icon(
                          onPressed: () async {
                            final image = await ImagePicker().pickImage(
                                source: widget.selectType, maxWidth: 600);
                            widget.onSelected?.call(image);
                            setState(() {
                              _selectedImage = image;
                            });
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Change Picture')),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
