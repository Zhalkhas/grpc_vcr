import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_connection_interface.dart';
import 'package:grpc_vcr/src/cassette.dart';
import 'package:mockito/mockito.dart';
import 'package:protobuf/protobuf.dart';

class GrpcVcrInterceptor extends ClientInterceptor {
  final String cassetteName;
  final String _cassettePath;
  late final File _cassetteFile;
  late List<Cassette> _cachedCassettes;

  List<Cassette> get cachedCassettes => _cachedCassettes;

  set cachedCassettes(List<Cassette> cassettes) {
    _cachedCassettes = cassettes;
    _cassetteFile.writeAsString(jsonEncode(cassettes));
  }

  GrpcVcrInterceptor({required this.cassetteName, String? cassettePath})
      : _cassettePath = cassettePath ??= Directory.current.path {
    _cassetteFile = File('$_cassettePath/test_cassettes/$cassetteName.json');
    _cachedCassettes =
        (jsonDecode(_cassetteFile.readAsStringSync()) as List<dynamic>)
            .map((json) => Cassette.fromJson(json as Map<String, dynamic>))
            .toList();
  }

  @override
  ResponseFuture<R> interceptUnary<Q, R>(ClientMethod<Q, R> method, Q request,
      CallOptions options, ClientUnaryInvoker<Q, R> invoker) {
    final cachedCassette = _getFirstMatchingCassette(
        method.path, _encodeBytes(method.requestSerializer(request)));

    if (cachedCassette != null) {
      final bytes = base64Decode(cachedCassette.response);
      final response = method.responseDeserializer(bytes);
      return ResponseFuture(MockClientCall(response));
    } else {
      final respFuture = invoker(method, request, options);
      respFuture.then((resp) {
        if (resp is GeneratedMessage) {
          final respEncoded = _encodeBytes(resp.writeToBuffer());
          final cassette = Cassette(
              methodPath: method.path,
              request: _encodeBytes(method.requestSerializer(request)),
              requestType: '${request.runtimeType}',
              response: respEncoded,
              responseType: '${resp.runtimeType}');
          _recordCassette(cassette);
        } else {
          log('could not encode response');
        }
      });
      return respFuture;
    }
  }

  void _recordCassette(Cassette cassette) {
    cachedCassettes = cachedCassettes..add(cassette);
  }

  Cassette? _getFirstMatchingCassette(
    String methodPath,
    String request,
  ) =>
      cachedCassettes.firstWhereOrNull((cassette) =>
          cassette.methodPath == methodPath && cassette.request == request);

  String _encodeBytes(List<int> bytes) => base64Encode(bytes);
}

class MockClientCall<R> extends Mock implements ClientCall<dynamic, R> {
  final R mockResponse;

  MockClientCall(this.mockResponse);

  @override
  Stream<R> get response => Stream.value(mockResponse);

  @override
  bool isCancelled = false;

  @override
  Future<void> cancel() async {}

  @override
  Future<Map<String, String>> get headers => Future.value({});

  @override
  void onConnectionError(error) {}

  @override
  void onConnectionReady(ClientConnection connection) {}

  @override
  CallOptions get options => CallOptions();

  @override
  Future<Map<String, String>> get trailers => Future.value({});
}
