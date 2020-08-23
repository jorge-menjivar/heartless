import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Tools

import 'package:lise/main.dart';
import 'package:lise/pages/upload_images.dart';
import 'package:location/location.dart';

class UploadPicturesScreen extends StatefulWidget {
  UploadPicturesScreen({@required this.user, @required this.alias});

  final FirebaseUser user;
  final String alias;

  @override
  UploadPicturesScreenState createState() => UploadPicturesScreenState(user: user, alias: alias);
}

class UploadPicturesScreenState extends State<UploadPicturesScreen> {
  UploadPicturesScreenState({@required this.user, @required this.alias});

  final FirebaseUser user;
  final String alias;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Pictures'),
        elevation: 4.0,
      ),
      body: UploadImagesPage(
        alias: alias,
        placeholder: Center(
          child: FaIcon(
            FontAwesomeIcons.solidImage,
            color: (Theme.of(context).brightness == Brightness.light) ? Colors.black : Colors.white70,
            size: 60,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        color: (Theme.of(context).brightness == Brightness.light) ? Colors.black : Colors.black,
        child: ListTile(
          leading: Container(
            child: IconButton(
              iconSize: 45,
              icon: Text('BACK',
                  style: TextStyle(
                    color: white,
                    fontSize: 14.0,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  )),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
          ),
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
                ),
              ),
              onPressed: () async {
                if (true) {
                  await _saveProfileCompletion();
                  await Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoadingPage()),
                    (route) => false,
                  );
                } else {
                  print('picture missing');
                }
              },
            ),
          ),
        ),
      ),
    );
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

    // Getting instance of the server function
    final callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'onProfileComplete',
    );

    // Adding variables to the server to the request and calling the function
    await callable.call(<String, dynamic>{
      'latitude': locationData.latitude,
      'longitude': locationData.longitude,
    });

    return;
  }
}
