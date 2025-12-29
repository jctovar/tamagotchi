import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/credit_model.dart';

class Services {
  static Future<List<CreditModel>> readJsonCredits() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/credits.json',
      );
      final data = await json.decode(response);

      final credits = (data["RECORDS"] as List)
          .map((x) => CreditModel.fromJson(x))
          .toList();

      return credits;
    } catch (e) {
      rethrow;
    }
  }
}
