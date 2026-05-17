# Order Of Testing End Points In Swagger

Swagger UI:

```text
http://localhost:9090/swagger-ui.html
```

OpenAPI JSON:

```text
http://localhost:9090/v3/api-docs
```

Use this file as a practical testing checklist. The recommended order is:

1. Start the backend and database.
2. Register and verify a shipper.
3. Register and verify a driver.
4. Login both users and copy their JWT tokens.
5. Test driver profile and truck setup.
6. Test shipper offer creation and matching.
7. Test driver application.
8. Test shipper accepting the application.
9. Test offer start, completion, payment, and reviews.
10. Test notifications, WhatsApp, AI, admin, and super-admin APIs.

## 0. Before Testing

### Required Environment Variables

Set these before running the app:

```powershell
$env:DB_USERNAME="root"
$env:DB_PASSWORD="your_mysql_password"
$env:JWT_SECRET="change-this-to-a-long-secret-key-at-least-32-characters"
$env:MISTRAL_API_KEY="your_mistral_api_key"
$env:MAIL_USERNAME="your_email@gmail.com"
$env:MAIL_PASSWORD="your_gmail_app_password"
mvn.cmd spring-boot:run
```

If email is not configured, registration may fail while trying to send verification email.

### Swagger Authorization

After login, copy `accessToken`.

In Swagger:

1. Click `Authorize`.
2. Paste:

```text
Bearer YOUR_ACCESS_TOKEN
```

3. Click `Authorize`.

You need different tokens for different roles:

- `SHIPPER` token
- `DRIVER` token
- `ADMIN` token
- `SUPER_ADMIN` token

## 1. Public Auth Endpoints

### 1.1 Register Shipper

Endpoint:

```http
POST /api/auth/register
```

Body:

```json
{
  "firstName": "Ali",
  "lastName": "Shipper",
  "email": "shipper@test.com",
  "password": "password123",
  "phone": "+212 600 000 001",
  "role": "SHIPPER"
}
```

What happens:

- Creates a disabled shipper account.
- Creates a shipper profile.
- Creates an email verification token.
- Sends verification email.

### 1.2 Register Driver

Endpoint:

```http
POST /api/auth/register
```

Body:

```json
{
  "firstName": "Omar",
  "lastName": "Driver",
  "email": "driver@test.com",
  "password": "password123",
  "phone": "+212 600 000 002",
  "role": "DRIVER"
}
```

What happens:

- Creates a disabled driver account.
- Creates a driver profile.
- Creates an email verification token.
- Sends verification email.

### 1.3 Verify Email

Endpoint:

```http
GET /api/auth/verify-email?token=TOKEN_FROM_EMAIL
```

What to give:

- The token sent by email.

What happens:

- Marks account as enabled.
- Marks email as verified.

If email sending is not working during local development, get the token from the `email_verification_token` table in MySQL.

### 1.4 Login Shipper

Endpoint:

```http
POST /api/auth/login
```

Body:

```json
{
  "email": "shipper@test.com",
  "password": "password123"
}
```

Save the returned `accessToken` as the shipper token.

### 1.5 Login Driver

Endpoint:

```http
POST /api/auth/login
```

Body:

```json
{
  "email": "driver@test.com",
  "password": "password123"
}
```

Save the returned `accessToken` as the driver token.

### 1.6 Forgot Password

Endpoint:

```http
POST /api/auth/forgot-password
```

Body:

```json
{
  "email": "driver@test.com"
}
```

What happens:

- Creates reset token.
- Sends password reset email.

### 1.7 Reset Password

Endpoint:

```http
POST /api/auth/reset-password
```

Body:

```json
{
  "token": "TOKEN_FROM_EMAIL_OR_DATABASE",
  "newPassword": "newPassword123"
}
```

### 1.8 Current User

Endpoint:

```http
GET /api/auth/me
```

Auth:

- Any logged-in user.

What happens:

- Returns the authenticated user without password.

### 1.9 Change Password

Endpoint:

```http
POST /api/auth/change-password
```

Auth:

- Any logged-in user.

Body:

```json
{
  "oldPassword": "password123",
  "newPassword": "newPassword123"
}
```

## 2. Profile Endpoints

### 2.1 Get Profile

Endpoint:

```http
GET /api/profile
```

Auth:

- Any logged-in user.

### 2.2 Update Profile

Endpoint:

```http
PUT /api/profile
```

Body:

