// import 'dart:html';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

var randomColor = Colors.primaries[Random().nextInt(Colors.primaries.length)];

class AnimatedBarChart extends AnimatedWidget {
  const AnimatedBarChart({Key? key, required Animation<double> animation})
      : super(key: key, listenable: animation);

  static final _opacityTween = Tween<double>(begin: 0.1, end: 1);
  static final _sizeTween = Tween<double>(begin: 1, end: 300);
  static final _colorTween =
  ColorTween(begin: Colors.deepPurple, end: randomColor);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Opacity(
                  opacity: _opacityTween.evaluate(animation),
                  child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      color: _colorTween.evaluate(animation),
                      height: _sizeTween.evaluate(animation),
                      width: _sizeTween.evaluate(animation),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  }
}

class Insights extends StatefulWidget {
  final String userName;

  const Insights({Key? key, required this.userName}) : super(key: key);

  @override
  _InsightsState createState() => _InsightsState();
}

class _InsightsState extends State<Insights>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 10), vsync: this);
    animation =
    CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animations')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AnimatedBarChart(animation: animation),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Go back'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class CreatePromotionScreen extends StatelessWidget {
  const CreatePromotionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose the option for promotion'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueGrey,
                ),
                onPressed: () {
                  Navigator.pop(context, 'Promotion with post was created!');
                },
                child: const Text('Create promotion with post'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueGrey,
                ),
                onPressed: () {
                  Navigator.pop(context, 'Promotion with story was created!');
                },
                child: const Text('Create promotion with story'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Future<List<Map<String, dynamic>>> getData() async {
  final response = await http.get(Uri.parse(
      "https://raw.githubusercontent.com/ZaykaNya/flutter-labs/lab3/lib/data.json"));
  print('response ${response.body}');

  if (response.statusCode == 200) {
    final list = (jsonDecode(response.body) as List);
    return list.map((e) => e as Map<String, dynamic>).toList();
  } else {
    throw Exception('Failed to load');
  }
}

Future<String> createOrderMessage() async {
  var data = await fetchUserOrder();
  return '$data';
}

Future<String> fetchUserOrder() => Future.delayed(
  const Duration(seconds: 5),
      () => 'Data fetched with await',
);

class DrawerModel extends ChangeNotifier {
  final _broadcasts = [];

  void add(item) {
    _broadcasts.add(item);
    notifyListeners();
  }

  void removeAll() {
    _broadcasts.clear();
    notifyListeners();
  }
}

Future<void> main() async {
  print(await getData());
  print('Fetching data with await...');
  print(await createOrderMessage());
  print('Fetching data with .then()...');
  createOrderMessage().then((response) {
    print('Data fetched with .then()');
  });

  SharedPreferences.getInstance().then((sp) {
    runApp(
      ChangeNotifierProvider(
        create: (context) => DrawerModel(),
        child: MyApp(isDarkTheme: sp.getBool("isDarkTheme") ?? true),
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  final bool isDarkTheme;

  const MyApp({Key? key, required this.isDarkTheme}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAppState(isDarkTheme);
}

class _MyAppState extends State<MyApp> {
  late bool isDarkTheme;

  _MyAppState(this.isDarkTheme);// This widget is the root of your application.

  void toggleTheme() {
    setState(() {
      isDarkTheme = !isDarkTheme;
      SharedPreferences.getInstance().then((sp) {
        sp.setBool('isDarkTheme', isDarkTheme);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twitch',
      debugShowCheckedModeBanner: false,
      initialRoute: '',
      routes: {
        '': (context) => MyHomePage(title: '', toggleTheme: toggleTheme),
        '/game': (context) => const GamePage(
              tag: 'game',
              imagePath: 'images/Dota2',
            ),
      },
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      ),
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
    );
  }
}

class GamePage extends StatelessWidget {
  final String tag;
  final String imagePath;

  const GamePage({
    Key? key,
    required this.tag,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GamePage'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Hero(
              tag: tag,
              child: Container(
                width: 200,
                height: 300,
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(imagePath), fit: BoxFit.cover)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Function toggleTheme;

  const MyHomePage({Key? key, required this.title, required this.toggleTheme}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState(toggleTheme);
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _globalCounter = 0;
  final Function toggleTheme;

  final _inactiveColor = Colors.grey;

  _MyHomePageState(this.toggleTheme);

  late ScrollController _scrollController;
  bool _showBackToTopButton = false;

  void setGlobalCounter() {
    setState(() {
      _globalCounter++;
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          if (_scrollController.offset >= 100) {
            _showBackToTopButton = true; // show the back-to-top button
          } else {
            _showBackToTopButton = false; // hide the back-to-top button
          }
        });
      });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // dispose the controller
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.linear);
  }

  Widget _buildBottomBar() {
    return CustomAnimatedBottomBar(
      containerHeight: 45,
      selectedIndex: _currentIndex,
      showElevation: true,
      itemCornerRadius: 24,
      curve: Curves.easeIn,
      onItemSelected: (index) => setState(() => _currentIndex = index),
      items: <BottomNavyBarItem>[
        BottomNavyBarItem(
          icon: const Icon(Icons.favorite_border),
          title: const Text('Отслеживаемое'),
          activeColor: Colors.green,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: const Icon(Icons.search),
          title: const Text('Поиск'),
          activeColor: Colors.purpleAccent,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: const Icon(Icons.content_copy),
          title: const Text('Просмотр '),
          activeColor: Colors.pink,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: const Icon(Icons.emoji_events),
          title: const Text('Киберспорт'),
          activeColor: Colors.blue,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('TI-81 Andrii Demchyshyn'),
                  Text('Global Counter: $_globalCounter'),
                ],
              ),
            ),
            ListOfBroadcasts(setGlobalCounter: setGlobalCounter),
            const MyButton(),
            IconButton(
              icon: const Icon(Icons.wb_sunny),
              onPressed: () {
                toggleTheme();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: _showBackToTopButton == false ? null : FloatingActionButton(
        backgroundColor: const Color(0xFF212121),
        child: const Icon(Icons.arrow_upward, color: Colors.white, size: 24),
        onPressed: _scrollToTop,
      ),
      bottomNavigationBar: _buildBottomBar(),
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('In development')));
              },
              icon: const Icon(Icons.video_camera_back)),
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute<void>(
                    builder: (context) => const Insights(userName: 'ZaykaNya')
                ));
              },
              icon: const Icon(Icons.all_inbox)),
          IconButton(
              onPressed: () async {
                var res = await Navigator.push(context, MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return Scaffold(
                      appBar: AppBar(
                        title: const Text('Favorite'),
                      ),
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Empty here...',
                              style: TextStyle(fontSize: 24),
                            ),
                            TextButton(
                              onPressed: () => {
                                Navigator.pop(context, 'Data from page')
                              },
                              child: Column(
                                children: const <Widget>[
                                  Text(
                                    'Back',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        )
                      ),
                    );
                  },
                ));
                print(res as String);
              },
              icon: const Icon(Icons.favorite_border)),
          IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('In development')));
              },
              icon: const Icon(Icons.search)),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const <Widget>[
                  Text('Отслеживаемое',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      )),
                ],
              ),
              Row(
                children: const <Widget>[
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: (Text('Отслеживаемое категории',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ))))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  GameBar(
                      title: 'Apex Legends',
                      viewers: '81.6 тыс',
                      imagePath: "assets/images/ApexLegends.png"),
                  GameBar(
                      title: 'Fortnite',
                      viewers: '100.5 тыс',
                      imagePath: "assets/images/Fortnite.jpg"),
                  GameBar(
                      title: 'Dota 2',
                      viewers: '514.3 тыс',
                      imagePath: "assets/images/Dota2.jpg"),
                ],
              ),
              Row(
                children: const <Widget>[
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 32, 0, 16),
                      child: (Text('Ваши активные каналы',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ))))
                ],
              ),
              Broadcast(setGlobalCounter: setGlobalCounter),
              Broadcast(setGlobalCounter: setGlobalCounter),
              Broadcast(setGlobalCounter: setGlobalCounter),
              Broadcast(setGlobalCounter: setGlobalCounter),
              Broadcast(setGlobalCounter: setGlobalCounter),
              Row(
                children: const <Widget>[
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                      child: (Text('Рекомендуемые вам каналы',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ))))
                ],
              ),
              Broadcast(setGlobalCounter: setGlobalCounter),
              Broadcast(setGlobalCounter: setGlobalCounter),
              Broadcast(setGlobalCounter: setGlobalCounter),
              Broadcast(setGlobalCounter: setGlobalCounter),
              Broadcast(setGlobalCounter: setGlobalCounter),
            ],
          ),
        ),
      ),
    );
  }
}

