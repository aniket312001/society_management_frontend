import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:society_management_app/core/di/injector.dart';
import 'package:society_management_app/features/user/domain/entities/user_entity.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import 'user_form.dart';

class UserScreen extends StatefulWidget {
  final String role;
  const UserScreen({super.key, required this.role});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<UserBloc>().add(LoadMoreUsers());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.role == "admin";

    return BlocProvider(
      create: (_) => sl<UserBloc>()..add(FetchUsers()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text("Users")),

            floatingActionButton: isAdmin
                ? FloatingActionButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<UserBloc>(),
                          child: const UserFormScreen(),
                        ),
                      ),
                    ),
                    child: const Icon(Icons.add),
                  )
                : null,

            body: BlocConsumer<UserBloc, UserState>(
              listenWhen: (prev, curr) =>
                  curr is UserPageLoaded && curr.message != null,
              listener: (context, state) {
                if (state is UserPageLoaded && state.message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message!),
                      backgroundColor: state.isError
                          ? Colors.red
                          : Colors.green,
                    ),
                  );
                }
              },

              buildWhen: (prev, curr) =>
                  curr is UserPageLoading ||
                  curr is UserPageLoaded ||
                  curr is UserPageError ||
                  curr is UserInitial,
              builder: (context, state) {
                // ─── Loading ───────────────────────────────────────
                if (state is UserInitial || state is UserPageLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // ─── Error ─────────────────────────────────────────
                if (state is UserPageError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<UserBloc>().add(FetchUsers()),
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                // ─── Loaded ────────────────────────────────────────
                if (state is UserPageLoaded) {
                  final users = state.users;
                  final hasMore = state.hasMore;

                  if (users.isEmpty) {
                    return const Center(child: Text("No users found."));
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<UserBloc>().add(FetchUsers());
                    },
                    child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      itemCount: users.length + (hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Loading more indicator at bottom
                        if (index == users.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final user = users[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            title: Text(user.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.email),
                                Text("Status: ${user.status}"),
                                if (user.role != null)
                                  Text("Role: ${user.role}"),
                              ],
                            ),
                            trailing: isAdmin
                                ? PopupMenuButton<String>(
                                    onSelected: (value) {
                                      print("value - ${value}");
                                      if (value == "edit") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BlocProvider.value(
                                              value: context.read<UserBloc>(),
                                              child: UserFormScreen(user: user),
                                            ),
                                          ),
                                        );
                                      } else if (value == "activate") {
                                        context.read<UserBloc>().add(
                                          UpdateUserStatus(user, "active"),
                                        );
                                      } else if (value == "reject") {
                                        context.read<UserBloc>().add(
                                          UpdateUserStatus(user, "rejected"),
                                        );
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: "edit",
                                        child: Text("Edit"),
                                      ),
                                      if (user.status == "rejected" ||
                                          user.status == "pending")
                                        const PopupMenuItem(
                                          value: "activate",
                                          child: Text("Activate"),
                                        ),
                                      if (user.status != "rejected")
                                        const PopupMenuItem(
                                          value: "reject",
                                          child: Text("Reject"),
                                        ),
                                    ],
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  );
                }

                // Fallback (should rarely happen)
                return const Center(child: Text("Something went wrong"));
              },
            ),
          );
        },
      ),
    );
  }
}
