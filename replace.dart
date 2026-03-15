import 'dart:io';

void main() {
  for (var path in ['lib/connexion.dart', 'lib/inscription.dart']) {
    var file = File(path);
    if (!file.existsSync()) continue;
    var content = file.readAsStringSync();
    content = content.replaceAll(
      RegExp(r"locProvider\.translate\('([^']+)'\)"),
      r"'$1'.tr()",
    );
    content = content.replaceAll(
      "import 'package:sahtek/providers/localization_provider.dart';",
      "import 'package:easy_localization/easy_localization.dart';",
    );
    content = content.replaceAll(
      RegExp(
        r"\s*final locProvider = context\.watch<LocalizationProvider>\(\);",
      ),
      "",
    );
    content = content.replaceAll(
      "locProvider.toggleLanguage();",
      "if (context.locale.languageCode == 'fr') { context.setLocale(const Locale('en')); } else { context.setLocale(const Locale('fr')); }",
    );
    content = content.replaceAll(
      "locProvider.currentLanguage",
      "context.locale.languageCode",
    );
    file.writeAsStringSync(content);
  }

  // Nettoyage main.dart
  var mainFile = File('lib/main.dart');
  if (mainFile.existsSync()) {
    var content = mainFile.readAsStringSync();
    content = content.replaceAll(
      "import 'package:sahtek/providers/localization_provider.dart';\n",
      "",
    );
    mainFile.writeAsStringSync(content);
  }
}
