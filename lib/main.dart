import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(App());
}

class UserInfo extends ChangeNotifier {
  bool isLoggedIn = false;

  void logIn() {
    isLoggedIn = true;
    notifyListeners();
  }

  void logOut() {
    isLoggedIn = false;
    notifyListeners();
  }
}

class App extends StatelessWidget {
  App({super.key});

  final userInfo = UserInfo();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserInfo>.value(
      value: userInfo,
      child: MaterialApp.router(
        routerConfig: router,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          useMaterial3: false,
        ),
      ),
    );
  }

  late final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainScreen(),
        routes: [
          GoRoute(
            path: 'details/:itemId',
            builder: (context, state) =>
                DetailsScreen(id: state.pathParameters['itemId']!),
          )
        ],
      ),
      GoRoute(
        path: '/home',
        redirect: (context, state) => '/',
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    ],
    refreshListenable: userInfo,
    redirect: (context, state) {
      // Check if the user is logged in
      bool isLoggedIn = context.read<UserInfo>().isLoggedIn;

      // Check if the current navigation target is the login page
      bool isLoggingIn = state.matchedLocation == '/login';

      // Construct a string representing the location from which the user is being redirected
      // If the current location is the root ('/'), set savedLocation to an empty string
      // Otherwise, append the current location to the string '?from='
      final savedLocation =
          state.matchedLocation == '/' ? '' : '?from=${state.matchedLocation}';

      // If the user is not logged in and is not currently navigating to the login page,
      // redirect them to the login page, appending the savedLocation as a query parameter
      // If the user is not logged in but is already navigating to the login page,
      // return null (no additional redirection is necessary)
      if (!isLoggedIn) return isLoggingIn ? null : '/login$savedLocation';

      // If the user is logged in and is currently on the login page,
      // check if there's a 'from' query parameter, which represents the initial page the user was trying to access
      // If this parameter exists, redirect the user to that page
      // Otherwise, redirect them to the root ('/')
      if (isLoggingIn) return state.uri.queryParameters['from'] ?? '/';

      // If the user is logged in and is not on the login page, return null (no redirection is necessary)
      return null;
    },
  );
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome!'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.read<UserInfo>().logIn();
          },
          child: const Text(
            'Login',
          ),
        ),
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Details Screen',
          ),
        ),
        body: Center(child: Text('Details of item #$id')));
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Deep Links example',
        ),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => context.go('/details/$index'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Item #$index'),
              ),
              const Divider(),
            ],
          ),
        ),
        itemCount: 15,
      ),
    );
  }
}
