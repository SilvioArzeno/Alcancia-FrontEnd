import 'package:alcancia/src/shared/extensions/type_extensions.dart';
import 'package:alcancia/src/shared/models/transaction_input_model.dart';
import 'package:alcancia/src/shared/models/transaction_model.dart';
import "package:flutter/material.dart";
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AlcanciaTransactionItem extends StatelessWidget {
  Transaction txn;
  AlcanciaTransactionItem({Key? key, required this.txn}) : super(key: key);

  String getImageType(String txnType) {
    if (txnType == "WITHDRAW") {
      return "lib/src/resources/images/withdraw.svg";
    }
    return "lib/src/resources/images/deposit.svg";
  }

  @override
  Widget build(BuildContext context) {
    var txtTheme = Theme.of(context).textTheme;
    final appLoc = AppLocalizations.of(context)!;
    return InkWell(
        customBorder:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: () {
          context.push('/transaction_detail', extra: txn);
        },
        child: TransactionItem(txn: txn,));
  }
}

class TransactionItem extends StatelessWidget {
  const TransactionItem({Key? key, required this.txn}) : super(key: key);

  final Transaction txn;

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context)!;
    final txtTheme = Theme.of(context).textTheme;
    switch (txn.type) {
      case TransactionType.deposit:
        return Container(
          padding:
          const EdgeInsets.only(top: 12, bottom: 12, left: 12, right: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  txn.iconForTxnStatus,
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${txn.type.typeToString(appLoc)} ${txn.sourceAsset}",
                          style: txtTheme.bodyText2,
                        ),
                        Text(
                          txn.createdAt.substring(0, 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("\$${txn.sourceAmount?.toStringAsFixed(2)}"),
                        Text(
                            "\$${txn.amount.toStringAsFixed(2)} ${txn.targetAsset}"),
                      ],
                    ),
                  ),
                  SvgPicture.asset(
                    "lib/src/resources/images/white_arrow_right.svg",
                  )
                ],
              ),
            ],
          ),
        );
      case TransactionType.withdraw:
        return Container(
          padding:
          const EdgeInsets.only(top: 12, bottom: 12, left: 12, right: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  txn.iconForTxnStatus,
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${txn.type.typeToString(appLoc)} ${txn.sourceAsset}",
                          style: txtTheme.bodyText2,
                        ),
                        Text(
                          txn.createdAt.substring(0, 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("\$${txn.sourceAmount?.toStringAsFixed(2)}"),
                        Text(
                            "\$${txn.amount.toStringAsFixed(2)} ${txn.targetAsset}"),
                      ],
                    ),
                  ),
                  SvgPicture.asset(
                    "lib/src/resources/images/white_arrow_right.svg",
                  )
                ],
              ),
            ],
          ),
        );
      case TransactionType.p2p:
        return Container(
          padding:
          const EdgeInsets.only(top: 12, bottom: 12, left: 12, right: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  txn.iconForTxnStatus,
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${txn.type.typeToString(appLoc)} ${txn.sourceAsset}",
                          style: txtTheme.bodyText2,
                        ),
                        Text(
                          txn.createdAt.substring(0, 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                        "\$${txn.amount.toStringAsFixed(2)} ${txn.sourceAsset}"),
                  ),
                  SvgPicture.asset(
                    "lib/src/resources/images/white_arrow_right.svg",
                  )
                ],
              ),
            ],
          ),
        );
      case TransactionType.unknown:
        return Container(
          padding:
          const EdgeInsets.only(top: 12, bottom: 12, left: 12, right: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  txn.iconForTxnStatus,
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${txn.type.typeToString(appLoc)} ${txn.sourceAsset}",
                          style: txtTheme.bodyText2,
                        ),
                        Text(
                          txn.createdAt.substring(0, 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("\$${txn.sourceAmount?.toStringAsFixed(2)}"),
                        Text(
                            "${txn.amount.toStringAsFixed(2)} ${txn.targetAsset ?? txn.sourceAsset}"),
                      ],
                    ),
                  ),
                  SvgPicture.asset(
                    "lib/src/resources/images/white_arrow_right.svg",
                  )
                ],
              ),
            ],
          ),
        );
    }
  }
}

