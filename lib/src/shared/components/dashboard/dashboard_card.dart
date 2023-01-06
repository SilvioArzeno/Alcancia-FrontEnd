import 'package:alcancia/src/resources/colors/colors.dart';
import 'package:alcancia/src/shared/components/alcancia_components.dart';
import 'package:alcancia/src/shared/provider/balance_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardCard extends ConsumerWidget {
  DashboardCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var ctx = Theme.of(context);
    var userBalance = ref.watch(balanceProvider);
    Object? balance = 0.0;
    if (userBalance?.balance != null) {
      balance = userBalance?.balance == 0.0
          ? 0
          : userBalance?.balance.toStringAsFixed(6);
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: ctx.brightness == Brightness.dark
            ? alcanciaCardDark2
            : alcanciaCardLight2,
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Balance",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            child: Text(
              "\$${balance} USDC",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AlcanciaButton(
                    buttonText: "Depositar",
                    onPressed: () {
                      context.push("/swap");
                    },
                    width: 116,
                    height: 38,
                    color: alcanciaMidBlue,
                  ),
                  AlcanciaButton(
                    buttonText: "Retirar",
                    onPressed: () {},
                    width: 116,
                    height: 38,
                    color: alcanciaMidBlue,
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}