import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../core/localization.dart';
import '../../data/models/movie_model.dart';
import '../details/details_screen.dart';
import 'search_bloc.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchScreen extends HookWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final scrollController = useScrollController();

    useEffect(() {
      void onScroll() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          final state = context.read<SearchBloc>().state;
          if (state is SearchSuccess && state.hasMore) {
            context.read<SearchBloc>().add(const LoadMoreMovies());
          }
        }
      }

      scrollController.addListener(onScroll);
      context.read<SearchBloc>().add(const LoadSearchHistory());
      
      return () => scrollController.removeListener(onScroll);
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('app_title')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    
                    decoration: InputDecoration(
                      hintText: context.tr('search_movies'),
                      border: const OutlineInputBorder(),
                      
                      prefixIcon: const Icon(Icons.search),
                      semanticCounterText: 'Search for movies', 
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        context.read<SearchBloc>().add(SearchMovies(value));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final query = searchController.text;
                    if (query.trim().isNotEmpty) {
                      context.read<SearchBloc>().add(SearchMovies(query));
                    }
                  },
                  child: Text(context.tr('search')),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchInitial) {
                  return _buildSearchHistory(context, state.searchHistory);
                } else if (state is SearchLoading && state.currentMovies.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is SearchSuccess) {
                  return _buildMovieList(
                    context,
                    state.movies,
                    scrollController,
                    false,
                  );
                } else if (state is SearchLoading && state.isLoadingMore) {
                  final loadingState = state;
                  return _buildMovieList(
                    context,
                    loadingState.currentMovies,
                    scrollController,
                    true,
                  );
                } else if (state is SearchError) {
                  if (state.currentMovies.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(context.tr(state.error.message)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              final query = searchController.text;
                              if (query.trim().isNotEmpty) {
                                context.read<SearchBloc>().add(SearchMovies(query));
                              }
                            },
                            child: Text(context.tr('retry')),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return _buildMovieList(
                      context,
                      state.currentMovies,
                      scrollController,
                      false,
                    );
                  }
                }
                return Center(child: Text(context.tr('search_movies')));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory(BuildContext context, List<String> history) {
    if (history.isEmpty) {
      return Center(child: Text(context.tr('search_movies')));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('search_history'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () {
                  context.read<SearchBloc>().add(const ClearSearchHistory());
                },
                child: Text(context.tr('clear_all')),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final query = history[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(query),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    context
                        .read<SearchBloc>()
                        .add(RemoveFromSearchHistory(query));
                  },
                ),
                onTap: () {
                  context.read<SearchBloc>().add(SearchMovies(query));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMovieList(
    BuildContext context,
    List<MovieModel> movies,
    ScrollController scrollController,
    bool isLoadingMore,
  ) {
    if (movies.isEmpty) {
      return Center(child: Text(context.tr('no_results')));
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: movies.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == movies.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final movie = movies[index];
        return _MovieCard(movie: movie);
      },
    );
  }
}

class _MovieCard extends StatelessWidget {
  final MovieModel movie;

  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsScreen(imdbId: movie.imdbId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (movie.poster.isNotEmpty && movie.poster != 'N/A')
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    movie.poster,
                    width: 80,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.movie, size: 40),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 120,
                  color: Colors.grey[300],
                  child: const Icon(Icons.movie, size: 40),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${context.tr('year')}: ${movie.year}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${context.tr('type')}: ${movie.type}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
