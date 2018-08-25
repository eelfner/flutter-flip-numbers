import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/animation.dart';


// Motivated by trying to simplify: https://medium.com/flutter-community/make-3d-flip-animation-in-flutter-16c006bb3798
// EjE

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _counter = 0;
  Animation<double> animation;
  AnimationController controller;

  initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    final CurvedAnimation curve = CurvedAnimation(parent: controller, curve: Curves.bounceOut);
    animation = Tween(begin: 0.0, end: 1.0).animate(curve)
      ..addListener(() {
        setState(() {
          // the state that has changed here is the animation object’s value
        });
      });
    //controller.forward();
  }
  dispose() {
    controller.dispose();
    super.dispose();
  }
  void _incrementCounter() {
    setState(() {
      _counter++;

      controller.reset();
      controller.forward();
    });
  }

  Widget buildPanel(String text) {
    return Container(
      alignment: Alignment.center,
      width: 156.0,
      height: 172.0,
      decoration: BoxDecoration(
          color: Colors.black,
          border: new Border.all(color: Colors.grey, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
      child: Text(
        text,
        style: TextStyle(fontSize: 96.0, fontWeight: FontWeight.bold, color: Colors.yellow),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String nextText = _counter.toString();
    String prevText = math.max(0, _counter - 1).toString();
    Widget nextPanel = buildPanel(nextText);
    Widget prevPanel = buildPanel(prevText);
    Widget nextPanelTop = ClipRect(child: Align(alignment: Alignment.topCenter, heightFactor: 0.5, child: nextPanel,));
    Widget nextPanelBot = ClipRect(child: Align(alignment: Alignment.bottomCenter, heightFactor: 0.5, child: nextPanel,));
    Widget prevPanelTop = ClipRect(child: Align(alignment: Alignment.topCenter, heightFactor: 0.5, child: prevPanel,));
    Widget prevPanelBot = ClipRect(child: Align(alignment: Alignment.bottomCenter, heightFactor: 0.5, child: prevPanel,));

    List<Widget> topWidgets = [nextPanelTop];
    List<Widget> botWidgets = [prevPanelBot];

    double animationState = animation.value;
    double halfRotationRadians = math.pi / 2;
    bool bAnimateTop = (animationState >= 0.0 && animationState <= 0.5);
    bool bAnimateBot = (animationState > 0.5 && animationState <= 1.0);
    if (bAnimateTop) { // prevTop will start on top and rotate down until hidden at pi/2
      double rotation = 2.0 * animationState * halfRotationRadians;
      Matrix4 t = Matrix4.identity()..setEntry(3, 2, 0.002)..rotateX(rotation);
      topWidgets.add(Transform(transform: t, alignment: Alignment.bottomCenter, child: prevPanelTop,));
    }
    if (bAnimateBot) { // nextBox will start hidden at pi/2 and rotate down until completely covering prevBot
      double rotationToZero = 2.0 * halfRotationRadians * (1.0 - animationState); // f(an=0.5)=pi/2, f(an=1.0)=0.0
      Matrix4 t = Matrix4.identity()..setEntry(3, 2, -0.002)..rotateX(rotationToZero);
      botWidgets.add(Transform(transform: t, alignment: Alignment.topCenter, child: nextPanelBot,));
    }
    Stack topStack = Stack(alignment: Alignment.bottomCenter, children: topWidgets,);
    Stack botStack = Stack(alignment: Alignment.topCenter, children: botWidgets,);

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            topStack,
            Padding(padding: EdgeInsets.only(top: 2.0),),
            botStack,
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

