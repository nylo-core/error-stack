import 'package:nylo_support/helpers/backpack.dart';
import '/error_stack.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nylo_support/helpers/extensions.dart';
import 'package:nylo_support/helpers/helper.dart';
import 'package:nylo_support/widgets/ny_state.dart';
import 'package:nylo_support/widgets/ny_stateful_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class ErrorStackDebugWidget extends NyStatefulWidget {
  static const path = '/error-stack-debug';
  final FlutterErrorDetails errorDetails;

  ErrorStackDebugWidget({super.key, required this.errorDetails}) : super(path);

  @override
  createState() => _ErrorStackDebugWidget();
}

class _ErrorStackDebugWidget extends NyState<ErrorStackDebugWidget> {
  String? _themeMode;
  String? _className;

  @override
  init() async {
    String? themeMode = await NyStorage.read(ErrorStack.storageKey);
    _themeMode = themeMode == 'dark' ? 'dark' : 'light';
    _className = className();
  }

  /// Get the class name
  String className() {
    String stack = widget.errorDetails.stack.toString();
    RegExp regExp = RegExp(r'(\(package:([A-z\/.:0-9]+)\))');

    Iterable<RegExpMatch> regMatches = regExp.allMatches(stack);

    if (regMatches.isNotEmpty) {
      _className = regMatches.first.group(0);
    }

    if (_className == null) return "";

    String inputString = _className!;
    RegExp pattern = RegExp(r'^\(.*?\/');
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
                          color: _themeMode == "light"
                              ? Colors.grey.shade100
                              : "#13151a".toHexColor(),
                        ),
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
                                            className(),
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
                                color: _themeMode == 'light'
                                    ? "#282c34".toHexColor()
                                    : Colors.white.withOpacity(0.2),
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
                                    ? "#0045a0".toHexColor()
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        String initialRoute = Backpack.instance
                            .read("${ErrorStack.storageKey}_initial_route");
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
                    color: _themeMode == "light" ? Colors.black : Colors.white,
                  ),
                  onPressed: () async {
                    if (_themeMode == 'light') {
                      _themeMode = 'dark';
                    } else {
                      _themeMode = 'light';
                    }
                    await NyStorage.store(ErrorStack.storageKey, _themeMode);
                    setState(() {});
                  }),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Text(
                "ErrorStack v1.0.0",
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
