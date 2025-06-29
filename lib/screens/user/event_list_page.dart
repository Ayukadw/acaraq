import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
//import '../models/event.dart';
import '../admin/add_edit_event_page.dart';
import 'event_detail_page.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({Key? key}) : super(key: key);

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        return Scaffold(
          body:
              eventProvider.events.isEmpty
                  ? const Center(child: Text('Belum ada acara'))
                  : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: eventProvider.events.length,
                    itemBuilder: (context, index) {
                      final event = eventProvider.events[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        child: ListTile(
                          title: Text(
                            event.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          subtitle: Text('${event.date} • ${event.location}'),
                          trailing:
                              authProvider.isAdmin
                                  ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => AddEditEventPage(
                                                    event: event,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          Provider.of<EventProvider>(
                                            context,
                                            listen: false,
                                          ).deleteEvent(event.id!);
                                        },
                                      ),
                                    ],
                                  )
                                  : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EventDetailPage(event: event),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          floatingActionButton:
              authProvider.isAdmin
                  ? FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddEditEventPage(),
                        ),
                      );
                    },
                    backgroundColor: Colors.orange,
                    child: const Icon(Icons.add),
                  )
                  : null,
        );
      },
    );
  }
}
