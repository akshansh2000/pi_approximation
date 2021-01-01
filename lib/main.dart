import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:math' as math;

// starting point for the app
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

// stores the calculated value of PI
double pi = 0;

// UI class
class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  AnimationController _animationController; // to control button animations

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this)
      ..duration = Duration(milliseconds: 400);
  }

  @override
  Widget build(BuildContext context) {
    // sets system bar colors
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.grey[900],
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // locks the device to portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // continuously redraws the widgets
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => setState(() {}));

    // sets the colors and displays the calculated values
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        bottomNavigationBar: BottomAppBar(
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 50),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Pi Value (approx)",
                  style: Theme.of(context).textTheme.headline5.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  "${pi.toStringAsFixed(12)}",
                  style: Theme.of(context).textTheme.headline5,
                ),
                Text(
                  "Percentage Error (approx)",
                  style: Theme.of(context).textTheme.headline5.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  "${((math.pi - pi).abs() / math.pi * 100).toStringAsFixed(12)}",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 50),
                child: Text(
                  "Darts Inside Circle: ${insideCircle.toInt()}\n" +
                      "Darts Inside Square (Total): ${total.toInt()}\n" +
                      "Monte Carlo Error: ${(1 / math.sqrt(total.toInt())).toStringAsFixed(12)}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: CustomPaint(
                painter: SimulationPainter(),
                child: Container(),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FloatingActionButton(
                      child: Icon(Icons.replay),
                      backgroundColor: Colors.blueAccent,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      onPressed: () => setState(() {
                        insideCircle = 0;
                        total = 0;
                        coordinates.clear();
                        isWorking = true;
                        _animationController.reset();
                      }),
                    ),
                    SizedBox(width: 30),
                    FloatingActionButton(
                      child: AnimatedIcon(
                        icon: AnimatedIcons.pause_play,
                        progress: _animationController,
                      ),
                      backgroundColor: Colors.blueAccent,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      onPressed: () => setState(() {
                        isWorking
                            ? _animationController.forward()
                            : _animationController.reverse();
                        isWorking = !isWorking;
                      }),
                    ),
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

final coordinates = List<List<double>>(); // stores coordinates of all darts
double insideCircle = 0, total = 0; // counts number of darts
bool isWorking = true; // remembers the pause/play state

// paints the dots on screen
class SimulationPainter extends CustomPainter {
  final randomGenerator = math.Random(); // generates random coordinates
  double x, y; // stores current coordinates

  @override
  void paint(Canvas canvas, Size size) {
    // paint the square and circle
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

    // increase counters and generate coordinates if pause state is false
    if (isWorking)
      for (int i = 0; i < 30; i++) {
        x = -radius + randomGenerator.nextDouble() * radius * 2;
        y = -radius + randomGenerator.nextDouble() * radius * 2;

        coordinates.add([x, y]);

        ++total;
        if (x * x + y * y <= radius * radius) ++insideCircle;
      }

    // paint dots at the generated coordinates and update pi value
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
