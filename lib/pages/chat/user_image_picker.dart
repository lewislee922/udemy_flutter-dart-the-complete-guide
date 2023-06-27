import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final Function(XFile?)? onSelected;
  final ImageSource selectType;

  const UserImagePicker({Key? key, this.onSelected, required this.selectType})
      : super(key: key);

  @override
  State<UserImagePicker> createState() => _PlaceImageState();
}

class _PlaceImageState extends State<UserImagePicker> {
  XFile? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return _selectedImage == null
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
        : Column(
            children: [
              Center(
                  child: Container(
                clipBehavior: Clip.hardEdge,
                width: 100,
                height: 100,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Image.memory(
                  File(_selectedImage!.path).readAsBytesSync(),
                  fit: BoxFit.cover,
                ),
              )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton.icon(
                    onPressed: () async {
                      final image = await ImagePicker()
                          .pickImage(source: widget.selectType, maxWidth: 600);
                      widget.onSelected?.call(image);
                      setState(() {
                        _selectedImage = image;
                      });
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Change Picture')),
              )
            ],
          );
  }
}
