import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Tools
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as image_package;
import 'package:lise/main.dart';
import 'package:location/location.dart';


// Storage
import 'package:path_provider/path_provider.dart';



Map<int, Color> color = {
  50: Color.fromRGBO(0, 0, 0, .1),
  100: Color.fromRGBO(0, 0, 0, .2),
  200: Color.fromRGBO(0, 0, 0, .3),
  300: Color.fromRGBO(0, 0, 0, .4),
  400: Color.fromRGBO(0, 0, 0, .5),
  500: Color.fromRGBO(0, 0, 0, .6),
  600: Color.fromRGBO(0, 0, 0, .7),
  700: Color.fromRGBO(0, 0, 0, .8),
  800: Color.fromRGBO(0, 0, 0, .9),
  900: Color.fromRGBO(0, 0, 0, 1),
};
MaterialColor black = MaterialColor(0xFF000000, color);
MaterialColor white = MaterialColor(0xFFFFFFFF, color);

final _biggerFont = const TextStyle(
  fontSize: 18.0,
  color: Colors.black,
);
final _subFont = const TextStyle(
  color: Colors.black,
);
final _trailFont = const TextStyle(
  color: Colors.black,
);
final _listTitleStyle = const TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.bold
);
var _iconColor = black;


class UploadPicturesScreen extends StatefulWidget {
  UploadPicturesScreen({@required this.user});
  
  final FirebaseUser user;
  
  @override
  UploadPicturesScreenState createState() => UploadPicturesScreenState(user: user);
}

class UploadPicturesScreenState extends State<UploadPicturesScreen> {
  
  UploadPicturesScreenState({@required this.user});
  
  final FirebaseUser user;
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;
  
  
  String _profilePicImageLink1 = 'http://loading';
  String _profilePicImageLink2 = 'http://loading';
  String _profilePicImageLink3 = 'http://loading';
  String _profilePicImageLink4 = 'http://loading';
  String _profilePicImageLink5 = 'http://loading';
  
  StorageReference _storageReference1;
  StorageReference _storageReference2;
  StorageReference _storageReference3;
  StorageReference _storageReference4;
  StorageReference _storageReference5;
  
  bool pictureMissing1 = true;
  bool pictureMissing2 = true;
  bool pictureMissing3 = true;
  bool pictureMissing4 = true;
  bool pictureMissing5 = true;
  
  
  @override
  void initState() {
    super.initState();
    _loadUploadPictures();
    _scrollController = ScrollController();
  }
  
