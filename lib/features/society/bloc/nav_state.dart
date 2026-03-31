import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavState extends Equatable {
  final int currentIndex;
  const NavState({this.currentIndex = 0});

  @override
  List<Object?> get props => [currentIndex];
}
