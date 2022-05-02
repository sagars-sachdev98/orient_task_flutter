import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CommonUi {
  Future<void> loadingDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Column(mainAxisSize: MainAxisSize.min, children: [
            Lottie.asset(
              'assets/images/load.json',
              alignment: Alignment.center,
              fit: BoxFit.cover,
              height: 100,
              width: 100,
            ),
            const SizedBox(
              height: 12,
            ),
            Text("Loading...", style: Theme.of(context).textTheme.bodyMedium)
          ]),
        );
      },
    );
  }
}
