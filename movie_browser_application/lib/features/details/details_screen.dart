import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization.dart';
import '../../data/repositories/movie_repository.dart';
import 'details_bloc.dart';
import 'details_event.dart';
import 'details_state.dart';

class DetailsScreen extends StatelessWidget {
  final String imdbId;

  const DetailsScreen({super.key, required this.imdbId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DetailsBloc(
        RepositoryProvider.of<MovieRepository>(context),
      )..add(LoadMovieDetails(imdbId)),
      child: _DetailsScreenContent(imdbId: imdbId),
    );
  }
}

class _DetailsScreenContent extends StatelessWidget {
  final String imdbId;

  const _DetailsScreenContent({required this.imdbId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('details')),
        actions: [
          BlocBuilder<DetailsBloc, DetailsState>(
            builder: (context, state) {
              if (state is DetailsSuccess) {
                return IconButton(
                  icon: Icon(
                    state.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: state.isFavorite ? Colors.red : null,
                  ),
                  onPressed: () {
                    context.read<DetailsBloc>().add(const ToggleFavorite());
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<DetailsBloc, DetailsState>(
        builder: (context, state) {
          if (state is DetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DetailsSuccess) {
            return _buildMovieDetails(context, state);
          } else if (state is DetailsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(context.tr(state.error.message)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DetailsBloc>().add(
                            LoadMovieDetails(imdbId),
                          );
                    },
                    child: Text(context.tr('retry')),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMovieDetails(BuildContext context, DetailsSuccess state) {
    final movie = state.movie;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.isFromCache)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.orange[100],
              child: Row(
                children: [
                  const Icon(Icons.offline_bolt, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Showing cached data (offline mode)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          if (movie.poster.isNotEmpty && movie.poster != 'N/A')
            Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(movie.poster),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 400,
              color: Colors.grey[300],
              child: const Icon(Icons.movie, size: 100),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      movie.imdbRating,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      movie.year,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      movie.runtime,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(context, 'genre', movie.genre),
                _buildInfoRow(context, 'director', movie.director),
                _buildInfoRow(context, 'actors', movie.actors),
                _buildInfoRow(context, 'released', movie.released),
                _buildInfoRow(context, 'language', movie.language),
                _buildInfoRow(context, 'country', movie.country),
                const SizedBox(height: 16),
                Text(
                  context.tr('plot'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  movie.plot,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (movie.awards != 'N/A') ...[
                  const SizedBox(height: 16),
                  Text(
                    context.tr('awards'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.awards,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String labelKey, String value) {
    if (value == 'N/A') return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '${context.tr(labelKey)}:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