```json
{
  "firstName": "Ali",
  "lastName": "Updated",
  "phone": "+212 600 111 111"
}
```

### 2.3 Change Password From Profile

Endpoint:

```http
PUT /api/profile/change-password
```

Body:

```json
{
  "oldPassword": "password123",
  "newPassword": "newPassword123"
}
```

## 3. Driver Profile And Trucks

Use the driver token in Swagger.

### 3.1 Get Current Driver Profile

Endpoint:

```http
GET /api/drivers/me
```

Auth:

- `DRIVER`

### 3.2 Update Current Driver Profile

Endpoint:

```http
PUT /api/drivers/me
```

Body:

```json
{
  "currentCity": "Casablanca",
  "available": true
}
```

### 3.3 Set Driver Availability

Endpoint:

```http
PATCH /api/drivers/me/availability?available=true
```

Query param:

```text
available=true
```

### 3.4 Create Truck

Endpoint:

```http
POST /api/trucks
```

Body:

```json
{
  "brand": "Mercedes",
  "model": "Sprinter",
  "plateNumber": "12345-A-6",
  "vehicleType": "VAN",
  "capacityKg": 1500,
  "active": true
}
```

Vehicle types:

```text
MOTORCYCLE, SMALL_VAN, PICKUP, VAN, SMALL_TRUCK, MEDIUM_TRUCK, BIG_TRUCK
```

### 3.5 List My Trucks

Endpoint:

```http
GET /api/trucks/me
```

### 3.6 Get Truck By Id

Endpoint:

```http
GET /api/trucks/{id}
```

Give:

- Truck id owned by current driver.

### 3.7 Update Truck

Endpoint:

```http
PUT /api/trucks/{id}
```

Body:

```json
{
  "brand": "Mercedes",
  "model": "Sprinter Updated",
  "plateNumber": "12345-A-6",
  "vehicleType": "VAN",
  "capacityKg": 1800,
  "active": true
}
```

### 3.8 Activate Truck

Endpoint:

```http
PATCH /api/trucks/{id}/activate
```

### 3.9 Deactivate Truck

Endpoint:

```http
PATCH /api/trucks/{id}/deactivate
```

### 3.10 Delete Truck

Endpoint:

```http
DELETE /api/trucks/{id}
```

## 4. Public Driver Browsing

Use any authenticated token.

### 4.1 List Drivers

Endpoint:

```http
GET /api/drivers?page=0&size=10
```

### 4.2 Get Driver By Id

Endpoint:

```http
GET /api/drivers/{id}
```

Give:

- Driver profile id.

### 4.3 Search Drivers

Endpoint:

```http
GET /api/drivers/search?city=Casablanca&vehicleType=VAN&minCapacityKg=1000
```

Query params are optional:

- `city`
- `vehicleType`
- `minCapacityKg`

## 5. Shipper Profile

Use the shipper token in Swagger.

### 5.1 Get Current Shipper Profile

Endpoint:

```http
GET /api/shippers/me
```

### 5.2 Update Current Shipper Profile

Endpoint:

```http
PUT /api/shippers/me
```

Body:

```json
{
  "companyName": "Atlas Logistics",
  "address": "Casablanca, Morocco"
}
```

### 5.3 Get Shipper By Id

Endpoint:

```http
GET /api/shippers/{id}
```

Give:

- Shipper profile id.

## 6. Offer Flow

Use the shipper token first.

### 6.1 Create Offer

Endpoint:

```http
POST /api/offers
```

Body:

```json
{
  "title": "Transport furniture to Rabat",
  "description": "Need a van for furniture delivery",
  "departureCity": "Casablanca",
  "arrivalCity": "Rabat",
  "pickupAddress": "Maarif, Casablanca",
  "deliveryAddress": "Agdal, Rabat",
  "goodsType": "FURNITURE",
  "weightKg": 700,
  "requiredVehicleType": "VAN",
  "proposedPrice": 1200,
  "maxDriversToNotify": 10,
  "transportDate": "2030-01-20T10:00:00"
}
```

Goods types:

```text
FOOD, FURNITURE, ELECTRONICS, CONSTRUCTION_MATERIALS, CLOTHES, AGRICULTURE, OTHER
```

What happens:

- Offer starts as `PENDING`.
- Matching service finds available drivers.
- Matching drivers receive database and WebSocket notifications.
- Offer becomes `NOTIFIED` if drivers were notified.

