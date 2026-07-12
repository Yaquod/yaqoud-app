class TripHistoryResponse {
  final bool success;
  final String? message;
  final TripHistoryData? data;

  TripHistoryResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory TripHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TripHistoryResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? TripHistoryData.fromJson(json['data']) : null,
    );
  }
}

class TripHistoryData {
  final List<TripItem> content;
  final PageInfo? page;

  TripHistoryData({required this.content, this.page});

  factory TripHistoryData.fromJson(Map<String, dynamic> json) {
    return TripHistoryData(
      content: (json['content'] as List?)
              ?.map((item) => TripItem.fromJson(item))
              .toList() ?? [],
      page: json['page'] != null ? PageInfo.fromJson(json['page']) : null,
    );
  }
}

class TripItem {
  final int id;
  final String status; 
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime updatedAt;
  final double startLong;
  final double startLat;
  final double endLong;
  final double endLat;
  final double? amount;
  final String? currency;
  final int? ratingValue;
  final String carCompany;
  final String model;
  final String color;

  TripItem({
    required this.id,
    required this.status,
    required this.startedAt,
    this.endedAt,
    required this.updatedAt,
    required this.startLong,
    required this.startLat,
    required this.endLong,
    required this.endLat,
    this.amount,
    this.currency,
    this.ratingValue,
    required this.carCompany,
    required this.model,
    required this.color,
  });

  factory TripItem.fromJson(Map<String, dynamic> json) {
    return TripItem(
      id: json['id'],
      status: json['status'] ?? 'UNKNOWN',
      startedAt: DateTime.parse(json['startedAt']),
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      updatedAt: DateTime.parse(json['updatedAt']),
      startLong: (json['startLong'] as num).toDouble(),
      startLat: (json['startLat'] as num).toDouble(),
      endLong: (json['endLong'] as num).toDouble(),
      endLat: (json['endLat'] as num).toDouble(),
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      currency: json['currency'],
      ratingValue: json['ratingValue'],
      carCompany: json['carCompany'] ?? 'Robo',
      model: json['model'] ?? 'Taxi',
      color: json['color'] ?? 'BLACK',
    );
  }
}

class PageInfo {
  final int size;
  final int number;
  final int totalElements;
  final int totalPages;

  PageInfo({
    required this.size,
    required this.number,
    required this.totalElements,
    required this.totalPages,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      size: json['size'] ?? 0,
      number: json['number'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}