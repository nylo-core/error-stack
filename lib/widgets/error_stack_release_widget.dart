import 'package:flutter/material.dart';
import 'package:nylo_support/widgets/ny_state.dart';
import 'package:nylo_support/widgets/ny_stateful_widget.dart';

class ErrorStackReleaseWidget extends NyStatefulWidget {
  static const path = '/error-stack-release';
  final FlutterErrorDetails errorDetails;

  ErrorStackReleaseWidget({super.key, required this.errorDetails}) : super(path);

  @override
  createState() => _ErrorStackReleaseWidget();
}

class _ErrorStackReleaseWidget extends NyState<ErrorStackReleaseWidget> {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
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
                    Text("Unfortunately, an error occurred."),
                    Text("Please restart the app or report this issue."),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
