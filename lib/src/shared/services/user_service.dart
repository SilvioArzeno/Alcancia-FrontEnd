import 'package:alcancia/src/shared/graphql/mutations/update_user_mutation.dart';
import 'package:alcancia/src/shared/graphql/queries/me_query.dart';
import 'package:alcancia/src/shared/graphql/queries/user_phone_number_search_query.dart';
import 'package:alcancia/src/shared/graphql/queries/walletbalance_query.dart';
import 'package:alcancia/src/shared/models/balance_history_model.dart';
import 'package:alcancia/src/shared/services/graphql_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../graphql/queries/history_balance.dart';

class UserService {
  late GraphQLConfig graphQLConfig;
  late Future<GraphQLClient> client;

  UserService() {
    graphQLConfig = GraphQLConfig();
    client = graphQLConfig.clientToQuery();
  }

  Future<QueryResult> getUser() async {
    var clientResponse = await client;
    return await clientResponse.query(
      QueryOptions(
        document: gql(meQuery),
      ),
    );
  }

  Future<QueryResult> getUserBalance() async {
    var clientResponse = await client;
    return await clientResponse.query(
      QueryOptions(
        document: gql(balanceQuery),
      ),
    );
  }

  Future<QueryResult> getUserBalanceHisotry() async {
    var clientResponse = await client;
    return await clientResponse.query(
      QueryOptions(
        document: gql(historyBalanceQuery),
      ),
    );
  }

  Future<QueryResult> updateUser({required Map<String, dynamic> info}) async {
    final clientResponse = await client;
    return await clientResponse.query(
      QueryOptions(
        document: gql(updateUserMutation),
        variables: {"updateUserInput": info},
      ),
    );
  }

  Future<QueryResult> searchUserFromPhoneNumber(
      {required String phoneNumber}) async {
    var clientResponse = await client;
    return await clientResponse.query(
      QueryOptions(
        document: gql(userPhoneNumberSearchQuery),
        variables: {"phoneNumber": phoneNumber},
      ),
    );
  }
}
