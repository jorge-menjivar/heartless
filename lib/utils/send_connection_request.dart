import 'package:cloud_functions/cloud_functions.dart';
import 'package:location/location.dart';

Future<void> sendConnectionsRequest(String roomKey) async {
  // If the connections array has not been created yet, request the server to create it
  var location = Location();

  bool serviceEnabled;
  PermissionStatus permissionGranted;
  LocationData locationData;

  // Checking is location is enabled in device
  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();

    if (!serviceEnabled) {
      return false;
    }
  }

  // Checking if app has permission to get location
  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();

    if (permissionGranted != PermissionStatus.granted) {
      return false;
    }
  }

  // Getting location form device.
  locationData = await location.getLocation();

  // Getting instance of the server function
  final callable = CloudFunctions.instance.getHttpsCallable(
    functionName: 'getConnectionUsers',
  );

  // Adding variables to the server to the request and calling the function
  await callable.call(
    <String, dynamic>{
      'latitude': locationData.latitude,
      'longitude': locationData.longitude,
      'key': roomKey,
    },
  );

  return;
}
