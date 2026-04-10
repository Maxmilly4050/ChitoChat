import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickImage});
  final void Function(File pickedImage) onPickImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;

  void pickImage() async{
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 150);
      if(image != null) {
        setState(() {
          _pickedImage = File(image.path);
        });
      }
      widget.onPickImage(_pickedImage!);
      return;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage: _pickedImage != null ? FileImage(_pickedImage!) : null,
        ),
        TextButton.icon(
          onPressed: pickImage,
          icon: const Icon(Icons.image),
          label: Text('Add Image', style: TextStyle(color: Theme.of(context).colorScheme.secondary) ,),
        ),
      ],
    );
  }
}