import 'dart:io';
import 'dart:async';

class InternetSpeedTester {
  static Future<double> testDownloadSpeed() async {
    final stopwatch = Stopwatch()..start();
    const url = 'http://ipv4.download.thinkbroadband.com/10MB.zip';
    final request = await HttpClient().getUrl(Uri.parse(url));
    final response = await request.close();
    final bytes = await consolidateHttpClientResponseBytes(response);
    stopwatch.stop();

    final durationInSeconds = stopwatch.elapsedMilliseconds / 1000;
    final speedInMbps = (bytes.length * 8) / (durationInSeconds * 1000000);

    print(
        "Downloaded ${bytes.length} bytes in $durationInSeconds seconds, speed: $speedInMbps Mbps");

    return speedInMbps;
  }

  static Future<List<int>> consolidateHttpClientResponseBytes(
      HttpClientResponse response) {
    final Completer<List<int>> completer = Completer<List<int>>();
    final List<List<int>> chunks = <List<int>>[];
    int contentLength = 0;
    response.listen(
      (List<int> chunk) {
        chunks.add(chunk);
        contentLength += chunk.length;
      },
      onDone: () =>
          completer.complete(<int>[for (final chunk in chunks) ...chunk]),
      onError: completer.completeError,
      cancelOnError: true,
    );
    return completer.future;
  }
}
