import 'dart:io';

import 'package:mongo_go/mongo_go.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/echo/<message>', _echoHandler);

Future<Response> _rootHandler(Request req) async {
  // mongodb://ahfastrans:ahfast.co@localhost:27017/
// you can keep this as a singleton.
  final connection =
      await Connection.connectWithString("mongodb://ahfastrans:ahfast.co@godart-mongodb:27017/");

  final database = await connection.database("ahfastrans");
  final collection = await database.collection("users");

  final lst = await collection.find({}).toList();
  print(lst);

  return Response.ok('Hello, World!\n $lst');
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
