import 'package:latlong2/latlong.dart';

class AppConstants {
  static const String appName = 'SevakConnect';
  static const String appTagline = 'Pandharpur Wari Command & Police Dashboard';

  // Pandharpur Coordinates (17.6775° N, 75.3278° E)
  static const LatLng pandharpurCenter = LatLng(17.6775, 75.3278);
  static const LatLng vithobaTemple = LatLng(17.6782, 75.3288);
  static const LatLng chandrabhagaBridge = LatLng(17.6750, 75.3240);

  // Map zoom settings
  static const double defaultZoom = 15.0;
  static const double minZoom = 11.0;
  static const double maxZoom = 18.0;

  // OpenStreetMap Tile Server
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String osmUserAgent = 'com.sevakconnect.dashboard/1.0';

  // Dindis Constants
  static const String famousDindi = 'Dindi 108';
  static const List<String> dindiList = [
    'Dindi 108 (Sant Tukaram Palkhi)',
    'Dindi 1 (Sant Dnyaneshwar Maharaj)',
    'Dindi 27 (Alandi Sansthan)',
    'Dindi 42 (Dehu Sansthan)',
    'Dindi 56 (Varkari Shikshan Sanstha)',
    'Dindi 89 (Appasaheb Chopdar)',
  ];

  // Volunteer Roles
  static const List<String> volunteerRoles = [
    'All Roles',
    'Crowd Marshal',
    'Medical First Aid',
    'Jal Seva (Water)',
    'Darshan Queue Seva',
    'Lost & Found Escort',
    'Sanitation & Food',
  ];
}
