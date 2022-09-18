import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/models/user.dart';
import 'package:instagram/pages/home_page.dart';
import 'package:instagram/widgets/progress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User? currentUser;
  const Upload({super.key, required this.currentUser});

  @override
  State<Upload> createState() => _UploadState();
  // _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  bool isUploading = false;
  String postId = const Uuid().v4();
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

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image? imageFile = Im.decodeImage(file!.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytes(
        Im.encodeJpg(imageFile!, quality: 85),
      );
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);

    String downloadImageUrl = await uploadTask.then((res) {
      return res.ref.getDownloadURL();
    });
    return downloadImageUrl;
  }

  createPostInFirestore(
      {required String mediaUrl,
      required String location,
      required String description}) {
    postRef.doc(widget.currentUser!.id).collection("userPost").doc(postId).set({
      "postId": postId,
      "ownerID": widget.currentUser!.id,
      "userName": widget.currentUser!.userName,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timastamp": timestamp,
      "likes": {},
    });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = const Uuid().v4();
    });
  }

/* ------------------------------- Upload Form ------------------------------ */
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
            onPressed: isUploading ? null : () => handleSubmit(),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
              padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0)),
            ),
            child: const Center(
              child: Text(
                'Post',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          isUploading ? linearProgress() : const Text(''),
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
            title: SizedBox(
              width: 250.0,
              child: TextField(
                controller: captionController,
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
            title: SizedBox(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  hintText: "Where was this taken?",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: getUserLocation,
            icon: const Icon(Icons.my_location),
            label: const Text(
              'Use current location',
              style: TextStyle(color: Colors.deepPurple),
            ),
          ),
        ],
      ),
    );
  }

  getUserLocation() async {
    await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        forceAndroidLocationManager: true,
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    // String completeAddress =
    //     '${placemark.subThoroughfare}, ${placemark.thoroughfare}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.administrativeArea}, ${placemark.street}, ${placemark.postalCode}, ${placemark.country}';
    // print(completeAddress);
    String formateAddress = "${placemark.locality}, ${placemark.country}";
    // print(formateAddress);
    locationController.text = formateAddress;
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
