import 'package:flutter/material.dart';
import 'internet_speed_tester.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CLOUDEL',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SpeedTestPage(),
    );
  }
}

class SpeedTestPage extends StatefulWidget {
  @override
  _SpeedTestPageState createState() => _SpeedTestPageState();
}

class _SpeedTestPageState extends State<SpeedTestPage> {
  String _speedTestResult = "start the speed test";
  List<double> _dataPoints = [];
  bool _isTesting = false;

  void _startSpeedTest() async {
    setState(() {
      _isTesting = true;
      _speedTestResult = "Testing...";
    });

    double downloadSpeed = await InternetSpeedTester.testDownloadSpeed();

    setState(() {
      _isTesting = false;
      _speedTestResult =
          "Download Speed: ${downloadSpeed.toStringAsFixed(2)} Mbps";
      _dataPoints.add(downloadSpeed);
    });
  }

  void _stopSpeedTest() {
    setState(() {
      _isTesting = false;
      _speedTestResult = "Test stopped.";
    });
  }

  void _handleButtonPress() {
    if (_isTesting) {
      _stopSpeedTest();
    } else {
      _startSpeedTest();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CLOUDEL'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _speedTestResult,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleButtonPress,
              child: Text(_isTesting ? 'Stop' : 'Start Speed Test'),
            ),
            SizedBox(height: 20),
            if (_dataPoints.isNotEmpty)
              Container(
                height: 300,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: CustomPaint(
                  painter: ChartPainter(_dataPoints),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<double> dataPoints;

  ChartPainter(this.dataPoints);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4;

    final double maxY = dataPoints.reduce((a, b) => a > b ? a : b);
    final double barWidth = size.width / (dataPoints.length * 2);

    for (int i = 0; i < dataPoints.length; i++) {
      final x = (i * 2 + 1) * barWidth;
      final y = size.height * (1 - dataPoints[i] / maxY);
      canvas.drawLine(Offset(x, size.height), Offset(x, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
