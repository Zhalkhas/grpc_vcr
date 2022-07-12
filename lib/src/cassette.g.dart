// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cassette.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cassette _$CassetteFromJson(Map<String, dynamic> json) => Cassette(
      methodPath: json['methodPath'] as String,
      request: json['request'] as String,
      requestType: json['requestType'] as String,
      response: json['response'] as String,
      responseType: json['responseType'] as String,
    );

Map<String, dynamic> _$CassetteToJson(Cassette instance) => <String, dynamic>{
      'methodPath': instance.methodPath,
      'request': instance.request,
      'requestType': instance.requestType,
      'response': instance.response,
      'responseType': instance.responseType,
    };
