import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class PMatches extends Equatable {
  final List list;

  PMatches({
    @required this.list,
  });

  @override
  List<Object> get props => [list];
}
