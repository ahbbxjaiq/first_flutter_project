import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];
  var unfavorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      unfavorites.add(current);
      favorites.remove(current);
    } else {
      if (unfavorites.contains(current)) {
        unfavorites.remove(current);
      }
      favorites.add(current);
    }
    notifyListeners();
  }

  void remove(int index) {
    unfavorites.add(favorites[index]);
    favorites.remove(favorites[index]);
    notifyListeners();
  }

  void refavorite(int index) {
    favorites.add(unfavorites[index]);
    unfavorites.remove(unfavorites[index]);
    notifyListeners();
  }
}

// ...

// ...

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      case 2:
        page = UnfavoritedPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: <Widget> [
              SafeArea(
                child: NavigationRail(
                    destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.heart_broken),
                      label: Text('Unfavorited'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  extended: constraints.maxWidth >= 600,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}


class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;

    if (favorites.isEmpty) return Center(child: Text('No Favorites Yet.'));
    
    return ListView.builder(
      itemCount: favorites.length+1,
      itemBuilder: (ctx, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Text('${favorites.length} favorites.'),
          );
        }
        index--;
        return ListTile(
            leading: IconButton(
              onPressed: () {
                setState(() {
                  appState.remove(index);
                });
              }, 
              icon: Icon(Icons.favorite),
            ),
            title: Text(favorites[index].asLowerCase),
          );
      },
    );
  }
}

class UnfavoritedPage extends StatefulWidget {
  const UnfavoritedPage({super.key});

  @override
  State<UnfavoritedPage> createState() => _UnfavoritedPage();
}

class _UnfavoritedPage extends State<UnfavoritedPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var unfavorites = appState.unfavorites;

    if (unfavorites.isEmpty) return Center(child: Text('No Unfavorited Yet.'));

    return ListView.builder(
      itemCount: unfavorites.length+1,
      itemBuilder: (ctx, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Text('${unfavorites.length} unfavorited.'),
          );
        }

        index--;

        return ListTile(
          leading: IconButton(
            onPressed: () {
              setState(() {
                appState.refavorite(index);
              });
            },
            icon: Icon(Icons.heart_broken),
          ),
          title: Text(unfavorites[index].asLowerCase),
        );
      }
    );
  }
}

// ...


class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase, 
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}