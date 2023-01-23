import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class WebViewApp extends StatefulWidget {
  const WebViewApp({Key? key}) : super(key: key);

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("test webview"),
      ),
      body: FutureBuilder(
        future: _initWebView(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text('Loading...');
          }

          _controller = snapshot.data!;
          return WebViewWidget(controller: snapshot.data!);
        },
      ),
    );
  }

  // js -> flutter の呼び出し
  void jsMessageRecv(JavaScriptMessage result) async {
    print("js message: ${result.message}");

    // flutter -> js の呼び出し
    await _controller
        .runJavaScriptReturningResult("flutterMessage('${result.message}')");
  }

  Future<WebViewController> _initWebView() async {
    final webViewController = WebViewController();

    await webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    await webViewController.loadHtmlString(await _loadHtmlFromAssets());

    // js からのメッセージ受け取り設定
    await webViewController.addJavaScriptChannel('flutterApp',
        onMessageReceived: jsMessageRecv);

    // android debug
    if (webViewController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
    }

    return webViewController;
  }

  Future<String> _loadHtmlFromAssets() async {
    return await rootBundle.loadString('assets/contents/index.html');
  }
}
