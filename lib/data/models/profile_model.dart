import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String profilePictureURL;
  final String name;
  final String email;

  Profile({
    @required this.name,
    @required this.profilePictureURL,
    @required this.email,
  });

  @override
  List<Object> get props => [name, email, profilePictureURL];
}
