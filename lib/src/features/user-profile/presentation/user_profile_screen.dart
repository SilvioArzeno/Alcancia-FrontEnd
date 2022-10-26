import 'package:alcancia/src/resources/colors/colors.dart';
import 'package:alcancia/src/shared/components/alcancia_action_dialog.dart';
import 'package:alcancia/src/shared/components/alcancia_button.dart';
import 'package:alcancia/src/shared/components/alcancia_toolbar.dart';
import 'package:alcancia/src/shared/provider/auth_service_provider.dart';
import 'package:alcancia/src/shared/provider/user.dart';
import 'package:alcancia/src/shared/services/graphql_client_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfileScreen extends ConsumerWidget {
  UserProfileScreen({Key? key}) : super(key: key);

  final Uri url = Uri.parse('https://landing.alcancia.io/privacypolicy');
  final Uri url2 = Uri.parse('https://landing.alcancia.io/termsandconditions');

  final GraphqlService _gqlService = GraphqlService();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final authService = ref.watch(authServiceProvider(_gqlService));
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 10),
          child: Column(
            children: [
              AlcanciaToolbar(
                state: StateToolbar.titleIcon,
                logoHeight: 38,
                title: "Perfil",
              ),
              _profileCard(context, user!),
              GestureDetector(
                onTap: () {
                  _launchUrl(url2);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.info_outline),
                      ),
                      Text(
                        "Términos y condiciones",
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Spacer(),
                      Icon(Icons.chevron_right)
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _launchUrl(url);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.info_outline),
                      ),
                      Text(
                        "Políticas de Privacidad",
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Spacer(),
                      Icon(Icons.chevron_right)
                    ],
                  ),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AlcanciaButton(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                  buttonText: "Borrar cuenta",
                  fontSize: 18,
                  padding: const EdgeInsets.only(
                      left: 24.0, right: 24.0, top: 4.0, bottom: 4.0),
                  onPressed: () async {
                    await showDialog(
                        context: context,
                        builder: (BuildContext ctx) {
                          return AlcanciaActionDialog(
                              child: Text(
                                "¿Seguro que quieres borrar tu cuenta?\nEsta acción no se puede deshacer.",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              acceptText: "Confirmar",
                              acceptColor: Colors.red,
                              cancelText: "Cancelar",
                              acceptAction: () async {
                                try {
                                  await authService.deleteAccount();
                                  context.go("/");
                                  ref.read(userProvider.notifier).setUser(null);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(_snackBar(context, "Hubo un problema al borrar tu cuenta."));
                                }
                              });
                        });
                  },
                  rounded: true,
                  icon: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.delete_forever),
                  ),
                )
              ),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AlcanciaButton(
                    foregroundColor: alcanciaLightBlue,
                    side: BorderSide(color: alcanciaLightBlue),
                    buttonText: "Cerrar sesión",
                    fontSize: 18,
                    padding: const EdgeInsets.only(
                        left: 24.0, right: 24.0, top: 4.0, bottom: 4.0),
                    onPressed: () async {
                      await showDialog(
                          context: context,
                          builder: (BuildContext ctx) {
                            return AlcanciaActionDialog(
                                child: Text(
                                  "¿Seguro que quieres cerrar sesión?",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                acceptText: "Confirmar",
                                acceptColor: Colors.red,
                                cancelText: "Cancelar",
                                acceptAction: () async {
                                  try {
                                    await authService.logout();
                                    context.go("/");
                                    ref.read(userProvider.notifier).setUser(null);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(_snackBar(context, "Hubo un problema al cerrar sesión"));
                                  }
                                });
                          });
                    },
                    rounded: true,
                    icon: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.delete_forever),
                    ),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileCard(BuildContext context, User user) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? alcanciaCardDark2
              : alcanciaCardLight2,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 48.0, right: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipOval(
                  child: SizedBox.fromSize(
                    size: Size.fromRadius(48), // Image radius
                    child: Image.asset(
                      "lib/src/resources/images/profile.png",
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    "${user.name} ${user.surname}",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(user.email),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  SnackBar _snackBar(BuildContext context, String string) {
    return SnackBar(
      content: Text(
        string,
        style: Theme.of(context).textTheme.bodyText2,
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
      duration: Duration(seconds: 5),
    );
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }
}