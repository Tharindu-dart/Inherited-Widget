import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  Widget build(BuildContext context) {
    return CounterWidget(
      //child of the inheritedWidget-----------------------------------------------------------------------------------------|
      child: Builder(builder: (context) {
        print(
            "-> Child builded  (But this should never rebuilt, because Inheritedwidget only rebuilt its dependent and never rebuilt its child)");
        return Scaffold(
          appBar: AppBar(
            title: Text("PageTitle"),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //dependent context of the inheritedWidget (updateShouldNotify affect on this)-------------------------------|
                //if updateShouldNotify = false => no rebuilt / if updateShouldNotify = true => rebuilt
                Builder(builder: (context) {
                  print(
                      "-> Dependent rebuilded  (if updateShouldNotify = true => dependent get rebuilded)");
                  final inherited = context
                      .dependOnInheritedWidgetOfExactType<_InheritedCount>();
                  return Text(
                    '${inherited.state}',
                    style: Theme.of(context).textTheme.headline1,
                  );
                }),
                //Dependent context ended...

                //This new widget(with new context) is not a dependent of the InheritedWidget---------------------------------|
                Builder(builder: (context) {
                  final ancestor = context.findAncestorStateOfType<
                      _CounterState>(); //findAncestorWidgetOfExactType<_InheritedCount>();
                  return RaisedButton(
                    onPressed: () => ancestor.incrementCount(),
                    child: Text("Increment"),
                  );
                }),
                //
              ],
            ),
          ),
        );
      }),
    );
  }
}

//This Statefulwidget resposible for -> rebuilding InheritedWiget with or without new InheritedWidget-------------------------|
class CounterWidget extends StatefulWidget {
  CounterWidget({Key key, @required this.child}) : super(key: key);

  final Widget child;

  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<CounterWidget> {
  int count;

  void incrementCount() {
    setState(() {
      ++count;
    });
  }

  @override
  void initState() {
    super.initState();
    count = 0;
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedCount(
      state: this.count,
      child: widget.child,
    );
  }
}

//Inherited Widget
class _InheritedCount extends InheritedWidget {
  _InheritedCount({Key key, @required this.state, @required Widget child})
      : super(key: key, child: child);

  final int state;

  @override
  bool updateShouldNotify(_InheritedCount old) {
    print("old = ${old.state}");
    print("current = $state");
    print(old.state != state);
    return old.state != state;
  }
}


//warning !
/* 
Don't give state object as the field of inheritedWidget ,because state object doesnt change its only update its instance variables.

*/