class NavButton extends StatelessWidget {
  final String title;
  final IconData icon;

  const NavButton({
    Key? key,
    required this.title,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextButton(
          onPressed: () => {},
          child: Column(
            children: <Widget>[
              Icon(icon, color: Colors.white),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class Broadcast extends StatelessWidget {
  final bool isButton;
  final setGlobalCounter;

  const Broadcast({
    Key? key,
    this.isButton = true,
    required this.setGlobalCounter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final drawerModel = context.watch<DrawerModel>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 55,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage("assets/images/Dota2.jpg"),
                fit: BoxFit.cover,
              )),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        CircleAvatar(
                          radius: 8,
                          backgroundImage: AssetImage("assets/images/Dota2.jpg"),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                          child: Text(
                            'dota2ti_ru',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 2),
                      child: Row(
                        children: const [
                          Text(
                            '[RU] Мультитрансляция',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 2, 0, 4),
                      child: Row(
                        children: const [
                          Text(
                            'Dota 2',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 8, 16),
                          width: 70,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF424242),
                            border: Border.all(
                              color: const Color(0xFF424242),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Русский',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
            if (isButton) Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () => {
                    Provider.of<DrawerModel>(context, listen: false).add('1')
                  },
                  child: Column(
                    children: const <Widget>[
                      Text(
                        "Add",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      )
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => {
                    setGlobalCounter()
                  },
                  child: Column(
                    children: const <Widget>[
                      Text(
                        "Increase",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        )
      ],
    );
  }
}

class GameBar extends StatelessWidget {
  final String title;
  final String viewers;
  final String imagePath;

  const GameBar({
    Key? key,
    required this.title,
    required this.viewers,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
        tag: title,
        child: Expanded(
          flex: 1,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.all(0))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 150,
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(imagePath), fit: BoxFit.cover)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    )
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      viewers,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    )
                  ],
                )
              ],
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  CustomPageRoute((GamePage(
                    tag: title,
                    imagePath: imagePath,
                  ))));
            },
          ),
        ));
  }
}

class CustomAnimatedBottomBar extends StatelessWidget {
  CustomAnimatedBottomBar({
    Key? key,
    this.selectedIndex = 0,
    this.showElevation = true,
    this.iconSize = 24,
    this.backgroundColor,
    this.itemCornerRadius = 50,
    this.containerHeight = 56,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    required this.items,
    required this.onItemSelected,
    this.curve = Curves.linear,
  })  : assert(items.length >= 2 && items.length <= 5),
        super(key: key);

  final int selectedIndex;
  final double iconSize;
  final Color? backgroundColor;
  final bool showElevation;
  final List<BottomNavyBarItem> items;
  final ValueChanged<int> onItemSelected;
  final MainAxisAlignment mainAxisAlignment;
  final double itemCornerRadius;
  final double containerHeight;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).bottomAppBarColor;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF212121),
        boxShadow: [
          if (showElevation)
            const BoxShadow(
              color: Colors.grey,
              blurRadius: 1,
            ),
        ],
      ),
      child: SafeArea(
        child: Container(
          width: double.infinity,
          height: containerHeight,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            mainAxisAlignment: mainAxisAlignment,
            children: items.map((item) {
              var index = items.indexOf(item);
              return GestureDetector(
                onTap: () => onItemSelected(index),
                child: _ItemWidget(
                  item: item,
                  iconSize: iconSize,
                  isSelected: index == selectedIndex,
                  backgroundColor: bgColor,
                  itemCornerRadius: itemCornerRadius,
                  curve: curve,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _ItemWidget extends StatelessWidget {
  final double iconSize;
  final bool isSelected;
  final BottomNavyBarItem item;
  final Color backgroundColor;
  final double itemCornerRadius;
  final Curve curve;

  const _ItemWidget({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.backgroundColor,
    required this.itemCornerRadius,
    required this.iconSize,
    this.curve = Curves.linear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      selected: isSelected,
      child: AnimatedContainer(
        height: double.maxFinite,
        duration: const Duration(microseconds: 250),
        decoration: BoxDecoration(
          color: const Color(0xFF212121),
          borderRadius: BorderRadius.circular(itemCornerRadius),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: NeverScrollableScrollPhysics(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconTheme(
                  data: IconThemeData(
                      size: iconSize,
                      color: isSelected ? Colors.white : Colors.grey),
                  child: item.icon,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 10),
                      maxLines: 1,
                      textAlign: item.textAlign,
                      child: item.title,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavyBarItem {
  BottomNavyBarItem({
    required this.icon,
    required this.title,
    this.activeColor = Colors.blue,
    this.textAlign,
    this.inactiveColor,
  });

  final Widget icon;
  final Widget title;
  final Color activeColor;
  final Color? inactiveColor;
  final TextAlign? textAlign;
}

class CustomPageRoute<T> extends PageRoute<T> {
  final Widget child;

  CustomPageRoute(this.child);

  @override
  Color get barrierColor => Colors.black;

  @override
  String get barrierLabel => '';

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class MyButton extends StatefulWidget {
  const MyButton({Key? key}) : super(key: key);

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  int _likes = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextButton(
          onPressed: () => {
            setState(() {
              _likes += 1;
            })
          },
          child: Column(
            children: <Widget>[
              Text(
                "Clicked $_likes times",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class ListOfBroadcasts extends StatelessWidget {
  final setGlobalCounter;

  const ListOfBroadcasts({Key? key, required this.setGlobalCounter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawerModel>(
      builder: (context, myModel, child) {
        return Column(
          children: <Widget>[
            for(var item in myModel._broadcasts) if(child != null) child,
            if(myModel._broadcasts.isNotEmpty) Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () => {
                    myModel.removeAll()
                  },
                  child: Column(
                    children: const <Widget>[
                      Text(
                        "Remove all broadcasts",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        );
      },
      child: Broadcast(isButton: false, setGlobalCounter: setGlobalCounter),
    );
  }
}