import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_browser_application/core/error.dart';
import 'package:movie_browser_application/data/models/movie_model.dart';
import 'package:movie_browser_application/data/repositories/movie_repository.dart';
import 'package:movie_browser_application/features/search/search_bloc.dart';
import 'package:movie_browser_application/features/search/search_event.dart';
import 'package:movie_browser_application/features/search/search_state.dart';


class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository mockRepository;
  late SearchBloc searchBloc;

  setUp(() {
    mockRepository = MockMovieRepository();
    searchBloc = SearchBloc(mockRepository);
  });

  tearDown(() {
    searchBloc.close();
  });

  group('SearchBloc', () {
    const testQuery = 'Batman';
    final testMovies = [
      const MovieModel(
        imdbId: 'tt0372784',
        title: 'Batman Begins',
        year: '2005',
        type: 'movie',
        poster: 'https://example.com/poster.jpg',
      ),
    ];

    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoading, SearchSuccess] when SearchMovies succeeds',
      build: () {
        when(() => mockRepository.searchMovies(testQuery, 1))
          .thenAnswer((_) async => (testMovies, 1));
        when(() => mockRepository.addToSearchHistory(testQuery))
            .thenAnswer((_) async => {});
        return searchBloc;
      },
      act: (bloc) => bloc.add(const SearchMovies(testQuery)),
      expect: () => [
        const SearchLoading(),
        SearchSuccess(
          movies: testMovies,
          query: testQuery,
          currentPage: 1,
           totalResults: 1
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.searchMovies(testQuery, 1)).called(1);
        verify(() => mockRepository.addToSearchHistory(testQuery)).called(1);
      },
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoading, SearchError] when SearchMovies fails',
      build: () {
        when(() => mockRepository.searchMovies(testQuery, 1))
            .thenThrow(NetworkError());
        return searchBloc;
      },
      act: (bloc) => bloc.add(const SearchMovies(testQuery)),
      expect: () => [
        const SearchLoading(),
        isA<SearchError>()
            .having((state) => state.error, 'error', isA<NetworkError>()),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits SearchInitial with history when LoadSearchHistory succeeds',
      build: () {
        when(() => mockRepository.getSearchHistory())
            .thenAnswer((_) async => [testQuery, 'Superman']);
        return searchBloc;
      },
      act: (bloc) => bloc.add(const LoadSearchHistory()),
      expect: () => [
        const SearchInitial(searchHistory: [testQuery, 'Superman']),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'removes query from history when RemoveFromSearchHistory is called',
      build: () {
        when(() => mockRepository.removeFromSearchHistory(testQuery))
            .thenAnswer((_) async => {});
        when(() => mockRepository.getSearchHistory())
            .thenAnswer((_) async => ['Superman']);
        return searchBloc;
      },
      act: (bloc) => bloc.add(const RemoveFromSearchHistory(testQuery)),
      expect: () => [
        const SearchInitial(searchHistory: ['Superman']),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'clears all history when ClearSearchHistory is called',
      build: () {
        when(() => mockRepository.clearSearchHistory())
            .thenAnswer((_) async => {});
        return searchBloc;
      },
      act: (bloc) => bloc.add(const ClearSearchHistory()),
      expect: () => [
        const SearchInitial(searchHistory: []),
      ],
    );
  });
}
