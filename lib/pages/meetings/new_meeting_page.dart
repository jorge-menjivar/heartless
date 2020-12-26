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
import 'package:google_maps_flutter_platform_interface/src/types/ui.dart';
import 'package:lise/utils/create_meeting.dart';
// Storage
import 'package:lise/widgets/cupertino_date_time_picker.dart';
import 'package:lise/widgets/loading_progress_indicator.dart';
import 'package:lise/widgets/switch.dart';
import 'package:location/location.dart';

import '../../app_variables.dart';

final _biggerFont = const TextStyle(
  fontSize: 18.0,
);

class NewMeetingScreen extends StatefulWidget {
  NewMeetingScreen({@required this.user});

  final FirebaseUser user;

  @override
  NewMeetingScreenState createState() => NewMeetingScreenState(user: user);
}

class NewMeetingScreenState extends State<NewMeetingScreen> {
  NewMeetingScreenState({@required this.user});

  final FirebaseUser user;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;

  DateTime _dateTime;
  bool _paying = false;
  String _placeName;
  String _placeAddress;
  double _longitude;
  double _latitude;
  String _photoRef;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // 2 hours from now
    final dateStart = DateTime.now().add(Duration(hours: 2));

    // 2 weeks from now
    final dateEnd = DateTime.now().add(Duration(days: 14));

