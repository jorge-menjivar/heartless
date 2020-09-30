import 'package:cloud_functions/cloud_functions.dart';
import 'package:location/location.dart';

/// Updates the location of the device to the database and sends a request for a potential match.
Future<List<dynamic>> getMeetings() async {
  var location = Location();

  print(location);

  bool serviceEnabled;
  PermissionStatus permissionGranted;
  LocationData locationData;

  // Checking is location is enabled in device
  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();

    if (!serviceEnabled) {
      return null;
    }
  }

  // Checking if app has permission to get location
  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();

    if (permissionGranted != PermissionStatus.granted) {
      return null;
    }
  }

  // Getting location form device.
  locationData = await location.getLocation();

  // Getting instance of the server function
  final callable = CloudFunctions.instance.getHttpsCallable(
    functionName: 'getMeetings',
  );

  // Adding variables to the server to the request and calling the function
  HttpsCallableResult resp = await callable.call(
    <String, dynamic>{
      'latitude': locationData.latitude,
      'longitude': locationData.longitude,
    },
  );

  return resp.data;
}
