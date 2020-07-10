import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lise/convo_completion/select_matches_screen.dart';
import 'package:lise/messages/m_p_matches_screen.dart';
import 'package:location/location.dart';

import '../localizations.dart';

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

class PotentialMatchesScreen extends StatefulWidget {
  PotentialMatchesScreen({Key key, @required this.scaffoldKey, @required this.user}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;
  final FirebaseUser user;

  @override
  _PotentialMatchesScreenState createState() =>
      _PotentialMatchesScreenState(scaffoldKey: this.scaffoldKey, user: this.user);
}

class _PotentialMatchesScreenState extends State<PotentialMatchesScreen> with AutomaticKeepAliveClientMixin {
  _PotentialMatchesScreenState({@required this.scaffoldKey, @required this.user});

  final scaffoldKey;
  final user;

  ScrollController _scrollController;

  var _pMatches = [];

  var pMatchesInitialized = false;

  final _pMatchLastMessages = [];

  final _listTitleStyle = const TextStyle(color: Colors.black, fontWeight: FontWeight.bold);
  final _biggerFont = const TextStyle(fontSize: 18.0, color: Colors.black);
  final _subFont = const TextStyle(color: Colors.black);
  final _trailFont = const TextStyle(color: Colors.black);

  var variablesInitialized = false;
  String _alias;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _downloadData();
    _scrollController = ScrollController();
  }

  Future<void> _downloadData() async {
    // Downloading data and synchronizing it with public variables

    if (!pMatchesInitialized) {
      Firestore.instance
          .collection('users')
          .document('${user.uid}')
          .collection('data_generated')
          .document('user_rooms')
          .collection('p_matches')
          .snapshots()
          .listen(
        (querySnapshot) {
          _pMatches = querySnapshot.documents;
          _loadPMatchesData();
        },
      );

      pMatchesInitialized = true;
    }
  }

