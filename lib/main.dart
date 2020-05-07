import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:math' as math;

main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

double pi = 0;

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.grey[900],
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => setState(() {}));

    return Scaffold(
      backgroundColor: Colors.grey[900],
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Pi Value (approx)",
                style: Theme.of(context).textTheme.headline4.copyWith(
                      color: Colors.black,
                    ),
              ),
              SizedBox(height: 10),
              Text(
                "${pi.toStringAsFixed(6)}",
                style: Theme.of(context).textTheme.headline5,
              ),
            ],
          ),
        ),
      ),
      body: CustomPaint(
        painter: SimulationPainter(),
        child: Container(),
      ),
    );
  }
}

final coordinates = List<List<double>>();

class SimulationPainter extends CustomPainter {
  final randomGenerator = math.Random();
  double x, y;
  int insideCircle = 0, total = 0;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width * 9 / 20;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white;

    canvas.translate(size.width / 2, size.height / 2);

    canvas.drawCircle(Offset(0, 0), radius, paint);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(0, 0),
        height: radius * 2,
        width: radius * 2,
      ),
      paint,
    );

    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 90; i++) {
      x = -radius + randomGenerator.nextDouble() * radius * 2;
      y = -radius + randomGenerator.nextDouble() * radius * 2;

      coordinates.add([x, y]);

      ++total;
      if (x * x + y * y < radius * radius) ++insideCircle;
    }

    coordinates.forEach((element) {
      x = element[0];
      y = element[1];

      paint.color = (x * x + y * y > radius * radius)
          ? Colors.redAccent
          : Colors.greenAccent;

      canvas.drawCircle(Offset(x, y), 0.3, paint);

      pi = insideCircle / total * 4;
    });
  }

  @override
  bool shouldRepaint(SimulationPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(SimulationPainter oldDelegate) => false;
}
