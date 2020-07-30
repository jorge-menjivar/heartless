import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Messages extends Equatable {
  final list;

  Messages({
    @required this.list,
  });

  @override
  List<Object> get props => [list];
}
