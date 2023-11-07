import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> fetchWeatherDescription(String uid) async {
  // Accessing the Firestore instance and the specific document using uid
  DocumentSnapshot documentSnapshot =
  await FirebaseFirestore.instance.collection('locations').doc(uid).get();

  if (documentSnapshot.exists) {
    // Extracting the 'description' from the 'weather' map
    String description =
    documentSnapshot.get('location.weather.description');
    return description;
  } else {
    throw Exception('Document does not exist');
  }
}
