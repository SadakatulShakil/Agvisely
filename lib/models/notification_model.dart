DateTime? _secondsToDate(dynamic value) {
  final seconds = value is num ? value : num.tryParse(value?.toString() ?? '');
  return seconds == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch((seconds * 1000).round());
}


class NotificationModel {
  final int id;
  final String type; // all | user
  final String channel;
  final String title;
  final String body;
  final String? imageUrl;
  final String? imageName;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.channel,
    required this.title,
    required this.body,
    this.imageUrl,
    this.imageName,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> j) => NotificationModel(
        id: j['id'] as int,
        type: j['type']?.toString() ?? '',
        channel: j['channel']?.toString() ?? '',
        title: j['title']?.toString() ?? '',
        body: j['body']?.toString() ?? '',
        imageUrl: j['imageUrl']?.toString(),
        imageName: j['imageName']?.toString(),
        isRead: j['isRead'] == true,
        readAt: _secondsToDate(j['readAt']),
        createdAt: _secondsToDate(j['createdAt']) ?? DateTime.now(),
      );

  NotificationModel copyWith({bool? isRead, DateTime? readAt}) => NotificationModel(
        id: id,
        type: type,
        channel: channel,
        title: title,
        body: body,
        imageUrl: imageUrl,
        imageName: imageName,
        isRead: isRead ?? this.isRead,
        readAt: readAt ?? this.readAt,
        createdAt: createdAt,
      );
}

/// `meta` of a paginated `GET /notifications` response.
class NotificationPageMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const NotificationPageMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory NotificationPageMeta.fromJson(Map<String, dynamic> j) => NotificationPageMeta(
        page: j['page'] is int ? j['page'] as int : 1,
        limit: j['limit'] is int ? j['limit'] as int : 0,
        total: j['total'] is int ? j['total'] as int : 0,
        totalPages: j['totalPages'] is int ? j['totalPages'] as int : 0,
      );

  bool get hasMore => page < totalPages;
}
