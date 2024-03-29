import 'package:alcancia/src/resources/colors/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AlcanciaDatePicker extends ConsumerWidget {
  const AlcanciaDatePicker({
    Key? key,
    required this.dateProvider,
    this.maximumDate,
    this.validator,
  }) : super(key: key);

  final AutoDisposeStateProvider<DateTime> dateProvider;
  final DateTime? maximumDate;
  final String? Function(DateTime?)? validator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(dateProvider);
    final appLoc = AppLocalizations.of(context)!;
    return FormField<DateTime>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Text(appLoc.labelBirthdate),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor,
                border: !state.hasError ? null : Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(7),
              ),
              child: CupertinoButton(
                child: Row(
                  children: [
                    Text(
                      DateFormat.yMMMMd(
                              Localizations.localeOf(context).toString())
                          .format(date),
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .subtitle2
                              ?.color
                              ?.withOpacity(0.6)),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.calendar_today,
                      color: alcanciaMidBlue,
                    ),
                  ],
                ),
                onPressed: () {
                  // Show custom pop-up menu
                  showCupertinoModalPopup(
                      context: context,
                      builder: (cxt) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.3,
                          color: CupertinoColors.systemBackground
                              .resolveFrom(context),
                          child: SafeArea(
                              child: CupertinoDatePicker(
                            initialDateTime: date,
                            maximumDate: maximumDate,
                            mode: CupertinoDatePickerMode.date,
                            onDateTimeChanged: (DateTime newDate) {
                              ref.read(dateProvider.notifier).state = newDate;
                              state.didChange(newDate);
                            },
                          )),
                        );
                      });
                },
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 10),
                ),
              ),
          ],
        );
      },
      validator: validator,
    );
  }
}
