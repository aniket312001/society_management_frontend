import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:society_management_app/features/society/bloc/nav_event.dart';
import 'package:society_management_app/features/society/bloc/nav_state.dart';

class NavBloc extends Bloc<NavEvent, NavState> {
  NavBloc() : super(const NavState()) {
    on<NavTabChanged>((e, emit) => emit(NavState(currentIndex: e.index)));
  }
}
