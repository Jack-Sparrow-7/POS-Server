import 'package:dart_frog/dart_frog.dart';
import 'package:pos_server/db/database.dart';
import 'package:postgres/postgres.dart';

Handler middleware(Handler handler) {
  return handler.use(
    provider<Pool<String>>(
      (context) => Database.instance.pool,
    ),
  );
}
