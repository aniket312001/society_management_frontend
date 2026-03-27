import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:society_management_app/core/di/injector.dart';
import 'package:society_management_app/features/visitors/presentation/screens/visitor_card.dart';
import '../bloc/visitor_bloc.dart';
import '../bloc/visitor_event.dart';
import '../bloc/visitor_state.dart';
import 'visitor_form_screen.dart';

class VisitorScreen extends StatefulWidget {
  final String role;
  final int currentUserId;

  const VisitorScreen({
    super.key,
    required this.role,
    required this.currentUserId,
  });

  @override
  State<VisitorScreen> createState() => _VisitorScreenState();
}

class _VisitorScreenState extends State<VisitorScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<VisitorBloc>().add(LoadMoreVisitors());
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
      create: (_) => sl<VisitorBloc>()..add(FetchVisitors()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text("Visitors")),

            floatingActionButton: FloatingActionButton(
              onPressed: () => _openForm(context),
              child: const Icon(Icons.add),
            ),

            body: BlocConsumer<VisitorBloc, VisitorState>(
              listenWhen: (_, curr) =>
                  curr is VisitorPageLoaded && curr.message != null,
              listener: (ctx, state) {
                if (state is VisitorPageLoaded && state.message != null) {
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
                  curr is VisitorInitial ||
                  curr is VisitorPageLoading ||
                  curr is VisitorPageLoaded ||
                  curr is VisitorPageError,
              builder: (context, state) {
                if (state is VisitorInitial || state is VisitorPageLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is VisitorPageError) {
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
                              context.read<VisitorBloc>().add(FetchVisitors()),
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                if (state is VisitorPageLoaded) {
                  if (state.visitors.isEmpty) {
                    return const Center(child: Text("No visitors found."));
                  }

                  return RefreshIndicator(
                    onRefresh: () async =>
                        context.read<VisitorBloc>().add(FetchVisitors()),
                    child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      itemCount:
                          state.visitors.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.visitors.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final visitor = state.visitors[index];
                        final isOwner = visitor.addedBy == widget.currentUserId;

                        return VisitorCard(
                          visitor: visitor,
                          isAdmin: isAdmin,
                          canEdit: isOwner && visitor.status == "pending",
                          onEdit: () => _openForm(context, visitor: visitor),
                          onDelete: isOwner || isAdmin
                              ? () => _confirmDelete(context, visitor.id)
                              : null,
                          onStatusChange: isAdmin
                              ? (status) => _showStatusDialog(
                                  context,
                                  visitor.id,
                                  status,
                                )
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

  void _openForm(BuildContext context, {visitor}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<VisitorBloc>(),
          child: VisitorFormScreen(visitor: visitor),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Visitor"),
        content: const Text("Are you sure you want to remove this visitor?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<VisitorBloc>().add(DeleteVisitor(id));
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(BuildContext context, int id, String currentStatus) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Update Status"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: "Note (optional)",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          if (currentStatus != "approved")
            TextButton(
              onPressed: () {
                context.read<VisitorBloc>().add(
                  UpdateVisitorStatus(
                    visitorId: id,
                    status: "approved",
                    note: noteController.text.trim().isEmpty
                        ? null
                        : noteController.text.trim(),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text(
                "Approve",
                style: TextStyle(color: Colors.green),
              ),
            ),
          if (currentStatus != "rejected")
            TextButton(
              onPressed: () {
                context.read<VisitorBloc>().add(
                  UpdateVisitorStatus(
                    visitorId: id,
                    status: "rejected",
                    note: noteController.text.trim().isEmpty
                        ? null
                        : noteController.text.trim(),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text("Reject", style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
}
