import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingScreen extends StatelessWidget {
  final String movieId;

  const BookingScreen({required this.movieId}); // Required movieId

  Future<void> _bookTicket(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('bookings').add({
      'userId': user.uid,
      'movieId': movieId,
      'timestamp': DateTime.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ticket booked successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book Ticket')),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('movies').doc(movieId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Movie not found'));
          }

          final movie = snapshot.data!;
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie['title'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text('Genre: ${movie['genre']}'),
                Text('Duration: ${movie['duration']} mins'),
                Text('Rating: ${movie['rating']}'),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _bookTicket(context),
                  child: Text('Book Ticket'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
