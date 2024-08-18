import 'package:cloud_firestore/cloud_firestore.dart';

List<String> getFields(List<QueryDocumentSnapshot<Object?>> docs) =>
    docs.fold<Set<String>>(
      {},
      (fields, doc) =>
          fields..addAll((doc.data()! as Map<String, dynamic>).keys),
    ).toList();

Stream<QuerySnapshot<Map<String, dynamic>>> getStream(
  FirebaseFirestore firestore,
) =>
    firestore
        .collection('stuff')
        //.where('test2', isEqualTo: 'fdfd')
        .orderBy('test2')
        //.limit(2)
        .snapshots();
