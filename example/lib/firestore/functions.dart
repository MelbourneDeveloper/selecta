import 'package:cloud_firestore/cloud_firestore.dart';

/// Returns a list of fields from a list of documents
List<String> getFields(List<QueryDocumentSnapshot<Object?>> docs) =>
    docs.fold<Set<String>>(
      {},
      (fields, doc) =>
          fields..addAll((doc.data()! as Map<String, dynamic>).keys),
    ).toList();

extension FirebaseFirestoreExtensions on FirebaseFirestore {
  /// Returns a stream of snapshots from Firestore
  Stream<QuerySnapshot<Map<String, dynamic>>> getStream() => collection('stuff')
      //.where('test2', isEqualTo: 'fdfd')
      .orderBy('test2')
      //.limit(2)
      .snapshots();
}
