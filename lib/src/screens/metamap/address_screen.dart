import 'dart:convert';
import 'package:alcancia/src/resources/colors/colors.dart';
import 'package:alcancia/src/screens/metamap/address_controller.dart';
import 'package:alcancia/src/screens/metamap/metamap_controller.dart';
import 'package:alcancia/src/shared/components/alcancia_components.dart';
import 'package:alcancia/src/shared/components/alcancia_dropdown.dart';
import 'package:alcancia/src/shared/components/alcancia_toolbar.dart';
import 'package:alcancia/src/shared/models/address_model.dart';
import 'package:alcancia/src/shared/models/alcancia_models.dart';
import 'package:alcancia/src/shared/models/checkout_model.dart';
import 'package:alcancia/src/shared/models/transaction_input_model.dart';
import 'package:alcancia/src/shared/provider/alcancia_providers.dart';
import 'package:alcancia/src/shared/services/metamap_service.dart';
import 'package:alcancia/src/shared/services/responsive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({
    Key? key,
    required this.wrapper,
  }) : super(key: key);
  final Map wrapper;

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  final _streetController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _exNumberController = TextEditingController();
  final _inNumberController = TextEditingController();
  final _zipController = TextEditingController();

  final responsiveService = ResponsiveService();

  final MetaMapController metaMapController = MetaMapController();
  final AddressController addressController = AddressController();
  final MetamapService metamapService = MetamapService();
  late String selectedProfession = metaMapController.professions[0]["name"]!;

  final List<Map<String, String>> states = [
    {"value": "Aguascalientes", "name": "Aguascalientes"},
    {"value": "BajaCalifornia", "name": "Baja California"},
    {"value": "BajaCaliforniaSur", "name": "Baja California Sur"},
    {"value": "Campeche", "name": "Campeche"},
    {"value": "CDMX", "name": "CDMX"},
    {"value": "Chiapas", "name": "Chiapas"},
    {"value": "Chihuahua", "name": "Chihuahua"},
    {"value": "Coahuila", "name": "Coahuila"},
    {"value": "Colima", "name": "Colima"},
    {"value": "Durango", "name": "Durango"},
    {"value": "EdoMex", "name": "Estado de México"},
    {"value": "Guanajuato", "name": "Guanajuato"},
    {"value": "Guerrero", "name": "Guerrero"},
    {"value": "Hidalgo", "name": "Hidalgo"},
    {"value": "Jalisco", "name": "Jalisco"},
    {"value": "Michoacan", "name": "Michoacán"},
    {"value": "Morelos", "name": "Morelos"},
    {"value": "Nayarit", "name": "Nayarit"},
    {"value": "NuevoLeon", "name": "Nuevo León"},
    {"value": "Oaxaca", "name": "Oaxaca"},
    {"value": "Puebla", "name": "Puebla"},
    {"value": "Queretaro", "name": "Querétaro"},
    {"value": "QuintanaRoo", "name": "Quintana Roo"},
    {"value": "SanLuisPotosi", "name": "San Luis Potosí"},
    {"value": "Sinaloa", "name": "Sinaloa"},
    {"value": "Sonora", "name": "Sonora"},
    {"value": "Tabasco", "name": "Tabasco"},
    {"value": "Tamaulipas", "name": "Tamaulipas"},
    {"value": "Tlaxcala", "name": "Tlaxcala"},
    {"value": "Veracruz", "name": "Veracruz"},
    {"value": "Yucatan", "name": "Yucatán"},
    {"value": "Zacatecas", "name": "Zacatecas"}
  ];

  late String _selectedState = states.first["value"]!;
  bool _loadingCheckout = false;

  final metamapMexicanINEId = dotenv.env['MEXICO_INE_FLOW_ID'] as String;
  final jsonEncoder = const JsonEncoder();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appLocalization = AppLocalizations.of(context)!;
    final user = ref.watch(userProvider);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AlcanciaToolbar(
          state: StateToolbar.logoNoletters,
          logoHeight: responsiveService.getHeightPixels(40, screenHeight),
        ),
        body: SafeArea(
          bottom: false,
          child: Form(
            autovalidateMode: AutovalidateMode.always,
            child: ListView(
              padding: const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 32.0),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0, top: 24),
                  child: Center(
                    child: Text(appLocalization.labelWeNeedToKnowMore,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ),
                LabeledTextFormField(
                  controller: _streetController,
                  labelText: appLocalization.labelStreet,
                  inputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return appLocalization.errorRequiredField;
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                LabeledTextFormField(
                  controller: _exNumberController,
                  labelText: appLocalization.labelExteriorNumber,
                  inputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return appLocalization.errorRequiredField;
                    } else if (value.length > 25) {
                      return appLocalization.errorAddressNumberLength;
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                LabeledTextFormField(
                  controller: _inNumberController,
                  labelText: appLocalization.labelInteriorNumber,
                  inputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: (newValue) {
                    if (newValue != null && newValue.length > 25) return appLocalization.errorAddressNumberLength;
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                LabeledTextFormField(
                  controller: _neighborhoodController,
                  labelText: appLocalization.labelNeighborhood,
                  inputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return appLocalization.errorRequiredField;
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  appLocalization.labelState,
                ),
                AlcanciaDropdown(
                  dropdownItems: states,
                  itemsFontSize: 15,
                  itemsAlignment: MainAxisAlignment.start,
                  decoration: BoxDecoration(
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  onChanged: (newValue) {
                    final selected = states.firstWhere((element) => element["name"] == newValue);
                    final state = selected["value"];
                    setState(() {
                      _selectedState = state!;
                    });
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                LabeledTextFormField(
                  controller: _zipController,
                  labelText: appLocalization.labelZipCode,
                  inputType: TextInputType.text,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return appLocalization.errorRequiredField;
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  appLocalization.labelYourProfession,
                ),
                AlcanciaDropdown(
                  dropdownItems: metaMapController.professions,
                  itemsFontSize: 15,
                  itemsAlignment: MainAxisAlignment.start,
                  decoration: BoxDecoration(
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      selectedProfession = newValue;
                    });
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                if (_loadingCheckout) ...[
                  const CircularProgressIndicator(),
                ] else ...[
                  AlcanciaButton(
                    buttonText: appLocalization.buttonNext,
                    color: alcanciaLightBlue,
                    width: 304,
                    height: 64,
                    onPressed: () async {
                      final address = Address(
                        street: _streetController.text,
                        colonia: _neighborhoodController.text,
                        extNum: _exNumberController.text,
                        intNum: _inNumberController.text,
                        state: _selectedState,
                        zip: _zipController.text,
                      );

                      final User newUser = user!;
                      var jsonAddress = jsonEncode(address.toJson());
                      selectedProfession = selectedProfession.replaceAll(' ', '');
                      newUser.profession = selectedProfession;
                      newUser.address = jsonAddress;
                      ref.read(userProvider.notifier).setUser(newUser);
                      try {
                        await metaMapController.updateUser(address: jsonAddress, profession: selectedProfession);
                      } catch (e) {
                        Fluttertoast.showToast(msg: e.toString());
                        context.go('/');
                      }

                      if (!widget.wrapper['verified']) {
                        try {
                          // Metamap flow
                          await metamapService.showMatiFlow(metamapMexicanINEId, user.id, appLocalization);
                        } catch (e) {
                          Fluttertoast.showToast(msg: e.toString());
                        }
                        final updatedUser = await addressController.fetchUser();
                        ref.read(userProvider.notifier).setUser(updatedUser);
                        context.go('/');
                      } else {
                        final txnInput = widget.wrapper['txnInput'] as TransactionInput;
                        final orderInput = {
                          "orderInput": {
                            "from_amount": txnInput.sourceAmount.toString(),
                            "type": txnInput.txnType.name.toUpperCase(),
                            "from_currency": "MXN",
                            "network": txnInput.network,
                            "to_amount": txnInput.targetAmount.toString(),
                            "to_currency": txnInput.targetCurrency
                          }
                        };
                        try {
                          setState(() {
                            _loadingCheckout = true;
                          });
                          final order = await addressController.sendSuarmiOrder(orderInput);
                          final checkoutData = CheckoutModel(order: order, txnInput: txnInput);
                          context.pushNamed('checkout', extra: checkoutData);
                        } catch (e) {
                          Fluttertoast.showToast(msg: appLocalization.errorSomethingWentWrong, backgroundColor: Colors.red, textColor: Colors.white70);
                        }
                        setState(() {
                          _loadingCheckout = false;
                        });
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
