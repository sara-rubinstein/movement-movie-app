import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/api_client.dart';
import 'core/constants.dart';
import 'core/localization.dart';
import 'data/models/movie_model.dart';
import 'data/models/movie_details_model.dart';
import 'data/repositories/movie_repository.dart';
import 'features/search/search_bloc.dart';
import 'features/search/search_screen.dart';
import 'features/favorites/favorites_bloc.dart';
import 'features/favorites/favorites_screen.dart';
import 'features/favorites/favorites_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive Adapters
  Hive.registerAdapter(MovieModelAdapter());
  Hive.registerAdapter(MovieDetailsModelAdapter());

  // Open boxes
  await Hive.openBox<MovieModel>(AppConstants.favoritesBox);
  await Hive.openBox<String>(AppConstants.searchHistoryBox);
  await Hive.openBox<MovieDetailsModel>(AppConstants.movieDetailsBox);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {  // ← FIXED: removed extra parameters
    final apiClient = ApiClient();
    final movieRepository = MovieRepository(apiClient);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: movieRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SearchBloc(movieRepository)),
          BlocProvider(
            create: (context) => FavoritesBloc(movieRepository)
              ..add(const LoadFavorites()),
          ),
        ],
        child: MaterialApp(
          title: 'Movie Browser',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          localizationsDelegates: const [  // ← FIXED: added const
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
          ],
          home: const MainScreen(),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    SearchScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          
          // Reload favorites when switching to favorites tab
          if (index == 1) {
            context.read<FavoritesBloc>().add(const LoadFavorites());
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.search),
            label: context.tr('search'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite),
            label: context.tr('favorites'),
          ),
        ],
      ),
    );
  }
}