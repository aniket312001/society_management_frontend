import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:society_management_app/core/error/exceptions.dart';
import 'package:society_management_app/features/user/domain/usecases/create_user_usecase.dart';
import 'package:society_management_app/features/user/domain/usecases/fetch_users_usecase.dart';
import 'package:society_management_app/features/user/domain/usecases/update_user_usecase.dart';
import 'package:society_management_app/features/user/presentation/bloc/user_event.dart';
import 'package:society_management_app/features/user/presentation/bloc/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final FetchUsersUsecase fetchUsersUsecase;
  final UpdateUserUsecase updateUserUsecase;
  final CreateUserUsecase createUserUsecase;

  String? _status;
  String? _role;
  String? _search;

  UserBloc(
    this.fetchUsersUsecase,
    this.updateUserUsecase,
    this.createUserUsecase,
  ) : super(UserInitial()) {
    on<FetchUsers>(_onFetchUsers);
    on<LoadMoreUsers>(_onLoadMoreUsers);
    on<UpdateUserStatus>(_onUpdateUserStatus);
    on<CreateUser>(_onCreateUser);
  }

  String _getErrorMessage(Object error) {
    if (error is ValidationException) {
      return error.message;
    } else if (error is ServerException) {
      return error.message;
    } else if (error is UnauthorizedException) {
      return error.message;
    } else if (error is ConflictException) {
      return error.message;
    } else if (error is NetworkException) {
      return error.message;
    }
    return error.toString(); // fallback
  }

  // ─── Fetch Users ────────────────────────────────────────────────────────────
  Future<void> _onFetchUsers(FetchUsers event, Emitter<UserState> emit) async {
    emit(UserPageLoading());
    try {
      _status = event.status;
      _role = event.role;
      _search = event.search;

      final users = await fetchUsersUsecase(
        page: 1,
        status: _status,
        role: _role,
        search: _search,
      );

      emit(UserPageLoaded(users: users, hasMore: users.length == 10, page: 1));
    } catch (e) {
      emit(UserPageLoaded(users: [], hasMore: true, page: 0));
    }
  }

  // ─── Load More ──────────────────────────────────────────────────────────────
  Future<void> _onLoadMoreUsers(
    LoadMoreUsers event,
    Emitter<UserState> emit,
  ) async {
    if (state is! UserPageLoaded) return;
    final current = state as UserPageLoaded;
    if (!current.hasMore) return;

    try {
      final nextPage = current.page + 1;
      final users = await fetchUsersUsecase(
        page: nextPage,
        status: _status,
        role: _role,
        search: _search,
      );

      emit(
        UserPageLoaded(
          users: [...current.users, ...users],
          hasMore: users.length == 10,
          page: nextPage,
        ),
      );
    } catch (e) {
      emit(UserPageError(_getErrorMessage(e)));
    }
  }

  // ─── Update User Status ─────────────────────────────────────────────────────
  // ✅ No UserFormLoading — stays on UserPageLoaded the whole time
  Future<void> _onUpdateUserStatus(
    UpdateUserStatus event,
    Emitter<UserState> emit,
  ) async {
    if (state is! UserPageLoaded) return;
    final current = state as UserPageLoaded;

    try {
      final updatedUser = await updateUserUsecase(
        userId: event.user.id,
        data: event.user.copyWith(status: event.status),
      );

      final patchedList = current.users
          .map((u) => u.id == updatedUser.id ? updatedUser : u)
          .toList();

      emit(
        UserPageLoaded(
          users: patchedList,
          hasMore: current.hasMore,
          page: current.page,
          message: "${updatedUser.name} updated successfully!",
          isError: false,
        ),
      );
    } catch (e) {
      emit(
        UserPageLoaded(
          users: current.users,
          hasMore: current.hasMore,
          page: current.page,
          message: _getErrorMessage(e),
          isError: true,
        ),
      );
    }
  }

  // ─── Create User ────────────────────────────────────────────────────────────
  Future<void> _onCreateUser(CreateUser event, Emitter<UserState> emit) async {
    final current = state is UserPageLoaded ? state as UserPageLoaded : null;

    emit(UserFormLoading()); // keep loading for form

    try {
      final createdUser = await createUserUsecase(data: event.user);

      if (current != null) {
        emit(
          UserPageLoaded(
            users: [createdUser, ...current.users],
            hasMore: current.hasMore,
            page: current.page,
            message: "User created successfully",
            isError: false,
          ),
        );
      }
    } catch (e) {
      if (current != null) {
        emit(
          UserPageLoaded(
            users: current.users,
            hasMore: current.hasMore,
            page: current.page,
            message: _getErrorMessage(e),
            isError: true,
          ),
        );
      } else {
        emit(UserFormError(_getErrorMessage(e))); // fallback
      }
    }
  }
}
