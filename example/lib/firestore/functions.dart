import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selecta/model/model.dart';
import 'package:selecta/model/order_by.dart';

/// Returns a list of fields from a list of documents
List<String> getFields(List<QueryDocumentSnapshot<Object?>> docs) =>
    docs.fold<Set<String>>(
      {},
      (fields, doc) =>
          fields..addAll((doc.data()! as Map<String, dynamic>).keys),
    ).toList();

/// An extension on [FirebaseFirestore] that returns a stream of snapshots
extension FirebaseFirestoreExtensions on FirebaseFirestore {
  /// Returns a stream of snapshots from Firestore
  Stream<QuerySnapshot<Map<String, dynamic>>> getStream(
    SelectStatement selectStatement,
  ) {
    var colRef = collection('stuff') as Query<Map<String, dynamic>>;

    for (final where in selectStatement.where.elements) {
      //This is very basic. It doesn't deal with brackets
      if (where case final WhereCondition ad)
        colRef = colRef.where(ad.leftOperand, isEqualTo: ad.rightOperand);
    }

    for (final where in selectStatement.orderBy) {
      if (where case final OrderByColumn obc)
        colRef = colRef.orderBy(
          obc.columnName,
          descending: obc.direction == SortDirection.descending,
        );
    }

    return colRef.snapshots();
  }
}
