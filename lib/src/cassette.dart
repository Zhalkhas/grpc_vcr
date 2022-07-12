import 'package:json_annotation/json_annotation.dart';

part 'cassette.g.dart';

@JsonSerializable()
class Cassette {
  final String methodPath;
  final String request;
  final String requestType;
  final String response;
  final String responseType;

  Cassette({
    required this.methodPath,
    required this.request,
    required this.requestType,
    required this.response,
    required this.responseType,
  });

  factory Cassette.fromJson(Map<String, dynamic> json) =>
      _$CassetteFromJson(json);

  Map<String, dynamic> toJson() => _$CassetteToJson(this);
}
