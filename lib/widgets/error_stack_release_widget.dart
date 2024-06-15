import 'package:flutter/material.dart';

/// Widget to display a release error stack.
/// This widget is displayed when the app is in release mode.
/// It displays a simple error message.
class ErrorStackReleaseWidget extends StatefulWidget {
  final FlutterErrorDetails errorDetails;

  const ErrorStackReleaseWidget({super.key, required this.errorDetails});

  @override
  createState() => _ErrorStackReleaseWidget();
}

class _ErrorStackReleaseWidget extends State<ErrorStackReleaseWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: const [
              SizedBox(
                height: 450,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 50.0,
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              'Oops, something went wrong!',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16.0),
                            Divider(),
                            Text("An error occurred."),
                            Text(
                                "Please restart the app or report this issue."),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
