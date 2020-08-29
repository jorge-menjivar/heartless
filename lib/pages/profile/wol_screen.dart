import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Storage
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frino_icons/frino_icons.dart';

class WayOfLivingScreen extends StatefulWidget {
  WayOfLivingScreen({@required this.user});

  final FirebaseUser user;

  @override
  WayOfLivingScreenState createState() => WayOfLivingScreenState(user: user);
}

class WayOfLivingScreenState extends State<WayOfLivingScreen> {
  WayOfLivingScreenState({@required this.user});

  final FirebaseUser user;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;

  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  var _mostLiked = [];

  var _userLikes = [];

  final MAX = 6;

  final _listTitleStyle = const TextStyle(fontWeight: FontWeight.bold);

  TextEditingController _textController;
  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _scrollController = ScrollController();
    _downloadData();
  }

  Future<void> _downloadData() async {
    await Firestore.instance
        .collection('dictionary')
        .orderBy('likes', descending: true)
        .limit(10)
        .getDocuments()
        .then((snapshot) {
      for (var doc in snapshot.documents) {
        _mostLiked.add(doc.documentID);
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('My way of living'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Divider(color: Colors.transparent),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Platform.isIOS ? cupertinoTextField(context) : materialTextField(context),
          ),
          Divider(color: Colors.transparent),
          Container(
            padding: EdgeInsets.only(left: 12),
            child: Text(
              'MOST POPULAR',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _mostLiked.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: ActionChip(
                    label: Text(_mostLiked[index]),
                    onPressed: () {
                      _addInterest(_mostLiked[index]);
                    },
                    autofocus: false,
                  ),
                );
              },
            ),
          ),
          Divider(),
          Divider(color: Colors.transparent),
          Container(
            padding: EdgeInsets.only(left: 12),
            child: Text(
              'MY INTERESTS (${_userLikes.length}/$MAX)',
              textAlign: TextAlign.left,
              style: _listTitleStyle,
            ),
          ),
          Divider(color: Colors.transparent),
          Flexible(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white12 : Colors.black12,
              ),
              child: AnimatedList(
                key: listKey,
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                controller: ScrollController(),
                initialItemCount: _userLikes.length,
                itemBuilder: (BuildContext context, int index, Animation<double> animation) =>
                    animatedTile(index, animation),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget animatedTile(int index, Animation<double> animation, {like}) {
    return ScaleTransition(
      scale: animation,
      alignment: Alignment.centerRight,
      child: ListTile(
        title: Text((like != null) ? like : _userLikes[index]),
        trailing: removeIcon(index),
      ),
    );
  }

  Widget materialTextField(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.text,
      autocorrect: true,
      enableSuggestions: true,
      enableInteractiveSelection: true,
      textCapitalization: TextCapitalization.none,
      minLines: 1,
      maxLines: 1,
      showCursor: true,
      controller: _textController,
      decoration: InputDecoration(
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: 12),
          child: addIcon(),
        ),
        hintText: 'Add interest',
        fillColor: Theme.of(context).splashColor,
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white54 : Colors.black12,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white12 : Colors.black12,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white12 : Colors.black12,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
      ),
    );
  }

  Widget cupertinoTextField(BuildContext context) {
    return CupertinoTextField(
      keyboardType: TextInputType.text,
      clearButtonMode: OverlayVisibilityMode.editing,
      autocorrect: true,
      enableSuggestions: true,
      enableInteractiveSelection: true,
      textCapitalization: TextCapitalization.none,
      minLines: 1,
      maxLines: 1,
      showCursor: true,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyText2.color,
      ),
      controller: _textController,
      placeholder: "Add interest",
      suffix: addIcon(),
      suffixMode: OverlayVisibilityMode.always,
      decoration: BoxDecoration(
        border: Border.all(
          color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white12 : Colors.black12,
        ),
        color: Theme.of(context).splashColor,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget removeIcon(int index) {
    return IconButton(
      icon: Icon(
        CupertinoIcons.minus_circled,
      ),
      onPressed: () {
        var like = _userLikes[index];
        listKey.currentState.removeItem(
          index,
          (context, animation) => animatedTile(
            index,
            animation,
            like: like,
          ),
          duration: Duration(
            milliseconds: 350,
          ),
        );

        _userLikes.removeAt(index);

        setState(() {});
      },
    );
  }

  Widget addIcon() {
    return IconButton(
      icon: Icon(
        CupertinoIcons.add_circled,
        color: IconTheme.of(context).color,
        size: IconTheme.of(context).size,
      ),
      onPressed: () {
        if (_textController.text.contains(RegExp(r'\S'))) {
          _addInterest(_textController.text);
        }
      },
    );
  }

  Future<void> _addInterest(String interest) {
    listKey.currentState.insertItem(_userLikes.length,
        duration: Duration(
          milliseconds: 300,
        ));
    _userLikes.add(interest);
    setState(() {});
  }
}
