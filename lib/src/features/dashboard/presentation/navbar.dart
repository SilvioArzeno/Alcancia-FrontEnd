import 'package:alcancia/src/shared/components/alcancia_components.dart';
import 'package:alcancia/src/shared/graphql/queries.dart';
import 'package:alcancia/src/shared/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AlcanciaNavbar extends StatelessWidget {
  AlcanciaNavbar({Key? key}) : super(key: key);
  final StorageService _storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _storageService.readSecureData("token"),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var uri = dotenv.env['API_URL'] as String;
            var token = snapshot.data;
            print(token);

            final HttpLink httpLink = HttpLink(
              uri,
              defaultHeaders: <String, String>{
                'Authorization': 'Bearer $token'
              },
            );

            final ValueNotifier<GraphQLClient> myClient = ValueNotifier(
              GraphQLClient(
                cache: GraphQLCache(),
                link: httpLink,
              ),
            );
            return GraphQLProvider(
              client: myClient,
              child: Query(
                options: QueryOptions(
                  document: gql(meQuery),
                ),
                builder: (QueryResult result,
                    {VoidCallback? refetch, FetchMore? fetchMore}) {
                  print(result);
                  if (result.hasException) {
                    return Text("error");
                  }

                  if (result.isLoading) {
                    return Text("is loading...");
                  }
                  var userName = result.data?['me']['name'];

                  return Container(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              "lib/src/resources/images/profile.png",
                              width: 38,
                              height: 38,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: Text(
                                "Hola, ${userName}",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AlcanciaLogo(
                          height: 38,
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
