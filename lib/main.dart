import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'GameDetailScreen.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');

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
  String note;
  String? coverUrl;

  Game({required this.title, this.isPlayed = false, this.note = '', this.coverUrl});
}

class GameListScreen extends StatefulWidget{
  @override 
  _GameListScreenState createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  final List<Game> games = [];
  final List<Game> filteredGames = [];
  final TextEditingController searchController = TextEditingController();
  final String clientId = dotenv.get('API_CLIENT', fallback: 'API_CLIENT not found');
  final String accessToken = dotenv.get('API_KEY', fallback: 'API_KEY not found');

  @override
  void initState(){
    super.initState();
    fetchGames();
    searchController.addListener(()=> filterGames());
  }

  Future<void> fetchGames() async {
    int offset = 0;
    const int limit = 500;
    bool hasMoreGames = true;

    while(hasMoreGames){
      final response = await http.post(
          Uri.parse('https://api.igdb.com/v4/games'), headers: {
            'Client-ID': clientId, 'Authorization': 'Bearer $accessToken', 
          },

          body: 'fields name, cover.image_id; limit $limit; offset $offset;'
      );   
      if (response.statusCode == 200){
        final List<dynamic> data = json.decode(response.body);
        setState((){
          games.addAll(data.map((game) => Game(title:game['name'], coverUrl: game['cover'] != null ? 'https://images.igdb.com/igdb/image/upload/t_cover_big/${game['cover']['image_id']}.jpg' : null,)).toList());
          filteredGames.addAll(games);
        });

        if (data.length < limit){
          hasMoreGames = false;
        } else{
          offset += limit;
        }

        await Future.delayed(Duration(seconds: 2));
      }
        else{
          print('Failed to fetch games: ${response.statusCode}');
          hasMoreGames = false;
        }
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
  child: GridView.builder(
    padding: EdgeInsets.all(8.0),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 10, // Number of columns
      crossAxisSpacing: 8.0, // Space between columns
      mainAxisSpacing: 8.0, // Space between rows
      childAspectRatio: 0.7, // Aspect ratio for each card
    ),
    itemCount: filteredGames.length,
    itemBuilder: (context, index) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameDetailScreen(game: filteredGames[index]),
            ),
          ).then((_) {
            setState(() {}); // Refresh the UI on return
          });
        },
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display Game Cover
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                  child: filteredGames[index].coverUrl != null
                      ? Image.network(
                          filteredGames[index].coverUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image, size: 50),
                        )
                      : Icon(Icons.videogame_asset, size: 50),
                ),
              ),
              SizedBox(height: 8.0),
              // Display Game Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  filteredGames[index].title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8.0),
            ],
          ),
        ),
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

