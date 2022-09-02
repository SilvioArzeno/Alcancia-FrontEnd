import 'package:alcancia/src/features/dashboard/data/transactions_query.dart';
import 'package:alcancia/src/features/dashboard/presentation/navbar.dart';
import 'package:alcancia/src/shared/components/alcancia_components.dart';
import 'package:alcancia/src/shared/services/storage_service.dart';
import 'package:alcancia/src/features/dashboard/presentation/dashboard_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({Key? key}) : super(key: key);

  final StorageService _storageService = StorageService();

  String getImageType(String txnType) {
    if (txnType == "WITHDRAW") {
      return "lib/src/resources/images/withdraw.svg";
    }
    return "lib/src/resources/images/deposit.svg";
  }

  @override
  Widget build(BuildContext context) {
    var ctx = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _storageService.readSecureData("token"),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              var uri = dotenv.env['API_URL'] as String;
              var token = snapshot.data;

              final HttpLink httpLink = HttpLink(
                uri,
                defaultHeaders: <String, String>{
                  'Authorization': 'Bearer $token'
                },
              );

              final ValueNotifier<GraphQLClient> anotherClient = ValueNotifier(
                GraphQLClient(
                  cache: GraphQLCache(),
                  link: httpLink,
                ),
              );

              return GraphQLProvider(
                client: anotherClient,
                child: Query(
                  options: QueryOptions(
                    document: gql(transactionsQuery),
                    variables: const {
                      "userTransactionsInput": {
                        "currentPage": 0,
                        "itemsPerPage": 3,
                      },
                    },
                  ),
                  builder: (QueryResult result,
                      {VoidCallback? refetch, FetchMore? fetchMore}) {
                    if (result.hasException) {
                      print(result.exception?.graphqlErrors.first);
                      return Text("error");
                    }

                    if (result.isLoading) {
                      return Text("is loading...");
                    }

                    var response = result.data?['getUserTransactions'];

                    return Container(
                      padding: EdgeInsets.only(
                        left: 24,
                        right: 24,
                        bottom: 24,
                        top: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Navbar(),
                          Container(
                            padding: EdgeInsets.only(bottom: 16),
                            child: MyWidget(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 22),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Actividad",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                AlcanciaButton(
                                  buttonText: "Ver más",
                                  onPressed: () {},
                                  color: Color(0x00FFFFFF),
                                  rounded: true,
                                  height: 24,
                                ),
                              ],
                            ),
                          ),
                          if (response['totalItems'] == 0)
                            Text(
                              "Sin registros aún...",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          for (var txn in response['items'])
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        getImageType(txn['type']),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              txn['type'],
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            Text(
                                                "${txn['createdAt'].toString().split(' ')[0]} ${txn['createdAt'].toString().split(' ')[1]} ${txn['createdAt'].toString().split(' ')[2]}"),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                          "${txn['sourceAmount']} ${txn['sourceAsset']}"),
                                      Text(
                                          "${txn['amount']} ${txn['targetAsset']}"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
