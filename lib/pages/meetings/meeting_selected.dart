import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:frino_icons/frino_icons.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:lise/utils/create_meeting.dart';
// Storage
import 'package:lise/widgets/cupertino_date_time_picker.dart';
import 'package:lise/widgets/switch.dart';
import 'package:location/location.dart';

import '../../app_variables.dart';

final _biggerFont = const TextStyle(
  fontSize: 18.0,
);

class MeetingSelectedScreen extends StatefulWidget {
  final FirebaseUser user;

  final int dateEpoch;
  final bool paying;
  final String placeName;
  final String placeAddress;
  final double longitude;
  final double latitude;
  final String photoRef;

  MeetingSelectedScreen({
    @required this.user,
    @required this.dateEpoch,
    @required this.paying,
    @required this.placeName,
    @required this.placeAddress,
    @required this.longitude,
    @required this.latitude,
    @required this.photoRef,
  });

  @override
  MeetingSelectedScreenState createState() => MeetingSelectedScreenState(
        user: user,
        dateEpoch: dateEpoch,
        paying: paying,
        placeName: placeName,
        placeAddress: placeAddress,
        latitude: latitude,
        longitude: longitude,
        photoRef: photoRef,
      );
}

class MeetingSelectedScreenState extends State<MeetingSelectedScreen> {
  final FirebaseUser user;

  final int dateEpoch;
  final bool paying;
  final String placeName;
  final String placeAddress;
  final double longitude;
  final double latitude;
  final String photoRef;

  MeetingSelectedScreenState({
    @required this.user,
    @required this.dateEpoch,
    @required this.paying,
    @required this.placeName,
    @required this.placeAddress,
    @required this.longitude,
    @required this.latitude,
    @required this.photoRef,
  });
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final dateTime = DateTime.fromMillisecondsSinceEpoch(dateEpoch);

    // 2 hours from now
    final dateStart = DateTime.now().add(Duration(hours: 2));

    // 2 weeks from now
    final dateEnd = DateTime.now().add(Duration(days: 14));

    var readableTime;
    if (dateTime != null) {
      if (dateTime.hour == 0) {
        readableTime = '12:${dateTime.minute.toString().padLeft(2, '0')}AM';
      } else if (dateTime.hour == 12) {
        readableTime = '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}PM';
      } else if (dateTime.hour < 12) {
        readableTime = '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}AM';
      } else {
        readableTime = '${dateTime.hour - 12}:${dateTime.minute.toString().padLeft(2, '0')}PM';
      }
    }

    var attributes = 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&';

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Create New Meeting'),
      ),
      body: ListView(
        shrinkWrap: true,
        primary: false,
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Container(
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: (photoRef != null)
                    ? CachedNetworkImageProvider('${attributes}photoreference=$photoRef&key=${AppVariables.MAPS_KEY}')
                    : CachedNetworkImageProvider(
                        'https://pbs.twimg.com/profile_images/1305883698471018496/_4BfrCaP.jpg'),
              ),
            ),
          ),
          Divider(color: Colors.transparent),
          ListTile(
            isThreeLine: true,
            leading: Icon(
              FrinoIcons.f_map,
              color: IconTheme.of(context).color,
              size: IconTheme.of(context).size,
            ),
            title: Text(
              'Place',
              style: _biggerFont,
            ),
            subtitle: Text((placeName != null) ? '$placeName\n$placeAddress' : 'Select Place'),
          ),
          ListTile(
            leading: Icon(
              FrinoIcons.f_calendar,
              color: IconTheme.of(context).color,
              size: IconTheme.of(context).size,
            ),
            title: Row(
              children: <Widget>[
                Text(
                  'Date',
                  style: _biggerFont,
                ),
              ],
            ),
            subtitle: Text(
              (dateTime != null) ? _readableTimeString(dateTime) : 'Select Date',
            ),
          ),
          ListTile(
            leading: Icon(
              FrinoIcons.f_clock,
              color: IconTheme.of(context).color,
              size: IconTheme.of(context).size,
            ),
            title: Row(
              children: <Widget>[
                Text(
                  'Time',
                  style: _biggerFont,
                ),
              ],
            ),
            subtitle: Text(
              (dateTime != null) ? readableTime : 'Select Time',
            ),
          ),
          Divider(),
          Divider(
            color: Colors.transparent,
            height: 60,
          ),
          Center(
            child: CupertinoButton(
              color: Theme.of(context).accentColor,
              child: Text(
                'MEET',
                style: TextStyle(color: Theme.of(context).canvasColor),
              ),
              onPressed: () async {},
            ),
          ),
        ],
      ),
    );
  }

  String _readableTimeString(DateTime dateTime) {
    var month = dateTime.month;
    var day = dateTime.day;
    var year = dateTime.year;
    return '${month}/${day}/${year}';
  }
}