### 6.2 List My Offers

Endpoint:

```http
GET /api/offers/my?page=0&size=10
```

Auth:

- `SHIPPER`

### 6.3 Get Offer By Id

Endpoint:

```http
GET /api/offers/{id}
```

### 6.4 Update Offer

Endpoint:

```http
PUT /api/offers/{id}
```

Auth:

- Owner shipper only.

Rules:

- Cannot update if `ASSIGNED`, `IN_PROGRESS`, `COMPLETED`, or `CANCELED`.

Use same body as create offer.

### 6.5 List All Offers

Endpoint:

```http
GET /api/offers?page=0&size=10
```

### 6.6 Search Offers

Endpoint:

```http
GET /api/offers/search?departureCity=Casablanca&arrivalCity=Rabat&vehicleType=VAN&maxWeightKg=1000
```

Query params are optional:

- `departureCity`
- `arrivalCity`
- `vehicleType`
- `maxWeightKg`

### 6.7 Available Offers

Endpoint:

```http
GET /api/offers/available?page=0&size=10
```

Returns:

- `PENDING`
- `NOTIFIED`

### 6.8 Cancel Offer

Endpoint:

```http
PATCH /api/offers/{id}/cancel
```

Auth:

- Owner shipper or admin.

### 6.9 Delete Offer

Endpoint:

```http
DELETE /api/offers/{id}
```

Auth:

- Owner shipper or admin.

## 7. Matching

### 7.1 Get Matching Drivers For Offer

Endpoint:

```http
GET /api/matching/offers/{offerId}/drivers
```

What happens:

- Returns available drivers with compatible active trucks.
- Scores city match, truck capacity, rating, and completed jobs.

### 7.2 Notify Matching Drivers Again

Endpoint:

```http
POST /api/matching/offers/{offerId}/notify
```

What happens:

- Saves notifications.
- Pushes WebSocket notifications.

## 8. Application Flow

Use the driver token first.

### 8.1 Driver Applies To Offer

Endpoint:

```http
POST /api/offers/{offerId}/applications
```

Body:

```json
{
  "message": "I am available and have a van ready.",
  "proposedPrice": 1100
}
```

Rules:

- Driver cannot apply twice.
- Driver cannot apply to `CANCELED`, `COMPLETED`, or `ASSIGNED` offer.

### 8.2 Shipper Lists Offer Applications

Endpoint:

```http
GET /api/offers/{offerId}/applications?page=0&size=10
```

Auth:

- Owner shipper or admin.

### 8.3 Driver Lists Own Applications

Endpoint:

```http
GET /api/applications/my?page=0&size=10
```

Auth:

- `DRIVER`

### 8.4 Shipper Accepts Application

Endpoint:

```http
PATCH /api/applications/{applicationId}/accept
```

What happens:

- Accepted application becomes `ACCEPTED`.
- Offer gets assigned driver.
- Offer status becomes `ASSIGNED`.
- Other pending applications become `REJECTED`.
- Drivers receive notifications.

### 8.5 Shipper Rejects Application

Endpoint:

```http
PATCH /api/applications/{applicationId}/reject
```

### 8.6 Driver Cancels Own Application

Endpoint:

```http
PATCH /api/applications/{applicationId}/cancel
```

## 9. Start And Complete Transport

### 9.1 Start Offer

Endpoint:

```http
PATCH /api/offers/{id}/start
```

Auth:

- Owner shipper or assigned driver.

What happens:

- Offer status becomes `IN_PROGRESS`.

### 9.2 Complete Offer

Endpoint:

```http
PATCH /api/offers/{id}/complete
```

Auth:

- Owner shipper or admin.

What happens:

- Offer status becomes `COMPLETED`.
- Driver completed jobs increase.
- Shipper completed offers increase.
- Payment record is created.
- Assigned driver receives notification.

## 10. Reviews

Only users involved in a completed offer can review.

### 10.1 Shipper Reviews Driver

Endpoint:

```http
POST /api/reviews
```

Body:

```json
{
  "offerId": 1,
  "reviewedUserId": 2,
  "rating": 5,
  "comment": "Great driver, on time."
}
```

Use:

- `reviewedUserId` = driver user id, not driver profile id.

### 10.2 Driver Reviews Shipper

Endpoint:

```http
POST /api/reviews
```

Body:

```json
{
  "offerId": 1,
  "reviewedUserId": 1,
  "rating": 5,
  "comment": "Good communication."
}
```

