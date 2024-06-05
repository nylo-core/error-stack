import '/error_stack.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

/// ErrorStackDebugWidget
/// This widget is displayed when an error occurs in debug mode
/// It displays the error message, the class name, and the stack trace
/// It also allows the user to search for the error on Google
/// and restart the app
class ErrorStackDebugWidget extends StatefulWidget {
  static const path = '/error-stack-debug';
  final FlutterErrorDetails errorDetails;

  const ErrorStackDebugWidget({super.key, required this.errorDetails});

  @override
  createState() => _ErrorStackDebugWidget();
}

class _ErrorStackDebugWidget extends State<ErrorStackDebugWidget> {
  /// The theme mode
  String? _themeMode;

  /// The class name
  String? _className;

  @override
  initState() {
    super.initState();
    _init();
  }

  /// Initialize the widget
  _init() {
    _themeMode = ErrorStack.instance.themeMode == 'dark' ? 'dark' : 'light';
    setState(() {});
  }

  /// Get the class name
  String className() {
    String stack = widget.errorDetails.stack.toString();
    RegExp regExp = RegExp(r'(\(package:([A-z/.:0-9]+)\))');

    Iterable<RegExpMatch> regMatches = regExp.allMatches(stack);

    if (regMatches.isNotEmpty) {
      _className = regMatches.first.group(0);
    }

    if (_className == null) return "";

    String inputString = _className!;
    RegExp pattern = RegExp(r'^\(.*?/');
    String result = inputString
        .replaceAll(pattern, "/")
        .replaceAll("(", "")
        .replaceAll(")", "");

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _themeMode == "light" ? Colors.white : _hexColor("#282c34"),
      body: SafeArea(
          child: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 550,
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
                                color: _themeMode == "light"
                                    ? Colors.grey.shade100
                                    : _hexColor("#13151a"),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 30,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    width: double.infinity,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.only(
                                                bottom: 8),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Text(
                                              className(),
                                              textAlign: TextAlign.left,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(Icons.copy,
                                              size: 15,
                                              color: _themeMode == 'light'
                                                  ? Colors.black
                                                  : Colors.white),
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
                                                    fontWeight:
                                                        FontWeight.w600),
                                              )));
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: _themeMode == 'light'
                                          ? _hexColor("#282c34")
                                          : Colors.white.withOpacity(0.2),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Text(
                                        widget.errorDetails.exceptionAsString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: _hexColor("#d8b576"),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                          const SizedBox(height: 20.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
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
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Container(
                            decoration: BoxDecoration(
                                color: _themeMode == "light"
                                    ? Colors.grey.shade50
                                    : Colors.white.withOpacity(0.2),
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
                                  child: Text(
                                    "Search Google for this error",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _themeMode == "light"
                                          ? _hexColor("#0045a0")
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              String initialRoute =
                                  ErrorStack.instance.initialRoute;
                              Navigator.pushNamedAndRemoveUntil(
                                  context, initialRoute, (_) => false);
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
                          color: _themeMode == "light"
                              ? Colors.black
                              : Colors.white,
                        ),
                        onPressed: () async {
                          _themeMode == 'light'
                              ? _themeMode = 'dark'
                              : _themeMode = 'light';
                          await ErrorStack.instance.storage.write(
                              key: '${ErrorStack.storageKey}_theme_mode',
                              value: _themeMode!);
                          ErrorStack.instance.themeMode = _themeMode!;
                          setState(() {});
                        }),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Text(
                      "ErrorStack v1.4.0",
                      style: TextStyle(
                        color: _themeMode == 'light'
                            ? Colors.black54
                            : Colors.white70,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  /// Get the color from a hex string
  /// [hexColor] the hex color string
  Color _hexColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
