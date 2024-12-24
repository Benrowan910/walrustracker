import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const WalrusTracker());
}

class WalrusTracker extends StatelessWidget {
  const WalrusTracker({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Walrus Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue, 
        visualDensity: VisualDensity.adaptivePlatformDensity,),
        home: GameListScreen(),
    );
  }     // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
}

class Game{
  final String title;
  bool isPlayed;
  Game({required this.title, this.isPlayed = false});
}

class GameListScreen extends StatefulWidget{
  @override 
  _GameListScreenState createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  final List<Game> games = [];
  final List<Game> filteredGames = [];
  final TextEditingController searchController = TextEditingController();
  final String clientId = '1efwnc3tso9etae2mohqr8hkjixsnw';
  final String accessToken = '49ab4e1gom54daz4xmfk0ejyuhs0d4';

  @override
  void initState(){
    super.initState();
    fetchGames();
    searchController.addListener(()=> filterGames());
  }

  Future<void> fetchGames() async {
    final response = await http.post(
      Uri.parse('https://api.igdb.com/v4/games'), headers: {
          'Client-ID': clientId, 'Authorization': 'Bearer $accessToken', 
        },

        body: 'fields name; limit 20;'
    );

    if (response.statusCode == 200){
      final List<dynamic> data = json.decode(response.body);
      setState((){
        games.addAll(data.map((game) => Game(title:game['name'])).toList());
        filteredGames.addAll(games);
      });
    }
      else{
        print('Failed to fetch games: $response.statusCode}');
      }
    }

    void toggleGameStatus(int index){
      setState(() {
        filteredGames[index].isPlayed = !filteredGames[index].isPlayed;
      });
    }

    void filterGames(){
      final query = searchController.text.toLowerCase();
      setState(() {
        filteredGames.clear();
        filteredGames.addAll(
          games.where((game)=>game.title.toLowerCase().contains(query))
        );
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Game Tracker'),
        ),
      body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search games...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredGames.length, 
            itemBuilder: (context, index){
              return ListTile(
                title:Text(filteredGames[index].title),
                trailing: Icon(
                  filteredGames[index].isPlayed ? Icons.check_box : Icons.check_box_outline_blank, 
                  color: filteredGames[index].isPlayed ? Colors.green : null,
                ),
                onTap: () => toggleGameStatus(index),
              );
            },
          ),
        ),
      ],
    ),
  );
}

    @override
    void dispose(){
      searchController.dispose();
      super.dispose();
    }
  }


  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.

        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.


        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.

          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.