   void _loadUploadPictures() async {
      try {
        _storageReference1 = FirebaseStorage().ref().child('users/${user.uid}/profile_pictures/pic1.jpg');
        _profilePicImageLink1 = await _storageReference1.getDownloadURL();
        pictureMissing1 = false;
      }
      catch (e) {
        print (e);
      }
      try {
        _storageReference2 = FirebaseStorage().ref().child('users/${user.uid}/profile_pictures/pic2.jpg');
        _profilePicImageLink2 = await _storageReference2.getDownloadURL();
        pictureMissing2 = false;
      }
      catch (e) {
        print (e);
      }
      try {
        _storageReference3 = FirebaseStorage().ref().child('users/${user.uid}/profile_pictures/pic3.jpg');
        _profilePicImageLink3 = await _storageReference3.getDownloadURL();
        pictureMissing3 = false;
      }
      catch (e) {
        print (e);
      }
      try {
        _storageReference4 = FirebaseStorage().ref().child('users/${user.uid}/profile_pictures/pic4.jpg');
        _profilePicImageLink4 = await _storageReference4.getDownloadURL();
        pictureMissing4 = false;
      }
      catch (e) {
        print (e);
      }
      try {
        _storageReference5 = FirebaseStorage().ref().child('users/${user.uid}/profile_pictures/pic5.jpg');
        _profilePicImageLink5 = await _storageReference5.getDownloadURL();
        pictureMissing5 = false;
      }
      catch (e) {
        print (e);
      }

      setState(() {});
      return;
   }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('My Public Profile'),
        elevation: 4.0,
        /* actions: <Widget>[
          MaterialButton(
            child: Icon (
              Icons.flag,
              color: Colors.white,
            ),
            onPressed: () {
              // TODO report user
            },
          )
        ],*/
      ),
      body: ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
            begin: Alignment(0, 0.9),
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.transparent],
          ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
        },
        blendMode: BlendMode.dstIn,
        child: ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment(0, -0.9),
              end: Alignment.topCenter,
              colors: [Colors.white, Colors.transparent],
            ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
          },
          blendMode: BlendMode.dstIn,
          child: ListView(
            shrinkWrap: true,
            controller: _scrollController,
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              Divider(
                color: Colors.transparent
              ),
              Center(
                child:
                SizedBox(
                  width: 390,
                  height: 390,
                  child: RawMaterialButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    padding: EdgeInsets.all(4),
                    child: _imageOrPlaceHolder(pictureMissing1, _profilePicImageLink1),
                    onLongPress: () {},
                    onPressed: () {
                      getImageFromGallery(1);
                    },
                  )
                ),
              ),
              Center(
                child:
                SizedBox(
                  width: 350,
                  height: 350,
                  child: RawMaterialButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    padding: EdgeInsets.all(4),
                    child: _imageOrPlaceHolder(pictureMissing2, _profilePicImageLink2),
                    onLongPress: () {},
                    onPressed: () {
                      getImageFromGallery(2);
                    },
                  )
                ),
              ),
              Center(
                child:
                SizedBox(
                  width: 350,
                  height: 350,
                  child: RawMaterialButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    padding: EdgeInsets.all(4),
                    child: _imageOrPlaceHolder(pictureMissing3, _profilePicImageLink3),
                    onLongPress: () {},
                    onPressed: () {
                      getImageFromGallery(3);
                    },
                  )
                ),
              ),
              Center(
                child:
                SizedBox(
                  width: 350,
                  height: 350,
                  child: RawMaterialButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    padding: EdgeInsets.all(4),
                    child: _imageOrPlaceHolder(pictureMissing4, _profilePicImageLink4),
                    onLongPress: () {},
                    onPressed: () {
                      getImageFromGallery(4);
                    },
                  )
                ),
              ),
              Center(
                child:
                SizedBox(
                  width: 350,
                  height: 350,
                  child: RawMaterialButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    padding: EdgeInsets.all(4),
                    child: _imageOrPlaceHolder(pictureMissing5, _profilePicImageLink5),
                    onLongPress: () {},
                    onPressed: () {
                      getImageFromGallery(5);
                    },
                  )
                ),
              ),
              Divider(
                color: Colors.transparent
              ),
            ],
          )
        )
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        color: black,
        child: ListTile(
          trailing: Container(
              child: IconButton(
                iconSize: 45,
                icon: Text(
                  'NEXT',
                  style: TextStyle(
                    color: white,
                    fontSize: 14.0,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  )
                ),
                onPressed: () async {
                  if (!pictureMissing1 && !pictureMissing2 && !pictureMissing3 && !pictureMissing4 && !pictureMissing5) {
                    await _saveProfileCompletion();
                    await Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoadingPage()
                      )
                    );
                  }
                  else {
                    print('picture missing');
                  }
                },
              ),
            ),
        ),
      ),
    );
  }
  
  
  /// Gets image from gallery and uploads it to firebase storage.
  /// [pictureNumber] represent the number of the card of where the picture is at.
  Future getImageFromGallery(int pictureNumber) async {
    
    // Open gallery to select picture
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    
    // making sure a picture was selected from the gallery
    if (image == null) {
      return;
    }
    
    // Decoding Image before resizing
    var decodedImage = image_package.decodeImage(image.readAsBytesSync());
    
    
    // Making a copy of the copy and cropping and resizing
    var editedImage = image_package.copyResizeCropSquare(decodedImage, 850);
    
    var appDocDirectory = await getApplicationDocumentsDirectory();
    var croppedResizedImage = File('${appDocDirectory.path}/croppedResizedImage.jpg');
    croppedResizedImage.writeAsBytesSync(image_package.encodeJpg(editedImage));
    
    // Compressing the resized file
    var compressedCroppedResizedFile = await FlutterImageCompress.compressAndGetFile(
      '${appDocDirectory.path}/croppedResizedImage.jpg',
      '${appDocDirectory.path}/compressedCroppedResizedImage.jpg',
      quality: 35,
    );
    
    // Notifying user that the image is being uploaded through snackbar
    final snackBar = SnackBar(
      content: Text(
        'Uploading image',
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
    
    // Deciding where to upload the picture to
    StorageReference reference;
    switch (pictureNumber) {
      case 1: reference = _storageReference1;
      break;
      
      case 2: reference = _storageReference2;
      break;
      
      case 3: reference = _storageReference3;
      break;
      
      case 4: reference = _storageReference4;
      break;
      
      case 5: reference = _storageReference5;
      break;
    }
    
    // Uploading picture to the storage reference
    final uploadTask = reference.putFile(compressedCroppedResizedFile);
    
    // Wait until has been completely uploaded
    await uploadTask.onComplete;
    print('image uploaded');
    
    // Get the link to the picture we just uploaded
    var link = await reference.getDownloadURL();
    
    // Update the link in global variable
    switch (pictureNumber) {
      case 1: _profilePicImageLink1 = link;
              pictureMissing1 = false;
      break;
      
      case 2: _profilePicImageLink2 = link;
              pictureMissing2 = false;
      break;
      
      case 3: _profilePicImageLink3 = link;
              pictureMissing3 = false;
      break;
      
      case 4: _profilePicImageLink4 = link;
              pictureMissing4 = false;
      break;
      
      case 5: _profilePicImageLink5 = link;
              pictureMissing5 = false;
      break;
    }
    
    // Update the image widget
    setState(() {
      print('updating state');
      // Hide snackbar notification
      _scaffoldKey.currentState.hideCurrentSnackBar();
    });
  }
  
  
  Future<void> _saveProfileCompletion() async {
    var location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    // Checking is location is enabled in device
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();

      if (!serviceEnabled) {
        return false;
      }
    }

    // Checking if app has permission to get location
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();

      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }

    // Getting location form device.
    locationData = await location.getLocation();

    final snackBar = SnackBar(
      content: Text(
        'Completing Profile',
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);

    // Getting instance of the server function
    final callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'onProfileComplete',
    );

    // Adding variables to the server to the request and calling the function
    dynamic resp = await callable.call(<String, dynamic>{
      'latitude': locationData.latitude,
      'longitude': locationData.longitude,
    });

    print(resp.data['success']);

    _scaffoldKey.currentState.hideCurrentSnackBar();
    return (resp.data['success']);
  }
  
  
  Widget _imageOrPlaceHolder(bool pictureMissing, String profilePicImageLink) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.0),
        color: Colors.red
      ),
      padding: EdgeInsets.all(10),
      child: (pictureMissing)
      ? Center(
        child: FaIcon(
          FontAwesomeIcons.solidImage,
          color: white,
          size: 60,
        ),
      )
      : Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: Colors.transparent,
          image: DecorationImage(
            image: AdvancedNetworkImage(
              profilePicImageLink,
              useDiskCache: true,
            ),
            fit: BoxFit.cover,
          ),
        )
      )
    );
  }
  
}