Use:

- `reviewedUserId` = shipper user id, not shipper profile id.

### 10.3 Get Reviews For User

Endpoint:

```http
GET /api/reviews/user/{userId}?page=0&size=10
```

### 10.4 Get Reviews For Offer

Endpoint:

```http
GET /api/reviews/offer/{offerId}?page=0&size=10
```

### 10.5 My Received Reviews

Endpoint:

```http
GET /api/reviews/my-received?page=0&size=10
```

### 10.6 My Written Reviews

Endpoint:

```http
GET /api/reviews/my-written?page=0&size=10
```

### 10.7 Delete Review

Endpoint:

```http
DELETE /api/reviews/{id}
```

Auth:

- Review writer or admin.

## 11. Notifications

### 11.1 List Notifications

Endpoint:

```http
GET /api/notifications?page=0&size=10
```

### 11.2 List Unread Notifications

Endpoint:

```http
GET /api/notifications/unread
```

### 11.3 Mark One Notification As Read

Endpoint:

```http
PATCH /api/notifications/{id}/read
```

### 11.4 Mark All Notifications As Read

Endpoint:

```http
PATCH /api/notifications/read-all
```

### 11.5 Delete Notification

Endpoint:

```http
DELETE /api/notifications/{id}
```

## 12. WhatsApp Links

### 12.1 Contact Driver

Endpoint:

```http
GET /api/whatsapp/contact-driver/{driverId}
```

Give:

- Driver profile id.

Returns:

```json
{
  "phone": "+212 600 000 002",
  "whatsappUrl": "https://wa.me/212600000002"
}
```

### 12.2 Contact Shipper From Offer

Endpoint:

```http
GET /api/whatsapp/contact-shipper/{offerId}
```

Give:

- Offer id.

Returns:

```json
{
  "phone": "+212 600 000 001",
  "whatsappUrl": "https://wa.me/212600000001"
}
```

## 13. AI Chat

Use shipper or driver token.

### 13.1 Shipper Searches Drivers With AI

Endpoint:

```http
POST /api/ai/chat
```

Body:

```json
{
  "message": "I need a van in Casablanca that can carry 1000 kg"
}
```

What happens:

- Mistral extracts filters.
- Backend searches real drivers in database.
- Response includes matching drivers and WhatsApp links.

### 13.2 Driver Searches Offers With AI

Endpoint:

```http
POST /api/ai/chat
```

Body:

```json
{
  "message": "Find offers from Casablanca to Rabat for a van under 1000 kg"
}
```

What happens:

- Mistral extracts filters.
- Backend searches real offers in database.

### 13.3 AI History

Endpoint:

```http
GET /api/ai/history
```

### 13.4 Delete AI History

Endpoint:

```http
DELETE /api/ai/history
```

## 14. Payments

### 14.1 List Payments

Endpoint:

```http
GET /api/payments?page=0&size=10
```

Auth:

- `ADMIN`
- `SUPER_ADMIN`

Payments are created automatically when an offer is completed.

## 15. Admin Setup

There is no seed super-admin endpoint because creating admins requires `SUPER_ADMIN`.

For local testing, create a `SUPER_ADMIN` manually in MySQL or temporarily change an existing verified user role to `SUPER_ADMIN`.

Example SQL idea:

```sql
UPDATE users
SET role = 'SUPER_ADMIN', enabled = true, email_verified = true, account_locked = false
WHERE email = 'shipper@test.com';
```

Then login again and use the new token.

## 16. Super Admin Endpoints

Use `SUPER_ADMIN` token.

### 16.1 Create Admin

Endpoint:

```http
POST /api/super-admin/admins
```

Body:

```json
{
  "firstName": "Admin",
  "lastName": "User",
  "email": "admin@test.com",
  "password": "password123",
  "phone": "+212 600 000 003"
}
```

### 16.2 List Admins

Endpoint:

```http
GET /api/super-admin/admins?page=0&size=10
```

### 16.3 Delete Admin

Endpoint:

```http
DELETE /api/super-admin/admins/{id}
```

Give:

- Admin user id.

## 17. Admin User Management

Use `ADMIN` or `SUPER_ADMIN` token.

### 17.1 List Users

```http
GET /api/admin/users?page=0&size=10
```

### 17.2 Get User

```http
GET /api/admin/users/{id}
```

### 17.3 Lock User

