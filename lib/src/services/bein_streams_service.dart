
import 'package:cloud_firestore/cloud_firestore.dart';

class BeinStreamsService {
  final CollectionReference _beinCollection = FirebaseFirestore.instance.collection('bein_streams');

  Future<List<Map<String, dynamic>>> fetchBeinStreams() async {
    try {
      final snapshot = await _beinCollection.get();
      return snapshot.docs.map((doc) => {
        'name': doc['name'],
        'streams': List<Map<String, dynamic>>.from(doc['streams']),
      }).toList();
    } catch (e) {
      print('Error fetching BEIN streams: $e');
      return [];
    }
  }
}