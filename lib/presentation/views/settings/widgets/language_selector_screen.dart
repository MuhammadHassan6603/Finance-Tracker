import 'package:finance_tracker/widgets/shared_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/localization_service.dart';
import '../../../../generated/l10n.dart';
import '../../../../viewmodels/locale_view_model.dart';

class LanguageSelectorScreen extends StatelessWidget {
  const LanguageSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeViewModel = Provider.of<LocaleViewModel>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: SharedAppbar(title: localizations.languageTitle),
      body: Column(
        children: [
          // System default option
          ListTile(
            title: Text(localizations.systemDefault),
            trailing: localeViewModel.isSystemDefault
                ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                : null,
            onTap: () {
              localeViewModel.useSystemLocale();
              Navigator.pop(context);
            },
          ),
          const Divider(),
          // Language options
          Expanded(
            child: ListView.builder(
              itemCount: LocalizationService.supportedLocales.length,
              itemBuilder: (context, index) {
                final locale = LocalizationService.supportedLocales[index];
                final languageName = LocalizationService.getLanguageName(locale);
                final isSelected = !localeViewModel.isSystemDefault &&
                    localeViewModel.locale?.languageCode == locale.languageCode;

                return ListTile(
                  title: Text(languageName),
                  subtitle: Text(locale.languageCode.toUpperCase()),
                  trailing: isSelected
                      ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                      : null,
                  onTap: () {
                    localeViewModel.setLocale(locale);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
