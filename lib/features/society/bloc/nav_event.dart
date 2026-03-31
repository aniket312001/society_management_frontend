import 'package:equatable/equatable.dart';

abstract class NavEvent extends Equatable {
  const NavEvent();
  @override
  List<Object?> get props => [];
}

class NavTabChanged extends NavEvent {
  final int index;
  const NavTabChanged(this.index);
  @override
  List<Object?> get props => [index];
}
