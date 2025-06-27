import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/event.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;

  const EventDetailPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LatLng eventLatLng = LatLng(event.latitude, event.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Acara'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.title,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange)),
            const SizedBox(height: 8),
            Text('${event.date} • ${event.time}'),
            const SizedBox(height: 8),
            Text(event.description),
            const SizedBox(height: 16),
            const Text("Lokasi Acara:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(event.location),
            SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: eventLatLng,
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId("event_location"),
                    position: eventLatLng,
                    infoWindow: InfoWindow(title: event.title),
                  )
                },
                liteModeEnabled: true,
              ),
            ),
            const SizedBox(height: 16),
            const Text("Tuan Rumah:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(event.hostName),
            const SizedBox(height: 16),
            const Text("Catatan:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(event.notes),
            const SizedBox(height: 24),
            const Text("QR Code untuk Check-In:", style: TextStyle(fontWeight: FontWeight.bold)),
            Center(
              child: QrImageView(
                data: event.id.toString(),
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
