import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:society_management_app/core/di/injector.dart';
import 'package:society_management_app/features/announcements/presentation/screens/annoucement_card.dart';
import 'package:society_management_app/features/announcements/presentation/screens/announcement_forms.dart';
import '../bloc/announcement_bloc.dart';
import '../bloc/announcement_event.dart';
import '../bloc/announcement_state.dart';

class AnnouncementScreen extends StatefulWidget {
  final String role;

  const AnnouncementScreen({super.key, required this.role});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AnnouncementBloc>().add(const LoadMoreAnnouncements());
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
      create: (_) => sl<AnnouncementBloc>()..add(const FetchAnnouncements()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text("Announcements")),

            floatingActionButton: isAdmin
                ? FloatingActionButton(
                    onPressed: () => _openForm(context),
                    child: const Icon(Icons.add),
                  )
                : null,

            body: BlocConsumer<AnnouncementBloc, AnnouncementState>(
              listenWhen: (_, curr) =>
                  curr is AnnouncementPageLoaded && curr.message != null,
              listener: (ctx, state) {
                if (state is AnnouncementPageLoaded && state.message != null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(state.message!),
                      backgroundColor: state.isError
                          ? Colors.red
                          : Colors.green,
                    ),
                  );
                }
              },
              buildWhen: (_, curr) =>
                  curr is AnnouncementInitial ||
                  curr is AnnouncementPageLoading ||
                  curr is AnnouncementPageLoaded ||
                  curr is AnnouncementPageError,
              builder: (context, state) {
                if (state is AnnouncementInitial ||
                    state is AnnouncementPageLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AnnouncementPageError) {
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
                          onPressed: () => context.read<AnnouncementBloc>().add(
                            const FetchAnnouncements(),
                          ),
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                if (state is AnnouncementPageLoaded) {
                  if (state.announcements.isEmpty) {
                    return const Center(child: Text("No announcements found."));
                  }

                  return RefreshIndicator(
                    onRefresh: () async => context.read<AnnouncementBloc>().add(
                      const FetchAnnouncements(),
                    ),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      itemCount:
                          state.announcements.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.announcements.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final a = state.announcements[index];
                        return AnnouncementCard(
                          announcement: a,
                          isAdmin: isAdmin,
                          onEdit: isAdmin
                              ? () => _openForm(context, announcement: a)
                              : null,
                          onDelete: isAdmin
                              ? () => _confirmDelete(context, a.id)
                              : null,
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context, {announcement}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AnnouncementBloc>(),
          child: AnnouncementFormScreen(announcement: announcement),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Announcement"),
        content: const Text(
          "Are you sure you want to delete this announcement?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<AnnouncementBloc>().add(DeleteAnnouncement(id));
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