    var readableTime;
    if (_dateTime != null) {
      if (_dateTime.hour == 0) {
        readableTime = '12:${_dateTime.minute.toString().padLeft(2, '0')}AM';
      } else if (_dateTime.hour == 12) {
        readableTime = '${_dateTime.hour}:${_dateTime.minute.toString().padLeft(2, '0')}PM';
      } else if (_dateTime.hour < 12) {
        readableTime = '${_dateTime.hour}:${_dateTime.minute.toString().padLeft(2, '0')}AM';
      } else {
        readableTime = '${_dateTime.hour - 12}:${_dateTime.minute.toString().padLeft(2, '0')}PM';
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
                image: (_photoRef != null)
                    ? CachedNetworkImageProvider('${attributes}photoreference=$_photoRef&key=${AppVariables.MAPS_KEY}')
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
            subtitle: Text((_placeName != null) ? '$_placeName\n$_placeAddress' : 'Select Place'),
            onTap: () async {
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

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlacePicker(
                    apiKey: AppVariables.MAPS_KEY,
                    initialPosition: LatLng(locationData.latitude, locationData.longitude),
                    useCurrentLocation: true,
                    usePlaceDetailSearch: true,
                    selectedPlaceWidgetBuilder: (babyContext, data, state, success) =>
                        _placeWidgetBuilder(babyContext, data, state),
                    initialMapType: MapType.normal,
                  ),
                ),
              );
            },
          ),
          Divider(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('Remember to check the respective open hours')],
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
              (_dateTime != null) ? _readableTimeString(_dateTime) : 'Select Date',
            ),
            onTap: () {
              Platform.isIOS
                  ? showCupertinoDateTimePicker(
                      context: context,
                      dateStart: DateTime(now.year, now.month, now.day),
                      dateEnd: dateEnd,
                      title: Text(
                        'Select date',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      initialDateTime: (_dateTime != null) ? _dateTime : DateTime.now().add(Duration(hours: 2)),
                      mode: CupertinoDatePickerMode.date,
                    ).then((v) async {
                      if (v != null) {
                        setState(() {
                          if (_dateTime != null) {
                            // Setting the date of _dateTime based of DateTime received
                            _dateTime = DateTime(
                              v.year,
                              v.month,
                              v.day,
                              _dateTime.hour,
                              _dateTime.minute,
                            );
                          } else {
                            _dateTime = v;
                          }
                        });
                      }
                    })
                  : showDatePicker(
                      helpText: 'SELECT DATE',
                      fieldLabelText: 'DATE',
                      initialEntryMode: DatePickerEntryMode.calendar,
                      initialDatePickerMode: DatePickerMode.day,
                      firstDate: DateTime(now.year, now.month, now.day),
                      initialDate: (_dateTime != null) ? _dateTime : DateTime.now().add(Duration(hours: 2)),
                      lastDate: dateEnd,
                      context: context,
                    ).then(
                      (v) async {
                        if (v != null) {
                          setState(() {
                            if (_dateTime != null) {
                              // Setting the date of _dateTime based of DateTime received
                              _dateTime = DateTime(
                                v.year,
                                v.month,
                                v.day,
                                _dateTime.hour,
                                _dateTime.minute,
                              );
                            } else {
                              _dateTime = v;
                            }
                          });
                        }
                      },
                    );
            },
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
              (_dateTime != null) ? readableTime : 'Select Time',
            ),
            onTap: () {
              Platform.isIOS
                  ? showCupertinoDateTimePicker(
                      context: context,
                      dateStart: DateTime.now(),
                      dateEnd: dateEnd,
                      title: Text(
                        'Select Time',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      initialDateTime: (_dateTime != null) ? _dateTime : DateTime.now().add(Duration(hours: 2)),
                      mode: CupertinoDatePickerMode.time,
                    ).then((v) async {
                      if (v != null) {
                        setState(() {
                          if (_dateTime != null) {
                            // Setting the date of _dateTime based of DateTime received
                            _dateTime = DateTime(
                              _dateTime.year,
                              _dateTime.month,
                              _dateTime.day,
                              v.hour,
                              v.minute,
                            );
                          } else {
                            _dateTime = DateTime(
                              now.year,
                              now.month,
                              now.day,
                              v.hour,
                              v.minute,
                            );
                          }
                        });
                      }
                    })
                  : showTimePicker(
                      helpText: 'SELECT TIME',
                      initialTime: (_dateTime != null)
                          ? TimeOfDay.fromDateTime(_dateTime)
                          : TimeOfDay.fromDateTime(DateTime.now().add(Duration(hours: 2))), // Converting to TimeOfDay
                      context: context,
                    ).then(
                      (v) async {
                        if (v != null) {
                          setState(() {
                            if (_dateTime != null) {
                              // Setting the date of _dateTime based of TimeOfDay received
                              _dateTime = DateTime(
                                _dateTime.year,
                                _dateTime.month,
                                _dateTime.day,
                                v.hour,
                                v.minute,
                              );
                            } else {
                              _dateTime = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                v.hour,
                                v.minute,
                              );
                            }
                          });
                        }
                      },
                    );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              FrinoIcons.f_cash__1_,
              color: IconTheme.of(context).color,
              size: IconTheme.of(context).size,
            ),
            title: Text(
              'I\'m paying for cost of date',
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            trailing: settingsSwitch(
              value: _paying,
              onChanged: (newValue) {
                setState(() {
                  _paying = newValue;
                });
              },
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
                'CREATE',
                style: TextStyle(color: Theme.of(context).canvasColor),
              ),
              onPressed: () async {
                if (_dateTime != null &&
                    _placeName != null &&
                    _placeAddress != null &&
                    _latitude != null &&
                    _longitude != null &&
                    _paying != null &&
                    _photoRef != null) {
                  await createMeeting(
                    context: context,
                    latitude: _latitude,
                    longitude: _longitude,
                    locName: _placeName,
                    dateTime: _dateTime.millisecondsSinceEpoch,
                    paying: _paying,
                    locAddress: _placeAddress,
                    photoRef: _photoRef,
                  );
                  Navigator.pop(context);
                } else {
                  print('not complete');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeWidgetBuilder(BuildContext context, PickResult data, SearchingState state) {
    return FloatingCard(
      bottomPosition: MediaQuery.of(context).size.height * 0.05,
      leftPosition: MediaQuery.of(context).size.width * 0.025,
      rightPosition: MediaQuery.of(context).size.width * 0.025,
      width: MediaQuery.of(context).size.width * 0.9,
      borderRadius: BorderRadius.circular(12.0),
      elevation: 4.0,
      color: Theme.of(context).cardColor,
      child: state == SearchingState.Searching ? loading_progress_indicator() : _buildSelectionDetails(context, data),
    );
  }

  Widget _buildSelectionDetails(BuildContext context, PickResult result) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Text(
            (result.name != null) ? '${result.name}\n${result.formattedAddress}' : result.formattedAddress,
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          CupertinoButton.filled(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text("Select here",
                style: TextStyle(
                  color: Colors.white,
                )),
            onPressed: () {
              setState(() {
                _placeName = result.name;
                _placeAddress = result.formattedAddress;
                _longitude = result.geometry.location.lng;
                _latitude = result.geometry.location.lat;
                _photoRef = result.photos[0].photoReference;
              });
              Navigator.of(context).pop();
            },
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
