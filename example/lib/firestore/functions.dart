
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
    var colRef =
        collection(selectStatement.from) as Query<Map<String, dynamic>>;

    for (final where in selectStatement.where.elements) {
      //This is very basic. It doesn't deal with brackets
      if (where is WhereCondition) {
        if (where.leftOperand case final ColumnReferenceOperand cro) {
          if (where.rightOperand case final StringLiteralOperand slo)
            colRef = colRef.where(cro.value, isEqualTo: slo.value);
          else if (where.rightOperand case final NumberLiteralOperand nlo)
            colRef = colRef.where(cro.value, isEqualTo: nlo.value);
        }
      }
    }

    for (final element in selectStatement.orderBy) {
      if (element case final OrderByColumn obc)
        colRef = colRef.orderBy(
          obc.columnName,
          descending: obc.direction == SortDirection.descending,
        );
    }

    return colRef.snapshots();
  }
}
