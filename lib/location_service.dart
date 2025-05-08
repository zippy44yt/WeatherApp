import 'package:location/location.dart';

class LocationService {
  final Location _loc = Location();

  Future<LocationData?> getLocation() async {
    if (!await _loc.serviceEnabled() && !await _loc.requestService()) {
      return null;
    }

    var permission = await _loc.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _loc.requestPermission();
      if (permission != PermissionStatus.granted) return null;
    }

    return await _loc.getLocation();
  }
}