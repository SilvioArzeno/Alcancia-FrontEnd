import 'package:alcancia/src/features/registration/provider/registration_controller_provider.dart';
import 'package:alcancia/src/features/registration/provider/timer_provider.dart';
import 'package:alcancia/src/resources/colors/colors.dart';
import 'package:alcancia/src/shared/components/alcancia_components.dart';
import 'package:alcancia/src/shared/provider/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OTPScreen extends ConsumerStatefulWidget {
  const OTPScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final codeController = TextEditingController();

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phoneNumber = ref.watch(userProvider)?.phoneNumber;
    final timer = ref.watch(timerProvider);
    final registrationController = ref.watch(registrationControllerProvider);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: AlcanciaLogo(),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(0.0),
                        child: Text(
                          "Ya casi \nterminamos,",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 35),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                            "Ingresa el código de 6 dígitos que enviamos a tu celular ${phoneNumber}"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LabeledTextFormField(
                            controller: codeController,
                            autofillHints: [AutofillHints.oneTimeCode],
                            labelText: "Código"),
                      ),
                      StreamBuilder<int>(
                          stream: timer.rawTime,
                          initialData: 0,
                          builder: (BuildContext context,
                              AsyncSnapshot snapshot) {
                            final value = snapshot.data;
                            final displayTime =
                            StopWatchTimer.getDisplayTime(value,
                                hours: false, milliSecond: false);
                            return Center(
                              child: Container(
                                decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(100),
                                        side: BorderSide(
                                            color: alcanciaLightBlue))),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.timer_sharp,
                                        color: alcanciaLightBlue,
                                      ),
                                      Text(
                                        displayTime,
                                        style: TextStyle(
                                            color: alcanciaLightBlue),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("¿No recibiste el código?"),
                          CupertinoButton(
                              child: const Text(
                                "Reenviar",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                  color: alcanciaLightBlue,
                                ),
                              ),
                              onPressed: () {}),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 25,
                            child: Checkbox(
                                value: false,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (value) {}),
                          ),
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text(
                                  "He leído y acepto la Política de Privacidad y Tratamiento de Datos"),
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child:
                        AlcanciaButton(
                          buttonText: "Crea tu cuenta",
                          onPressed: () async {
                            final validOTP = await registrationController.verifyOTP(codeController.text, phoneNumber!);
                            if (validOTP) {
                              context.go("/dashboard");
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
