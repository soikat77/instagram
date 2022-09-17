import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/models/user.dart';

class Upload extends StatefulWidget {
  final User? currentUser;
  const Upload({super.key, required this.currentUser});

  @override
  State<Upload> createState() => _UploadState();
  // _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File? file;
  Future handleTakePhoto() async {
    Navigator.pop(context);
    var file = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 675, maxWidth: 960);

    setState(() {
      this.file = File(file!.path);
    });
  }

  Future handleChooseImage() async {
    Navigator.pop(context);
    var file = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      this.file = File(file!.path);
    });
  }

  selectImage(parrentContext) {
    return showDialog(
        context: parrentContext,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Create a new post'),
            children: [
              SimpleDialogOption(
                onPressed: handleTakePhoto,
                child: const Text('Photo with Camera'),
              ),
              SimpleDialogOption(
                onPressed: handleChooseImage,
                child: const Text('Image from Gallery'),
              ),
              SimpleDialogOption(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/images/Image-upload.svg', height: 360.0),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: ElevatedButton(
              onPressed: () => selectImage(context),
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 18.0),
              ),
              child: const Text('Upload Image'),
            ),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: clearImage,
        ),
        title: const Text(
          'Caption Post',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => print('pressed'),
            child: const Text(
              'Post',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(file!),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18.0),
          ListTile(
            leading: widget.currentUser?.photoUrl == null
                ? CircleAvatar(
                    backgroundColor: Colors.purple[900],
                  )
                : CircleAvatar(
                    backgroundColor: Colors.purple[900],
                    backgroundImage: CachedNetworkImageProvider(
                        widget.currentUser!.photoUrl!),
                  ),
            title: const SizedBox(
              width: 250.0,
              child: TextField(
                // controller: captionController,
                decoration: const InputDecoration(
                  hintText: "Write a caption",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.purple[900],
              size: 35.0,
            ),
            title: const SizedBox(
              width: 250.0,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Where was this taken?",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: () => print('get user location'),
              icon: const Icon(Icons.my_location),
              label: const Text(
                'Use current location',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
