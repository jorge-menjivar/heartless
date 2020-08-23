import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:lise/bloc/public_profile_bloc.dart';
import 'package:lise/widgets/loading_progress_indicator.dart';

class PublicProfileScreen extends StatefulWidget {
  final String name;
  final String alias;

  PublicProfileScreen({
    Key key,
    @required this.alias,
    @required this.name,
  }) : super(key: key);

  @override
  _PublicProfileScreenState createState() => _PublicProfileScreenState(
        alias: this.alias,
        name: name,
      );
}

enum PopupMenuChoice { flag }

class _PublicProfileScreenState extends State<PublicProfileScreen> with AutomaticKeepAliveClientMixin {
  final String alias;
  final String name;

  _PublicProfileScreenState({
    @required this.alias,
    @required this.name,
  });

  var dataLoaded = false;
  var picturesLoaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Creating the profile bloc and initializing it
    BlocProvider.of<PublicProfileBloc>(context)..add(GetPublicProfile(alias: alias));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<PopupMenuChoice>(
            onSelected: (PopupMenuChoice result) {
              print(result);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<PopupMenuChoice>>[
              const PopupMenuItem<PopupMenuChoice>(
                value: PopupMenuChoice.flag,
                child: Text('Report'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          BlocBuilder<PublicProfileBloc, PublicProfileState>(
            builder: (context, state) {
              if (state is PublicProfileLoading) {
                return loading_progress_indicator();
              } else if (state is PublicProfileLoaded) {
                final pictureList = state.publicProfile.pictureURLs;

                return CarouselSlider.builder(
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.height * .55,
                    viewportFraction: 1.0,
                    aspectRatio: 16 / 12,
                    disableCenter: true,
                    enableInfiniteScroll: false,
                  ),
                  itemCount: pictureList.length,
                  itemBuilder: (BuildContext context, int index) => Container(
                    child: CachedNetworkImage(
                      imageUrl: pictureList[index],
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                );
              }
              return loading_progress_indicator();
            },
          ),
          Divider(color: Colors.transparent),
          Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text(
                    name + ', 21',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                  subtitle: Text(
                    'Male',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 3,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(5, (index) {
                          return Container(
                            margin: EdgeInsets.all(4),
                            child: FaIcon(
                              FontAwesomeIcons.fire,
                              color: Colors.red,
                              size: 16,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 3,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(5, (index) {
                          return Container(
                            margin: EdgeInsets.all(4),
                            child: FaIcon(
                              FontAwesomeIcons.solidStar,
                              color: Colors.yellow,
                              size: 15,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 3,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(5, (index) {
                          return Container(
                            margin: EdgeInsets.all(4),
                            child: FaIcon(
                              FontAwesomeIcons.pepperHot,
                              color: Colors.green,
                              size: 16,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: Colors.transparent),
        ],
      ),
    );
  }
}
