import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class PublicProfile extends Equatable {
  final List pictureURLs;

  PublicProfile({
    @required this.pictureURLs,
  });

  @override
  List<Object> get props => [pictureURLs];
}
