import 'api_client.dart';
import 'models.dart';

class ESamsarApi {
  ESamsarApi(this.client);

  final ApiClient client;

  Future<DriverProfile> driverMe() async => DriverProfile.fromJson(await client.get('/api/drivers/me'));

  Future<ShipperProfile> shipperMe() async => ShipperProfile.fromJson(await client.get('/api/shippers/me'));

  Future<void> updateProfile({required String firstName, required String lastName, required String phone, String? profileImageUrl}) async {
    await client.put('/api/profile', {'firstName': firstName, 'lastName': lastName, 'phone': phone, 'profileImageUrl': profileImageUrl});
  }

  Future<void> updateDriver({
    String? firstName,
    String? lastName,
    String? phone,
    String? profileImageUrl,
    required String currentCity,
    required bool available,
  }) async {
    await client.put('/api/drivers/me', {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'currentCity': currentCity,
      'available': available,
    });
  }

  Future<void> updateShipper({
    required String firstName,
    required String lastName,
    required String phone,
    String? profileImageUrl,
    required String companyName,
    required String address,
  }) async {
    await client.put('/api/shippers/me', {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'companyName': companyName,
      'address': address,
    });
  }

  Future<DriverProfile> setAvailability(bool available) async {
    return DriverProfile.fromJson(await client.patch('/api/drivers/me/availability?available=$available'));
  }

  Future<List<OfferSummary>> offers({bool availableOnly = false}) async {
    final path = availableOnly ? '/api/offers/available?page=0&size=50' : '/api/offers?page=0&size=50';
    final offers = pageContent(await client.get(path), OfferSummary.fromJson);
    if (availableOnly && offers.isEmpty) {
      return pageContent(await client.get('/api/offers?page=0&size=50'), OfferSummary.fromJson);
    }
    return offers;
  }

  Future<List<OfferSummary>> myOffers() async {
    return pageContent(await client.get('/api/offers/my?page=0&size=50'), OfferSummary.fromJson);
  }

  Future<List<OfferSummary>> searchOffers({
    String? departureCity,
    String? arrivalCity,
    String? vehicleType,
    String? maxWeightKg,
  }) async {
    final query = {
      if ((departureCity ?? '').isNotEmpty) 'departureCity': departureCity!,
      if ((arrivalCity ?? '').isNotEmpty) 'arrivalCity': arrivalCity!,
      if ((vehicleType ?? '').isNotEmpty) 'vehicleType': vehicleType!,
      if ((maxWeightKg ?? '').isNotEmpty) 'maxWeightKg': maxWeightKg!,
      'page': '0',
      'size': '50',
    };
    return pageContent(await client.get('/api/offers/search?${Uri(queryParameters: query).query}'), OfferSummary.fromJson);
  }

  Future<Map<String, dynamic>> offerDetails(int id) async => await client.get('/api/offers/$id');

  Future<void> createOffer(Map<String, dynamic> body) async {
    await client.post('/api/offers', body);
  }

  Future<void> applyToOffer(int offerId, String message, String proposedPrice) async {
    await client.post('/api/offers/$offerId/applications', {
      'message': message,
      'proposedPrice': num.tryParse(proposedPrice) ?? 0,
    });
  }

  Future<List<dynamic>> myApplications() async {
    final json = await client.get('/api/applications/my?page=0&size=50');
    return (json['content'] as List?) ?? [];
  }

  Future<List<dynamic>> offerApplications(int offerId) async {
    final json = await client.get('/api/offers/$offerId/applications?page=0&size=50');
    return (json['content'] as List?) ?? [];
  }

  Future<void> acceptApplication(int id) async => await client.patch('/api/applications/$id/accept');

  Future<void> rejectApplication(int id) async => await client.patch('/api/applications/$id/reject');

  Future<void> cancelApplication(int id) async => await client.patch('/api/applications/$id/cancel');

  Future<void> startOffer(int id) async => await client.patch('/api/offers/$id/start');

  Future<void> completeOffer(int id) async => await client.patch('/api/offers/$id/complete');

  Future<void> cancelOffer(int id) async => await client.patch('/api/offers/$id/cancel');

  Future<void> deleteOffer(int id) => client.delete('/api/offers/$id');

  Future<List<TruckModel>> trucks() async {
    final json = await client.get('/api/trucks/me');
    return (json as List).whereType<Map<String, dynamic>>().map(TruckModel.fromJson).toList();
  }

  Future<void> saveTruck(Map<String, dynamic> body, {int? id}) async {
    if (id == null) {
      await client.post('/api/trucks', body);
    } else {
      await client.put('/api/trucks/$id', body);
    }
  }

  Future<void> setTruckActive(int id, bool active) async {
    await client.patch('/api/trucks/$id/${active ? 'activate' : 'deactivate'}');
  }

  Future<void> deleteTruck(int id) => client.delete('/api/trucks/$id');

  Future<List<DriverProfile>> drivers({String? city, String? vehicleType, String? minCapacityKg}) async {
    final query = {
      if ((city ?? '').isNotEmpty) 'city': city!,
      if ((vehicleType ?? '').isNotEmpty) 'vehicleType': vehicleType!,
      if ((minCapacityKg ?? '').isNotEmpty) 'minCapacityKg': minCapacityKg!,
      'page': '0',
      'size': '50',
    };
    return pageContent(await client.get('/api/drivers/search?${Uri(queryParameters: query).query}'), DriverProfile.fromJson);
  }

  Future<DriverProfile> driverDetails(int id) async => DriverProfile.fromJson(await client.get('/api/drivers/$id'));

  Future<List<TruckModel>> driverTrucks(int driverProfileId) async {
    final json = await client.get('/api/drivers/$driverProfileId/trucks');
    return (json as List).whereType<Map<String, dynamic>>().map(TruckModel.fromJson).toList();
  }

  Future<List<NotificationModel>> notifications({bool unread = false}) async {
    final json = await client.get(unread ? '/api/notifications/unread' : '/api/notifications?page=0&size=50');
    if (unread) {
      return (json as List).whereType<Map<String, dynamic>>().map(NotificationModel.fromJson).toList();
    }
    return pageContent(json, NotificationModel.fromJson);
  }

  Future<void> markNotificationRead(int id) async => await client.patch('/api/notifications/$id/read');

  Future<void> markAllNotificationsRead() async => await client.patch('/api/notifications/read-all');

  Future<void> deleteNotification(int id) => client.delete('/api/notifications/$id');

  Future<Map<String, dynamic>> aiChat(String message) async => await client.post('/api/ai/chat', {'message': message});

  Future<Map<String, dynamic>> whatsappDriver(int driverId) async => await client.get('/api/whatsapp/contact-driver/$driverId');

  Future<Map<String, dynamic>> whatsappShipper(int offerId) async => await client.get('/api/whatsapp/contact-shipper/$offerId');

  Future<void> createReview({required int offerId, required int reviewedUserId, required int rating, required String comment}) async {
    await client.post('/api/reviews', {
      'offerId': offerId,
      'reviewedUserId': reviewedUserId,
      'rating': rating,
      'comment': comment,
    });
  }
}
