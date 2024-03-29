import 'package:alcancia/src/resources/colors/colors.dart';
import 'package:alcancia/src/screens/transfer/transfer_controller.dart';
import 'package:alcancia/src/shared/components/alcancia_components.dart';
import 'package:alcancia/src/shared/components/alcancia_confirmation_dialog.dart';
import 'package:alcancia/src/shared/components/alcancia_dropdown.dart';
import 'package:alcancia/src/shared/components/alcancia_toolbar.dart';
import 'package:alcancia/src/shared/components/decimal_input_formatter.dart';
import 'package:alcancia/src/shared/provider/alcancia_providers.dart';
import 'package:alcancia/src/shared/provider/balance_provider.dart';
import 'package:alcancia/src/shared/services/responsive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final List<Map> countries = [
    {
      "value": "MX",
      "name": "+52",
      "icon": "lib/src/resources/images/icon_mexico_flag.png"
    },
    {
      "value": "CO",
      "name": "+57",
      "icon": "lib/src/resources/images/icon_colombia_flag.png"
    },
    {
      "value": "DO",
      "name": "+1",
      "icon": "lib/src/resources/images/icon_dominican_flag.png"
    },
    {
      "value": "US",
      "name": "+1",
      "icon": "lib/src/resources/images/icon_us_flag.png"
    },
    {
      "value": "ES",
      "name": "+34",
      "icon": "lib/src/resources/images/icon_spain_flag.png"
    },
  ];
  late String countryCode = countries.first['name'];

  final _responsiveService = ResponsiveService();

  final _formKey = GlobalKey<FormState>();

  bool _enableButton = false;
  bool _loading = false;

  String _error = "";
  String _transferError = "";

  final _phoneController = TextEditingController();
  final _transferAmountController = TextEditingController();

  final List<Map> sourceCurrencies = [
    {
      "name": "USDC",
      "icon": "lib/src/resources/images/icon_usdc.png",
      "value": "apolusdc",
    },
    /*{
      "name": "cUSD",
      "icon": "lib/src/resources/images/icon_celo_usd.png",
      "value": "cusd",
    },*/
  ];
  late String sourceCurrency = sourceCurrencies.first['value'];

  final transferController = TransferController();

  transferFunds(double amount, String currency, String destUserId) async {
    Navigator.pop(context);

    setState(() {
      _loading = true;
    });

    var transferResponse;

    try {
      transferResponse = await transferController.transferFunds(
        amount: amount.toStringAsFixed(2),
        destUserId: destUserId,
        token: currency,
      );
    } catch (transferError) {
      setState(() {
        _transferError = transferError.toString();
      });
    }

    setState(() {
      _loading = false;
    });

    if (_transferError.isEmpty) {
      context.goNamed('successful-transaction', extra: transferResponse);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final user = ref.read(userProvider);
    if (user?.country != null) {
      countryCode = countries
          .firstWhere((element) => element['value'] == user?.country)['name'];
    } else {
      countryCode = countries.first['name'];
    }
    final countryIndex =
        countries.indexWhere((element) => element['name'] == countryCode);
    final code = countries.removeAt(countryIndex);
    countries.insert(0, code);
  }

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context)!;
    final txtTheme = Theme.of(context).textTheme;
    final userBalance = ref.watch(balanceProvider);
    final balance = sourceCurrency == "apolusdc"
        ? userBalance.usdcBalance
        : userBalance.celoBalance;

    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AlcanciaToolbar(
          title: appLoc.labelTransfer,
          state: StateToolbar.titleIcon,
          logoHeight: 40,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,
            onChanged: () => setState(
                () => _enableButton = _formKey.currentState!.validate()),
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        appLoc.labelTransferPrompt,
                        style: txtTheme.bodyText1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Text(appLoc.labelRecipientPhone),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AlcanciaDropdown(
                                itemsAlignment: MainAxisAlignment.spaceBetween,
                                dropdownItems: countries,
                                dropdownWidth: _responsiveService
                                    .getWidthPixels(120, screenWidth),
                                dropdownHeight: 55.0,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .inputDecorationTheme
                                      .fillColor,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    countryCode = countries.firstWhere(
                                        (element) =>
                                            element['value'] == value)['name'];
                                    _enableButton =
                                        _formKey.currentState!.validate();
                                  });
                                },
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: TextFormField(
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    autofillHints: const [
                                      AutofillHints.telephoneNumber
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return appLoc.errorRequiredField;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 29, bottom: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Text(appLoc.labelTransferAmount),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AlcanciaDropdown(
                                itemsAlignment: MainAxisAlignment.spaceBetween,
                                dropdownItems: sourceCurrencies,
                                dropdownWidth: _responsiveService
                                    .getWidthPixels(120, screenWidth),
                                dropdownHeight: 55.0,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .inputDecorationTheme
                                      .fillColor,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              onChanged: (value) {
                                setState(() {
                                  sourceCurrency = value;
                                  _enableButton =
                                      _formKey.currentState!.validate();
                                });
                              },
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: TextFormField(
                                  style: Theme.of(context).textTheme.bodyText1,
                                  controller: _transferAmountController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    DecimalTextInputFormatter(decimalRange: 2)
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return appLoc.errorRequiredField;
                                    } else if (balance < double.parse(value)) {
                                      return appLoc.errorInsufficientBalance;
                                    } else if (double.parse(value) <= 0.1) {
                                      return appLoc.errorMinimumTransferAmount;
                                    }
                                    return null;
                                  },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(appLoc
                        .labelAvailableBalance(balance.toStringAsFixed(6))),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Center(
                        child: Column(
                          children: [
                            if (_loading) ...[
                              const CircularProgressIndicator(),
                            ] else ...[
                              if (balance <
                                  (double.tryParse(
                                          _transferAmountController.text) ??
                                      0)) ...[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: AlcanciaButton(
                                    buttonText: appLoc.buttonDeposit,
                                    onPressed: () {
                                      context.push("/deposit");
                                    },
                                    color: alcanciaLightBlue,
                                    width: 308,
                                    height: 64,
                                  ),
                                ),
                              ],
                              AlcanciaButton(
                                buttonText: appLoc.buttonNext,
                                // TODO: enableButton again
                                onPressed: _enableButton
                                    ? () async {
                                        setState(() {
                                          _loading = true;
                                        });
                                        try {
                                          final phoneNumber = countryCode +
                                              _phoneController.text;
                                          final currency = sourceCurrency;
                                          final amount = double.parse(
                                              _transferAmountController.text);
                                          final targetUser =
                                              await transferController
                                                  .searchUser(
                                                      phoneNumber: phoneNumber);
                                          showDialog(
                                            context: context,
                                            builder: (ctx) {
                                              return AlcanciaConfirmationDialog(
                                                targetUser: targetUser,
                                                userBalance: balance,
                                                amount: amount,
                                                currency:
                                                    sourceCurrency == "apolusdc"
                                                        ? "USDC"
                                                        : "CUSD",
                                                onConfirm: () {
                                                  transferFunds(amount,
                                                      currency, targetUser.id);
                                                },
                                              );
                                            },
                                          );
                                        } catch (e) {
                                          _error = e.toString();
                                        }
                                        setState(() {
                                          _loading = false;
                                        });
                                      }
                                    : null,
                                color: alcanciaLightBlue,
                                width: 308,
                                height: 64,
                              ),
                            ],
                            if (_error.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _error,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                            if (_transferError.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _transferError,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
