import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:lise/messages/m_matches_screen.dart';

import '../localizations.dart';

class MatchesScreen extends StatefulWidget {
  MatchesScreen({Key key, @required this.scaffoldKey, @required this.user}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;
  final FirebaseUser user;

  @override
  _MatchesScreenState createState() => _MatchesScreenState(scaffoldKey: this.scaffoldKey, user: this.user);
}

class _MatchesScreenState extends State<MatchesScreen> with AutomaticKeepAliveClientMixin {
  _MatchesScreenState({@required this.scaffoldKey, @required this.user});

  var dataLoaded = false;

  final scaffoldKey;
  final user;

  var _matches = [];

  var matchesInitialized = false;
  final _matchImageLinks = [];
  final _matchLastMessages = [];

  ScrollController _scrollController;

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

    if (!matchesInitialized) {
      Firestore.instance
          .collection('users')
          .document('${user.uid}')
          .collection('data_generated')
          .document('user_rooms')
          .collection('matches')
          .snapshots()
          .listen(
        (querySnapshot) {
          _matches = querySnapshot.documents;
          _loadMatchesData();
        },
      );

      matchesInitialized = true;
    }
  }

  void _loadMatchesData() async {
    if (_matchImageLinks.isNotEmpty) {
      _matchImageLinks.clear();
    }
    if (_matchLastMessages.isNotEmpty) {
      _matchLastMessages.clear();
    }

    for (var match in _matches) {
      try {
        // Getting the picture download URL for each user from the downloaded array
        _matchImageLinks.add(
          await FirebaseStorage()
              .ref()
              .child('users/${match['otherUserId']}/profile_pictures/pic1.jpg')
              .getDownloadURL(),
        );

        // Getting the last message sent in each conversation
        final lastMessage = await Firestore.instance
            .collection('messages')
            .document('rooms')
            .collection('${match['room']}')
            .where('time', isGreaterThanOrEqualTo: 0)
            .orderBy('time', descending: true)
            .limit(1)
            .getDocuments();

        _matchLastMessages.add(lastMessage.documents[0]);
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

    dataLoaded = true;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: const EdgeInsets.all(1),
      controller: _scrollController,
      itemCount: _matches.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return ListTile(
            leading: Text(AppLocalizations.of(context).translate('MATCHES'),
                textAlign: TextAlign.left, style: _listTitleStyle),
          );
        }

        final match = _matches[i - 1];
        var lastMessage;
        var time;
        if (_matchLastMessages.isNotEmpty) {
          time = _matchLastMessages[i - 1]['time'];
        }
        if (_matchLastMessages.isNotEmpty && time > 0) {
          if (_matchLastMessages[i - 1]['from'] == user.uid) {
            lastMessage = 'You: ${_matchLastMessages[i - 1]['message']}';
          } else {
            lastMessage = _matchLastMessages[i - 1]['message'];
          }
        } else {
          lastMessage = AppLocalizations.of(context).translate('Start_Conversation');
        }
        return ListTile(
          leading: Container(
            decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            child: SizedBox(
              height: 50,
              width: 50,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: _matchImageLinks.isNotEmpty
                      ? DecorationImage(
                          image: AdvancedNetworkImage(
                            _matchImageLinks[i - 1],
                            useDiskCache: true,
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
            ),
          ),
          title: Text(
            match['otherUser'],
            textAlign: TextAlign.left,
            style: _biggerFont,
          ),
          subtitle: Text(
            lastMessage,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: _subFont,
            textAlign: TextAlign.left,
          ),
          trailing: Text(
            (_matchLastMessages.isNotEmpty && time > 0)
                ? convertMatchTime(int.parse(_matchLastMessages[i - 1].documentID))
                : '',
            style: _trailFont,
            textAlign: TextAlign.left,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MatchedConversationScreen(
                  imageLink: _matchImageLinks[i - 1],
                  alias: _alias,
                  matchName: match['otherUser'],
                  otherUserId: match['otherUserId'],
                  username: user.displayName,
                  room: match['room'],
                ),
              ),
            ).then((value) {
              _loadMatchesData();
            });
          },
          onLongPress: () {
            setState(() {
              showDeleteDialog(context, match['otherUser']).then((v) {
                if (v) {
                  _deleteMatch(int.parse(match.documentID), match['room']);
                }
              });
            });
          },
        );
      },
    );
  }

  Future<void> _deleteMatch(int time, String room) async {
    final snackBar = SnackBar(
      content: Text(
        //TODO
        'Deleting Match',
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
    // Getting instance of the server function
    final callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'deleteMatch',
    );

    // Adding variables to the server to the request and calling the function
    await callable.call(
      <String, dynamic>{
        'time': time,
        'room': room,
      },
    );

    scaffoldKey.currentState.hideCurrentSnackBar();
    return;
  }

  String convertMatchTime(int time) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(time);

    var minutes = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(time)).inMinutes;

    var hours = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(time)).inHours;

    var days = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(time)).inDays;

    if (minutes < 1) {
      return AppLocalizations.of(context).translate('Just_now');
    } else if (minutes < 60) {
      return (minutes > 1)
          ? '$minutes ${AppLocalizations.of(context).translate('minutes_ago')}'
          : '$minutes ${AppLocalizations.of(context).translate('minute_ago')}';
    } else if (hours < 24) {
      return (hours > 1)
          ? '$hours ${AppLocalizations.of(context).translate('hours_ago')}'
          : '$hours ${AppLocalizations.of(context).translate('hour_ago')}';
    } else if (days < 7) {
      return (days > 1)
          ? '${days} ${AppLocalizations.of(context).translate('days_ago')}'
          : '${days} ${AppLocalizations.of(context).translate('day_ago')}';
    } else if (days > 7) {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }

    return '';
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
}