```http
PATCH /api/admin/users/{id}/lock
```

### 17.4 Unlock User

```http
PATCH /api/admin/users/{id}/unlock
```

### 17.5 Enable User

```http
PATCH /api/admin/users/{id}/enable
```

### 17.6 Disable User

```http
PATCH /api/admin/users/{id}/disable
```

### 17.7 Delete User

```http
DELETE /api/admin/users/{id}
```

## 18. Admin Driver Management

### 18.1 List Drivers

```http
GET /api/admin/drivers?page=0&size=10
```

### 18.2 Get Driver

```http
GET /api/admin/drivers/{id}
```

Give:

- Driver profile id.

### 18.3 Get Driver Trucks

```http
GET /api/admin/drivers/{id}/trucks
```

### 18.4 Approve Driver

```http
PATCH /api/admin/drivers/{id}/approve
```

### 18.5 Suspend Driver

```http
PATCH /api/admin/drivers/{id}/suspend
```

## 19. Admin Shipper Management

### 19.1 List Shippers

```http
GET /api/admin/shippers?page=0&size=10
```

### 19.2 Get Shipper

```http
GET /api/admin/shippers/{id}
```

### 19.3 Suspend Shipper

```http
PATCH /api/admin/shippers/{id}/suspend
```

## 20. Admin Offer Management

### 20.1 List Offers

```http
GET /api/admin/offers?page=0&size=10
```

### 20.2 Get Offer

```http
GET /api/admin/offers/{id}
```

### 20.3 Cancel Offer

```http
PATCH /api/admin/offers/{id}/cancel
```

### 20.4 Delete Offer

```http
DELETE /api/admin/offers/{id}
```

## 21. Admin Truck Management

### 21.1 List Trucks

```http
GET /api/admin/trucks?page=0&size=10
```

### 21.2 Get Truck

```http
GET /api/admin/trucks/{id}
```

### 21.3 Delete Truck

```http
DELETE /api/admin/trucks/{id}
```

## 22. Admin Review Management

### 22.1 List Reviews

```http
GET /api/admin/reviews?page=0&size=10
```

### 22.2 Get Review

```http
GET /api/admin/reviews/{id}
```

### 22.3 Delete Review

```http
DELETE /api/admin/reviews/{id}
```

## 23. Admin Statistics

All require `ADMIN` or `SUPER_ADMIN`.

### 23.1 Full Statistics

```http
GET /api/admin/statistics
```

Returns:

```json
{
  "totalUsers": 0,
  "totalDrivers": 0,
  "totalShippers": 0,
  "totalOffers": 0,
  "completedOffers": 0,
  "canceledOffers": 0,
  "totalIncome": 0,
  "platformFees": 0
}
```

### 23.2 User Statistics

```http
GET /api/admin/statistics/users
```

### 23.3 Offer Statistics

```http
GET /api/admin/statistics/offers
```

### 23.4 Income Statistics

```http
GET /api/admin/statistics/income
```

### 23.5 Admin Payments

```http
GET /api/admin/payments?page=0&size=10
```

## 24. WebSocket Notifications

Swagger cannot test WebSocket subscriptions directly. Use a STOMP client.

Endpoint:

```text
ws://localhost:9090/ws
```

Connect header:

```text
Authorization: Bearer YOUR_ACCESS_TOKEN
```

Subscribe to:

```text
/user/queue/notifications
```

Notifications are pushed when:

- A matching offer is created.
- A driver applies.
- An application is accepted.
- An application is rejected.
- An offer is canceled.
- An offer is completed.
- A review is received.

## 25. Best End-To-End Test Order

Use this order when testing the whole platform:

1. Register shipper.
2. Verify shipper email.
3. Login shipper.
4. Register driver.
5. Verify driver email.
6. Login driver.
7. With driver token, update driver city to `Casablanca`.
8. With driver token, set availability to `true`.
9. With driver token, create active `VAN` truck with capacity `1500`.
10. With shipper token, create offer from `Casablanca` to `Rabat`, vehicle `VAN`, weight `700`.
11. Check matching drivers.
12. Check driver unread notifications.
13. With driver token, apply to the offer.
14. With shipper token, list applications for the offer.
15. With shipper token, accept the application.
16. Start offer with shipper or assigned driver token.
17. Complete offer with shipper token.
18. Check payment as admin.
19. Review driver with shipper token.
20. Review shipper with driver token.
21. Check statistics as admin.

