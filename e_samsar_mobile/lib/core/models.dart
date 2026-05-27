class UserModel {
  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.profileImageUrl,
    required this.role,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String profileImageUrl;
  final String role;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawRole = json['role']?.toString() ?? '';
    return UserModel(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      role: normalizeRole(rawRole),
    );
  }

  String get fullName => '$firstName $lastName'.trim();

  static String normalizeRole(String rawRole) {
    final role = rawRole.trim().toUpperCase();
    if (role.contains('SHIPPER')) return 'SHIPPER';
    if (role.contains('DRIVER')) return 'DRIVER';
    if (role.contains('SUPER_ADMIN')) return 'SUPER_ADMIN';
    if (role.contains('ADMIN')) return 'ADMIN';
    return role;
  }
}

class DriverProfile {
  DriverProfile({
    required this.id,
    required this.user,
    required this.currentCity,
    required this.available,
    required this.averageRating,
    required this.completedJobs,
  });

  final int id;
  final UserModel user;
  final String currentCity;
  final bool available;
  final double averageRating;
  final int completedJobs;

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      id: json['id'] ?? 0,
      user: UserModel.fromJson(json['user'] ?? {}),
      currentCity: json['currentCity'] ?? '',
      available: json['available'] ?? false,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      completedJobs: json['completedJobs'] ?? 0,
    );
  }
}

class ShipperProfile {
  ShipperProfile({
    required this.id,
    required this.user,
    required this.companyName,
    required this.address,
    required this.averageRating,
    required this.completedOffers,
  });

  final int id;
  final UserModel user;
  final String companyName;
  final String address;
  final double averageRating;
  final int completedOffers;

  factory ShipperProfile.fromJson(Map<String, dynamic> json) {
    return ShipperProfile(
      id: json['id'] ?? 0,
      user: UserModel.fromJson(json['user'] ?? {}),
      companyName: json['companyName'] ?? '',
      address: json['address'] ?? '',
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      completedOffers: json['completedOffers'] ?? 0,
    );
  }
}

class OfferSummary {
  OfferSummary({
    required this.id,
    required this.title,
    required this.departureCity,
    required this.arrivalCity,
    required this.weightKg,
    required this.vehicleType,
    required this.price,
    required this.status,
    this.transportDate,
  });

  final int id;
  final String title;
  final String departureCity;
  final String arrivalCity;
  final double weightKg;
  final String vehicleType;
  final num price;
  final String status;
  final String? transportDate;

  factory OfferSummary.fromJson(Map<String, dynamic> json) {
    return OfferSummary(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      departureCity: json['departureCity'] ?? '',
      arrivalCity: json['arrivalCity'] ?? '',
      weightKg: (json['weightKg'] ?? 0).toDouble(),
      vehicleType: json['requiredVehicleType'] ?? '',
      price: json['proposedPrice'] ?? 0,
      status: json['status'] ?? '',
      transportDate: json['transportDate'],
    );
  }
}

class TruckModel {
  TruckModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.imageUrl,
    required this.plateNumber,
    required this.vehicleType,
    required this.capacityKg,
    required this.active,
  });

  final int id;
  final String brand;
  final String model;
  final String imageUrl;
  final String plateNumber;
  final String vehicleType;
  final double capacityKg;
  final bool active;

  factory TruckModel.fromJson(Map<String, dynamic> json) {
    return TruckModel(
      id: json['id'] ?? 0,
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      plateNumber: json['plateNumber'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      capacityKg: (json['capacityKg'] ?? 0).toDouble(),
      active: json['active'] ?? false,
    );
  }
}

class NotificationModel {
  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.seen,
    required this.offerId,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String message;
  final String type;
  final bool seen;
  final int? offerId;
  final String createdAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      seen: json['seen'] ?? false,
      offerId: (json['offerId'] as num?)?.toInt(),
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

List<T> pageContent<T>(dynamic json, T Function(Map<String, dynamic>) fromJson) {
  final raw = json is Map<String, dynamic> ? json['content'] : json;
  if (raw is! List) {
    return [];
  }
  return raw.whereType<Map<String, dynamic>>().map(fromJson).toList();
}
