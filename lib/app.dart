import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/network/connectivity_service.dart';
import 'core/widgets/reconnecting_bar.dart';
import 'features/users/domain/entities/user_entity.dart';
import 'features/users/domain/repositories/user_repository.dart';
import 'features/users/presentation/bloc/users_bloc.dart';
import 'features/users/presentation/bloc/users_event.dart';
import 'features/users/presentation/pages/users_page.dart';
import 'features/users/presentation/pages/add_user_page.dart';
import 'features/movies/domain/entities/movie_entity.dart';
import 'features/movies/domain/repositories/movie_repository.dart';
import 'features/movies/presentation/bloc/movies_bloc.dart';
import 'features/movies/presentation/bloc/movies_event.dart';
import 'features/movies/presentation/bloc/movies_state.dart';
import 'features/movies/presentation/pages/movies_page.dart';
import 'features/movies/presentation/pages/movie_detail_page.dart';
import 'features/saved_movies/domain/repositories/saved_movie_repository.dart';
import 'features/saved_movies/presentation/bloc/saved_movies_bloc.dart';
import 'features/saved_movies/presentation/bloc/saved_movies_event.dart';
import 'features/saved_movies/presentation/pages/saved_movies_page.dart';
import 'features/matches/domain/repositories/matches_repository.dart';
import 'features/matches/presentation/bloc/matches_bloc.dart';
import 'features/matches/presentation/bloc/matches_event.dart';
import 'features/matches/presentation/pages/matches_page.dart';
import 'sync/sync_manager.dart';

/// Root widget for MovieVerse.
class MovieVerseApp extends StatefulWidget {
  const MovieVerseApp({super.key});
  @override
  State<MovieVerseApp> createState() => _MovieVerseAppState();
}

class _MovieVerseAppState extends State<MovieVerseApp> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    final connectivity = getIt<ConnectivityService>();
    _isOffline = !connectivity.isOnline;
    connectivity.onConnectivityChanged.listen((online) {
      setState(() => _isOffline = !online);
      if (online) SyncManager.triggerSync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => UsersBloc(repository: getIt<UserRepository>())..add(const LoadUsers()),
        ),
      ],
      child: MaterialApp(
        title: 'MovieVerse',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: Column(
          children: [
            ReconnectingBar(isVisible: _isOffline),
            Expanded(
              child: Navigator(
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(
                    builder: (_) => _AppHome(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return UsersPage(
      onUserTap: (user) => _navigateToMovies(context, user),
      onAddUser: () => _navigateToAddUser(context),
      onMatchesTap: () => _navigateToMatches(context),
    );
  }

  void _navigateToMovies(BuildContext context, UserEntity user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => MoviesBloc(
            movieRepository: getIt<MovieRepository>(),
            savedMovieRepository: getIt<SavedMovieRepository>(),
          )..add(LoadMovies(userId: user.id)),
          child: MoviesPage(
            user: user,
            onMovieTap: (movie) => _navigateToDetail(context, movie, user),
            onSavedMoviesTap: () => _navigateToSavedMovies(context, user),
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, MovieEntity movie, UserEntity user) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: BlocProvider(
              create: (_) => MoviesBloc(
                movieRepository: getIt<MovieRepository>(),
                savedMovieRepository: getIt<SavedMovieRepository>(),
              )..add(LoadMovies(userId: user.id)),
              child: Builder(
                builder: (ctx) {
                  final moviesState = ctx.watch<MoviesBloc>().state;
                  final isSaved = moviesState is MoviesLoaded && moviesState.savedMovieIds.contains(movie.id);
                  return MovieDetailPage(
                    movie: movie,
                    isSaved: isSaved,
                    onToggleSave: () => ctx.read<MoviesBloc>().add(
                      ToggleSaveMovie(userId: user.id, movieId: movie.id),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToAddUser(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<UsersBloc>(),
          child: const AddUserPage(),
        ),
      ),
    );
  }

  void _navigateToSavedMovies(BuildContext context, UserEntity user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => SavedMoviesBloc(repository: getIt<SavedMovieRepository>())
            ..add(LoadSavedMovies(userId: user.id)),
          child: SavedMoviesPage(
            user: user,
            onMovieTap: (movieId) {},
          ),
        ),
      ),
    );
  }

  void _navigateToMatches(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => MatchesBloc(repository: getIt<MatchesRepository>())
            ..add(const LoadMatches()),
          child: MatchesPage(onMovieTap: (movieId) {}),
        ),
      ),
    );
  }
}
