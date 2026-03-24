import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/db/database.dart';

Future<void> init(InternetAddress ip, int port) async {
  await Database.instance.init();
}

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  return serve(handler, ip, port);
}
