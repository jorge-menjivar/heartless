import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lise/home_screen.dart';
import 'package:lise/main.dart';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SelectMatchesScreen extends StatefulWidget {
  final String room;

  SelectMatchesScreen({@required this.room});

  @override
  SelectMatchesScreenState createState() => new SelectMatchesScreenState(room: this.room);
}

class SelectMatchesScreenState extends State<SelectMatchesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String room;
  
  SelectMatchesScreenState({@required this.room});

  final secureStorage = new FlutterSecureStorage();

  FirebaseUser user;
  
  ScrollController _scrollController;

  var _profiles;

  bool _firstTry = true;
  int _counter = 0;
  final TextEditingController _controllerEmail = new TextEditingController();
  final TextEditingController _controllerPassword = new TextEditingController();
  final _emailFieldKey = GlobalKey<FormFieldState>();
  final _passwordFieldKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _profiles = [false, false, false, false, false, false, false, false, false, false, false, false, ];
  }
  
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: new Text("Looks"),
        elevation: 4.0,
      ),
      body: new Builder(
        builder: (BuildContext context) {
          return Container(
            decoration: new BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Select the profiles that you find attractive",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                SizedBox(
                  height: 200,
                  child:
                  ListView(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    children: <Widget>[
                      Center(
                        child: Card(
                          color: (_profiles[0]) 
                            ? Colors.green
                            : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(100))
                          ),
                          child:  SizedBox(
                            width: 200,
                            height: 200,
                            child: CupertinoButton(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      "https://st.depositphotos.com/1597387/1984/i/450/depositphotos_19841901-stock-photo-asian-young-business-man-close.jpg",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              ),
                              onPressed: () {
                                setState(() {
                                  _profiles[0] = !_profiles[0];
                                });
                              },
                            )
                          ),
                        )
                      ),
                      Center(
                        child: Card(
                          color: (_profiles[1]) 
                            ? Colors.green
                            : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(100))
                          ),
                          child:  SizedBox(
                            width: 200,
                            height: 200,
                            child: CupertinoButton(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      "https://media-exp1.licdn.com/dms/image/C4E03AQE2s8trWXGjWw/profile-displayphoto-shrink_200_200/0?e=1587600000&v=beta&t=NJUaGXLUdAqe44cm_UgWYLb_CxMlSED0CcPp1W7Fnbk",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              ),
                              onPressed: () {
                                setState(() {
                                  _profiles[1] = !_profiles[1];
                                });
                              },
                            )
                          ),
                        )
                      ),
                      Center(
                        child: Card(
                          color: (_profiles[2]) 
                            ? Colors.green
                            : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(100))
                          ),
                          child:  SizedBox(
                            width: 200,
                            height: 200,
                            child: CupertinoButton(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      "https://images.pexels.com/photos/555790/pexels-photo-555790.png?auto=compress&cs=tinysrgb&dpr=1&w=500",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              ),
                              onPressed: () {
                                setState(() {
                                  _profiles[2] = !_profiles[2];
                                });
                              },
                            )
                          ),
                        )
                      ),
                      Center(
                        child: Card(
                          color: (_profiles[3]) 
                            ? Colors.green
                            : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(100))
                          ),
                          child:  SizedBox(
                            width: 200,
                            height: 200,
                            child: CupertinoButton(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      "https://lh3.googleusercontent.com/nvY4xt3EcLtvdivYl5Vu5a1imzhk43oR9qA183eiNumUyrZ-_3mMnyXRzqKbM3S_77QLafalHmgb3JdouXi023kcgL3ZU4Y8GuRautjkhTP3lMgVZAzucr_YaZ7g285yLCksl20APbqc9UkoEAgIKIynxKnGmZK7ELME24xDdv-KJQooizazOZbHqr-z5BPpZMV1Zo_Ni2qfRl1XPirLDQzxsrUwpQHOkvYj8wDlWtNHx1GDy0LjdEucwD6Dk1gxvOukJgWh7L3CWxFLw4CI7_M48Fpybg56AK-X6V5nwFLE4QeNGm3AAHKCyjrlyMlvLSgpeB3dDUXkT2Qv9WG4p9JqE3vuS4BxqIutEP1G4NNLFYQHqpOV54SKooIUZ1AvnFbc2FloA8WbRH2mN69FTrAeYSMQumvY3HWcyaxjTmfqMLguZsBK-KSiSI4m1f6KXyMHrfiLD5nNvNT0FJfk74EGAz6tuZQ0dfN6HBAiAA0yrYHCXIy8lvaCJUSGbLfGxUcs8mjfrgbKEB80tb1RABra_3vj-1sinS_hlKpA9SrvqtDO6AdGBt7HeUiYPM4AA_HGLZrgotWJKOVO9Kc5EyWkJsYrM4uSidPGpZzHhhtoOjAjii1dFKxpkLt2kTtyF34QHUp7WMVUpFu8QPfBk0Fpfeb73kmUQzTFr2pjkRshqoy4ydp_VJN4LzHh6Lw_3OKL2kjzIKzEVmNp_J7S-Ll4UPE18rmkzLlqdVOkoa3Ob802HWgMbOg=w1180-h1570-no",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              ),
                              onPressed: () {
                                setState(() {
                                  _profiles[3] = !_profiles[3];
                                });
                              },
                            )
                          ),
                        )
                      ),
                      Center(
                        child: Card(
                          color: (_profiles[4]) 
                            ? Colors.green
                            : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(100))
                          ),
                          child:  SizedBox(
                            width: 200,
                            height: 200,
                            child: CupertinoButton(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      "https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              ),
                              onPressed: () {
                                setState(() {
                                  _profiles[4] = !_profiles[4];
                                });
                              },
                            )
                          ),
                        )
                      ),
                      Center(
                        child: Card(
                          color: (_profiles[5]) 
                            ? Colors.green
                            : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(100))
                          ),
                          child:  SizedBox(
                            width: 200,
                            height: 200,
                            child: CupertinoButton(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      "https://images.unsplash.com/photo-1561259230-46fa9832bf20?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              ),
                              onPressed: () {
                                setState(() {
                                  _profiles[5] = !_profiles[5];
                                });
                              },
                            )
                          ),
                        )
                      ),
                      Center(
                        child: Card(
                          color: (_profiles[6]) 
                            ? Colors.green
                            : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(100))
                          ),
                          child:  SizedBox(
                            width: 200,
                            height: 200,
                            child: CupertinoButton(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      "https://thumbs.dreamstime.com/b/thoughtful-african-american-man-profile-portrait-white-searching-idea-copy-space-130743833.jpg",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              ),
                              onPressed: () {
                                setState(() {
                                  _profiles[6] = !_profiles[6];
                                });
                              },
                            )
                          ),
                        )
                      ),
                      Center(
                        child: Card(
                          color: (_profiles[7]) 
                            ? Colors.green
                            : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(100))
                          ),
                          child:  SizedBox(
                            width: 200,
                            height: 200,
                            child: CupertinoButton(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      "https://media.gettyimages.com/photos/man-in-brown-shirt-smiling-profile-picture-id200484807-001",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              ),
                              onPressed: () {
                                setState(() {
                                  _profiles[7] = !_profiles[7];
                                });
                              },
                            )
                          ),
                        )
                      ),
                      Center(
                        child: Card(
                          color: (_profiles[8]) 
                            ? Colors.green
                            : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(100))
                          ),
                          child:  SizedBox(
                            width: 200,
                            height: 200,
                            child: CupertinoButton(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      "https://hlai.org/wp-content/uploads/2019/10/Daniel-Hernandez-971x1024.jpg",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              ),
                              onPressed: () {
                                setState(() {
                                  _profiles[8] = !_profiles[8];
                                });
                              },
                            )
                          ),
                        )
                      ),
                      Center(
                        child: Card(
                          color: (_profiles[9]) 
                            ? Colors.green
                            : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(100))
                          ),
                          child:  SizedBox(
                            width: 200,
                            height: 200,
                            child: CupertinoButton(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      "http://www.networkfp.com/wp-content/uploads/2016/08/man-1.jpg",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              ),
                              onPressed: () {
                                setState(() {
                                  _profiles[9] = !_profiles[9];
                                });
                              },
                            )
                          ),
                        )
                      ),
                      Center(
                        child: Card(
                          color: (_profiles[10]) 
                            ? Colors.green
                            : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(100))
                          ),
                          child:  SizedBox(
                            width: 200,
                            height: 200,
                            child: CupertinoButton(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      "http://actionsportsgames.com.au/cms/wp-content/uploads/2014/11/profile_picture_by_naivety_stock-d5x8lbn.jpg",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              ),
                              onPressed: () {
                                setState(() {
                                  _profiles[10] = !_profiles[10];
                                });
                              },
                            )
                          ),
                        )
                      ),
                      Center(
                        child: Card(
                          color: (_profiles[11]) 
                            ? Colors.green
                            : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(100))
                          ),
                          child:  SizedBox(
                            width: 200,
                            height: 200,
                            child: CupertinoButton(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      "https://previews.123rf.com/images/keeweeboy/keeweeboy1111/keeweeboy111100058/11215878-young-hispanic-man-closeup-headshot.jpg",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              ),
                              onPressed: () {
                                setState(() {
                                  _profiles[11] = !_profiles[11];
                                });
                              },
                            )
                          ),
                        )
                      ),
                    ],
                  )
                ),
                SizedBox (
                  height: 50,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      CupertinoButton(
                        color: Colors.black,
                        child: Text (
                          'CONTINUE',
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                        onPressed: () {},
                      )
                    ]
                  )
                )
              ]
            )
          );
        },
      )
    );
  }

  

  @override
  void dispose() {
    super.dispose();
  }

}