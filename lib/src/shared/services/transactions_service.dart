import 'package:alcancia/src/shared/graphql/queries/transactions_query.dart';
import 'package:alcancia/src/shared/services/graphql_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/alcancia_models.dart';

class TransactionsService {
  late GraphQLConfig graphQLConfig;
  late Future<GraphQLClient> client;

  TransactionsService() {
    graphQLConfig = GraphQLConfig();
    client = graphQLConfig.clientToQuery();
  }

  Future<QueryResult> getUserTransactions(
    Map<String, dynamic> userTransactionsInput,
  ) async {
    var clientResponse = await client;
    return await clientResponse.query(
      QueryOptions(
        document: gql(transactionsQuery),
        variables: userTransactionsInput,
      ),
    );
  }

  List<Transaction> getTransactionsFromJson(Map<String, dynamic> json) {
    var items = json['items'];
    if (items == null) {
      return <Transaction>[];
    }

    return List<Transaction>.from(
      items.map((txn) => Transaction.fromJson(txn)),
    );
  }
}