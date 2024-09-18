import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaymentService with ChangeNotifier {
  String? paymentIntent;

  Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      paymentIntent = json.decode(response.body)['id'];
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  Future<void> makePayment(BuildContext context,  amount) async {
    try {
      // Step 1: Create Payment Intent
      final intent = await createPaymentIntent(amount, 'USD');

      // Step 2: Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: intent['client_secret'],
          style: ThemeMode.light,
          merchantDisplayName: 'Ikay',
        ),
      );

      // Step 3: Present Payment Sheet
      await displayPaymentSheet(context);
    } catch (err) {
      print('Error during payment: $err');
      _showDialog(context, "Payment Initialization Failed", false);
    }
  }

  Future<void> displayPaymentSheet(BuildContext context) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        // Show success dialog
        _showDialog(context, "Payment Successful!", true);
        paymentIntent = null; // Clear paymentIntent
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      _showDialog(context, "Payment Failed", false);
    } catch (e) {
      print('$e');
    }
  }

  void _showDialog(BuildContext context, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.cancel,
              color: isSuccess ? Colors.green : Colors.red,
              size: 100.0,
            ),
            SizedBox(height: 10.0),
            Text(message),
          ],
        ),
      ),
    );
  }
}
