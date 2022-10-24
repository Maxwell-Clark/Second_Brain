import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:second_brain/screens/document_screen.dart';
import 'package:second_brain/screens/home_screen.dart';
import 'package:second_brain/screens/login_screen.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: LoginScreen()),
});

final loggedInRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: HomeScreen()),
  '/document/:id': (route) => MaterialPage(child: DocumentScreen(id: route.pathParameters['id'] ?? ''))
});