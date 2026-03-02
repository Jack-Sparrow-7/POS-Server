import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_backend/config/database.dart';
import 'package:pos_backend/config/env.dart';

Future<void> init(InternetAddress ip, int port) async {
  Env.load();
  await initDatabase();
}

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  return serve(handler, ip, port);
}
