import '/error_net.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nylo_support/helpers/extensions.dart';
import 'package:nylo_support/helpers/helper.dart';
import 'package:nylo_support/router/router.dart';
import 'package:nylo_support/widgets/ny_state.dart';
import 'package:nylo_support/widgets/ny_stateful_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class ErrorNetWidget extends NyStatefulWidget {
  static const path = '/error-net';
  final FlutterErrorDetails errorDetails;

  ErrorNetWidget({super.key, required this.errorDetails}) : super(path);

  @override
  createState() => _ErrorNetWidget();
}

class _ErrorNetWidget extends NyState<ErrorNetWidget> {
  String? _themeMode;
  String? _className;

  @override
  init() async {
    String? themeMode = await NyStorage.read(ErrorNet.storageKey);
    _themeMode = themeMode == 'dark' ? 'dark' : 'light';

    _findClassName();
  }

  /// Find the class name from the error stack
  _findClassName() {
    String stack = widget.errorDetails.stack.toString();
    RegExp regExp = RegExp(r'(\(package:[A-z\/.:0-9]+\))');

    Iterable<RegExpMatch> regMatches = regExp.allMatches(stack);

    if (regMatches.isNotEmpty) {
      _className = regMatches.first.group(0);
    }
  }

  /// Get the class name
  String get className {
    String className = _className!.replaceAll("(", "").replaceAll(")", "");
    return className.replaceAll(r'package:[A-z\_]+', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _themeMode == "light" ? Colors.white : "#282c34".toHexColor(),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50.0,
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      'Error Occurred!',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: _themeMode == "light"
                              ? Colors.black
                              : Colors.white),
                    ),
                    const SizedBox(height: 16.0),
                    const Divider(),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.grey.shade100),
                        child: Column(
                          children: [
                            Container(
                              height: 30,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              width: double.infinity,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: afterNotNull(_className, child: () {
                                      return Container(
                                          width: double.infinity,
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Text(
                                            className,
                                            textAlign: TextAlign.left,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ));
                                    },
                                        loading: const SizedBox(
                                          height: 15,
                                        )),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.copy, size: 15),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                              text:
                                                  "${widget.errorDetails.exceptionAsString()} flutter"))
                                          .then((_) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                          'Copied to your clipboard!',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        )));
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: "#282c34".toHexColor(),
                              ),
                              child: Text(
                                widget.errorDetails.exceptionAsString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: "#d8b576".toHexColor(),
                                  fontWeight: FontWeight.bold,
                                ),
                              ).paddingSymmetric(horizontal: 16),
                            ),
                          ],
                        )),
                    const SizedBox(height: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Operating System Version",
                          style: TextStyle(
                            color: _themeMode == "light"
                                ? Colors.black54
                                : Colors.grey,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          Platform.operatingSystemVersion,
                          style: TextStyle(
                            color: _themeMode == "light"
                                ? Colors.black
                                : Colors.white,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          "Operating System",
                          style: TextStyle(
                            color: _themeMode == "light"
                                ? Colors.black54
                                : Colors.grey,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          Platform.operatingSystem,
                          style: TextStyle(
                            color: _themeMode == "light"
                                ? Colors.black
                                : Colors.white,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 16),
                    const SizedBox(height: 20.0),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8)),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search),
                          CupertinoButton(
                            onPressed: () {
                              String exception =
                                  "${widget.errorDetails.exceptionAsString()}%20flutter";
                              String encodedQuery =
                                  Uri.encodeQueryComponent(exception);

                              launchUrl(Uri.parse(
                                  "https://www.google.com/search?q=$encodedQuery"));
                            },
                            child: const Text(
                              "Search Google for this error",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                // color: _themeMode == "light" ? Colors.blueAccent : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          routeToInitial();
                        },
                        child: Text(
                          "Restart app",
                          style: TextStyle(
                            color: _themeMode == "light"
                                ? Colors.grey
                                : Colors.white,
                          ),
                        ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                  // dark mode / light mode
                  icon: Icon(
                    _themeMode == "light"
                        ? Icons.brightness_4
                        : Icons.brightness_7,
                    color: _themeMode == "light" ? Colors.black : Colors.white,
                  ),
                  onPressed: () async {
                    if (_themeMode == 'light') {
                      _themeMode = 'dark';
                    } else {
                      _themeMode = 'light';
                    }
                    await NyStorage.store(ErrorNet.storageKey, _themeMode);
                    setState(() {});
                  }),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Text(
                "ErrorNet v1.0.0",
                style: TextStyle(
                  color:
                      _themeMode == 'light' ? Colors.black54 : Colors.white70,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
