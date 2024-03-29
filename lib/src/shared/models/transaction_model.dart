import 'dart:convert';

import 'package:alcancia/src/shared/models/currency_asset.dart';
import 'package:alcancia/src/shared/models/transaction_input_model.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Transaction {
  String transactionID;
  DateTime createdAt;
  double? sourceAmount;
  String sourceAsset;
  String? targetAsset;
  double amount;
  TransactionType type;
  TransactionStatus status;
  String? senderId;
  String? receiverId;
  String? concept;

  Transaction({
    required this.transactionID,
    required this.createdAt,
    required this.sourceAmount,
    required this.sourceAsset,
    required this.targetAsset,
    required this.amount,
    required this.type,
    required this.status,
    required this.senderId,
    required this.receiverId,
    required this.concept,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final targetAsset = json["targetAsset"];
    final sourceAsset = json["sourceAsset"];
    final createdAt = DateTime.parse(json["createdAt"]);
    final method = jsonDecode(json["method"] ?? "null");
    final String? concept = method == null || method is String ? null : method["concepto"];
    return Transaction(
        transactionID: json["id"] as String,
        createdAt: createdAt,
        sourceAmount: double.tryParse(json["sourceAmount"].toString()),
        sourceAsset:
            CurrencyAsset.values.firstWhereOrNull((e) => e.actualAsset.toLowerCase() == sourceAsset.toString().toLowerCase())?.shownAsset ?? sourceAsset,
        targetAsset:
            CurrencyAsset.values.firstWhereOrNull((e) => e.actualAsset.toLowerCase() == targetAsset.toString().toLowerCase())?.shownAsset ?? targetAsset,
        amount: double.parse(json["amount"].toString()),
        type: TransactionType.values.firstWhere((e) => e.name.toUpperCase() == json["type"], orElse: () => TransactionType.unknown),
        status: TransactionStatus.values.firstWhere((e) => e.name.toUpperCase() == json["status"], orElse: () => TransactionStatus.unknown),
        senderId: json["senderId"],
        receiverId: json["receiverId"],
      concept: concept,
    );
  }
}

extension StatusIcon on Transaction {
  Widget iconForTxnStatus(String currentUserId) {
    if (status == TransactionStatus.pending) return SvgPicture.asset("lib/src/resources/images/pending.svg", width: 24,);
    if (status == TransactionStatus.completed) {
      if (type == TransactionType.deposit || receiverId == currentUserId) return SvgPicture.asset("lib/src/resources/images/deposit.svg", width: 24,);
      if (type == TransactionType.withdraw || senderId == currentUserId) return SvgPicture.asset("lib/src/resources/images/withdrawal.svg", width: 24,);
    }
    // FAILED, EXPIRED OR UNKNOWN
    return SvgPicture.asset("lib/src/resources/images/failed.svg", width: 24,);
  }
}

enum TransactionStatus { pending, completed, failed, expired, cancelled, unknown }
