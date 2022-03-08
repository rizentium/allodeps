import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'td-locale-broadcaster.dart';


/* ====================================================
	Created by andy pangaribuan on 2020/06/04
	Copyright CT Corp Digital. All rights reserved.
===================================================== */
class TDAppTranslations {

  static Locale currentLocale;
  static Map<dynamic, dynamic> _localisedValues;


  static TDAppTranslations of(BuildContext context) => Localizations.of<TDAppTranslations>(context, TDAppTranslations);

  static Future<TDAppTranslations> load(Locale locale) async {
    currentLocale = locale;
    TDAppTranslations appTranslations = TDAppTranslations();
    String jsonContent = await rootBundle.loadString("assets/locale/localization_${locale.languageCode}.json");
    _localisedValues = json.decode(jsonContent);
    TDLocaleBroadcaster.fire(locale.languageCode);

    return appTranslations;
  }

  static String get currentLanguage => currentLocale.languageCode;

  static String text(String key) => _localisedValues[key] ?? "$key not found";

}
