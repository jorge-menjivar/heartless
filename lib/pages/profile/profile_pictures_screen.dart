import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Tools
import 'package:lise/pages/profile/upload_images.dart';
import 'package:lise/widgets/loading_progress_indicator.dart';

// Storage
class ProfilePicturesScreen extends StatefulWidget {
  ProfilePicturesScreen({@required this.alias});

  final String alias;

  @override
  ProfilePicturesScreenState createState() => ProfilePicturesScreenState(alias: alias);
}

class ProfilePicturesScreenState extends State<ProfilePicturesScreen> {
  ProfilePicturesScreenState({
    @required this.alias,
  });

  final String alias;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('My Pictures'),
        ),
        body: UploadImagesPage(alias: alias, placeholder: loading_progress_indicator()));
  }
}
