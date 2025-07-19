import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'api_error_response.g.dart';

@JsonSerializable()
class ApiErrorResponse extends Equatable {
  const ApiErrorResponse({
    required this.message,
    this.code,
    this.errors,
    this.statusCode,
  });

  final String message;
  final String? code;
  final Map<String, dynamic>? errors;
  @JsonKey(name: 'status_code')
  final int? statusCode;

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorResponseToJson(this);

  @override
  List<Object?> get props => [message, code, errors, statusCode];
}
