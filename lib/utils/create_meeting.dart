import 'package:cloud_functions/cloud_functions.dart';

/// Updates the location of the device to the database and sends a request for a potential match.
Future<List<dynamic>> getMeetings(
  double latitude,
  double longitude,
  String locName,
  DateTime dateTime,
  bool paying,
) async {
  // Getting instance of the server function
  final callable = CloudFunctions.instance.getHttpsCallable(
    functionName: 'createMeeting',
  );

  // Adding variables to the server to the request and calling the function
  HttpsCallableResult resp = await callable.call(
    <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locName,
      'date_time': dateTime,
      'paying': paying,
    },
  );
  return resp.data;
}