  void _loadPMatchesData() async {
    if (_pMatchLastMessages.isNotEmpty) {
      _pMatchLastMessages.clear();
    }

    for (var match in _pMatches) {
      try {
        // Getting the last message sent in each conversation
        var lastMessage = await Firestore.instance
            .collection('messages')
            .document('rooms')
            .collection('${match['room']}')
            .where('time', isGreaterThanOrEqualTo: 0)
            .orderBy('time', descending: true)
            .limit(1)
            .getDocuments();

        _pMatchLastMessages.add(lastMessage.documents[0]);
      } catch (e) {
        print(e);
      }
    }

    if (!variablesInitialized) {
      await Firestore.instance
          .collection('users')
          .document('${user.uid}')
          .collection('data')
          .document('private')
          .get()
          .then(
        (doc) {
          if (!doc.exists) {
            print('No data document!');
          } else {
            _alias = doc.data['alias'];
          }
        },
      );
      variablesInitialized = true;
    }

    if (mounted) {
      setState(() {});
    }

    return;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: const EdgeInsets.all(1),
      controller: _scrollController,
      itemCount: _pMatches.length + 2,
      itemBuilder: (context, i) {
        if (i == 0) {
          return ListTile(
            leading: Text(
              AppLocalizations.of(context).translate('POTENTIAL_MATCHES'),
              textAlign: TextAlign.left,
              style: _listTitleStyle,
            ),
          );
        }

        if (i == _pMatches.length + 1) {
          return ListTile(
            title: Text(
              AppLocalizations.of(context).translate('Find_someone_new'),
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            trailing: FaIcon(
              FontAwesomeIcons.userPlus,
              color: black,
            ),
            onTap: _sendPotentialMatchRequest,
          );
        }

        final pMatch = _pMatches[i - 1];
        var lastMessage;
        var time;

        if (pMatch['pending'] == true) {
          return ListTile(
            title: Text(
              AppLocalizations.of(context).translate('Searching_the_world_title'),
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            subtitle: Text(
              AppLocalizations.of(context).translate('Searching_the_world_subtitle'),
              style: _subFont,
              textAlign: TextAlign.left,
              maxLines: 1,
            ),
            trailing: FaIcon(
              FontAwesomeIcons.clock,
              color: black,
            ),
            onTap: () {},
            onLongPress: () {
              setState(() {
                showDeleteDialog(context, 'Request').then((v) {
                  if (v) {
                    _deleteRequest(pMatch.documentID);
                  }
                });
              });
            },
          );
        } else {
          if (_pMatchLastMessages.isNotEmpty && _pMatchLastMessages[i - 1]['time'] != null) {
            time = _pMatchLastMessages[i - 1]['time'];
          }
          if (_pMatchLastMessages.isNotEmpty && _pMatchLastMessages[i - 1]['time'] != null && time > 0) {
            if (_pMatchLastMessages[i - 1]['from'] == user.uid) {
              lastMessage = 'You: ${_pMatchLastMessages[i - 1]['message']}';
            } else {
              lastMessage = _pMatchLastMessages[i - 1]['message'];
            }
          } else {
            lastMessage = AppLocalizations.of(context).translate('Start_Conversation');
          }
          return ListTile(
            leading: CircleAvatar(child: Text(pMatch['otherUser'].toUpperCase()[0])),
            title: Text(
              pMatch['otherUser'],
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            subtitle: Text(
              lastMessage,
              style: _subFont,
              textAlign: TextAlign.left,
            ),
            trailing: Text(
              convertPMatchTime(int.parse(pMatch.documentID), pMatch.documentID),
              style: _trailFont,
              textAlign: TextAlign.left,
            ),
            onTap: () {
              // If the conversation is not finished go to chat, otherwise go to select connections screen
              (convertPMatchTime(int.parse(pMatch.documentID), pMatch.documentID) !=
                      AppLocalizations.of(context).translate('COMPLETED'))
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PMConversationScreen(
                          alias: _alias,
                          matchName: pMatch['otherUser'],
                          username: user.displayName,
                          room: pMatch['room'],
                        ),
                      ),
                    ).then((value) {
                      _loadPMatchesData();
                    })
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectMatchesScreen(
                          user: user,
                          room: pMatch['room'],
                          roomKey: pMatch.documentID,
                        ),
                      ),
                    );
            },
            onLongPress: () {
              setState(() {
                showDeleteDialog(context, pMatch['otherUser']).then((v) {
                  if (v) {
                    _deletePotentialMatch(int.parse(pMatch.documentID), pMatch['room']);
                  }
                });
              });
            },
          );
        }
      },
    );
  }

  /// Updates the location of the device to the database and sends a request for a potential match.
  Future<bool> _sendPotentialMatchRequest() async {
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
        //TODO
        'Sending Request',
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);

    // Getting instance of the server function
    final callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getPotentialMatch',
    );

    // Adding variables to the server to the request and calling the function
    dynamic resp = await callable.call(
      <String, dynamic>{
        'latitude': locationData.latitude,
        'longitude': locationData.longitude,
      },
    );

    print(resp.data['success']);

    scaffoldKey.currentState.hideCurrentSnackBar();
    return (resp.data['success']);
  }

  /// Shows the an alert asking the user if delete should really be done
  Future<bool> showDeleteDialog(BuildContext context, String name) async {
    var choice = false;

    // Await for the dialog to be dismissed before returning
    (Platform.isAndroid)
        ? await showDialog<bool>(
            context: context,
            barrierDismissible: true, // user can type outside box to dismiss
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Are you sure?'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Do you really want to delete the conversation with $name?'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text("I\'m sure"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      choice = true;
                    },
                  ),
                ],
              );
            },
          )
        : await showCupertinoDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text('Are you sure?'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Do you really want to delete the conversation with $name?'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text("I\'m sure"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      choice = true;
                    },
                  ),
                ],
              );
            },
          );
    return choice;
  }

  Future<void> _deletePotentialMatch(int time, String room) async {
    final snackBar = SnackBar(
      content: Text(
        //TODO
        'Deleting Potential Match',
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
    // Getting instance of the server function
    final callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'deletePotentialMatch',
    );

    // Adding variables to the server to the request and calling the function
    await callable.call(<String, dynamic>{
      'time': time,
      'room': room,
    });

    scaffoldKey.currentState.hideCurrentSnackBar();
    return;
  }

  Future<void> _deleteRequest(String key) async {
    final snackBar = SnackBar(
      content: Text(
        //TODO
        'Deleting Request',
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);

    // Getting instance of the server function
    final callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'deleteRequest',
    );

    // Adding variables to the server to the request and calling the function
    await callable.call(
      <String, dynamic>{
        'requestKey': key,
      },
    );

    scaffoldKey.currentState.hideCurrentSnackBar();
    return;
  }

  String convertPMatchTime(int time, String roomKey) {
    var minutes = DateTime.fromMillisecondsSinceEpoch(time).difference(DateTime.now()).inMinutes;

    var hours = DateTime.fromMillisecondsSinceEpoch(time).difference(DateTime.now()).inHours;

    var days = DateTime.fromMillisecondsSinceEpoch(time).difference(DateTime.now()).inDays;

    // Sending connection request 24 hours before the connection screen is shown to have profiles ready and prevent slowdown in the app
    if (hours < 36) {
      Firestore.instance
          .collection('users')
          .document('${user.uid}')
          .collection('data_generated')
          .document('user_rooms')
          .collection('p_matches')
          .document('$roomKey')
          .get()
          .then(
        (doc) {
          if (!doc.exists) {
            print('No data document!');
          } else {
            if (doc.data['connections'] == null || doc.data['connections'].length == 0) {
              _sendConnectionsRequest(roomKey);
            }
          }
        },
      );
    }
    if (minutes < 0) {
      return AppLocalizations.of(context).translate('COMPLETED');
    }

    if (minutes < 60) {
      return (minutes > 1)
          ? '$minutes ${AppLocalizations.of(context).translate('minutes_left')}'
          : '$minutes ${AppLocalizations.of(context).translate('minute_left')}';
    } else if (hours < 24) {
      return (hours > 1)
          ? '$hours ${AppLocalizations.of(context).translate('hours_left')}'
          : '$hours ${AppLocalizations.of(context).translate('hour_left')}';
    } else if (days > 0) {
      if (days > 1) {
        if (hours % 24 > 1) {
          return '$days days, ${hours % 24} ${AppLocalizations.of(context).translate('hours_left')}';
        } else {
          return '$days days, ${hours % 24} ${AppLocalizations.of(context).translate('hour_left')}';
        }
      } else {
        if (hours % 24 > 1) {
          return '$days day, ${hours % 24} ${AppLocalizations.of(context).translate('hours_left')}';
        } else {
          return '$days day, ${hours % 24} ${AppLocalizations.of(context).translate('hour_left')}';
        }
      }
    }

    return ' ';
  }

  Future<void> _sendConnectionsRequest(String roomKey) async {
    // If the connections array has not been created yet, request the server to create it
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
      functionName: 'getConnectionUsers',
    );

    // Adding variables to the server to the request and calling the function
    await callable.call(
      <String, dynamic>{
        'latitude': locationData.latitude,
        'longitude': locationData.longitude,
        'key': roomKey,
      },
    );

    return;
  }
}
