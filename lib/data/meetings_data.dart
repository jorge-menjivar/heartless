import 'models/meetings_model.dart';

abstract class MeetingsData {
  Future<Meetings> fetchData(var meetingsDocs);
  Future<Meetings> updateData(var meetingsList, var meetingsDocs);
}

class MeetingsRepository implements MeetingsData {
  @override
  Future<Meetings> fetchData(var meetingsDocs) async {
    final data = await loadMeetingsData(meetingsDocs);
    return Meetings(list: data);
  }

  @override
  Future<Meetings> updateData(var meetingsList, var meetingsDocs) async {
    final data = await updateMeetingsData(meetingsList, meetingsDocs);
    return Meetings(list: data);
  }

  Future<List> loadMeetingsData(var meetingsDocs) async {
    var list = [];
    for (var meet in meetingsDocs) {
      try {
        var values = {
          'uid': meet['uid'],
          'rating': meet['rating'],
          'gender': meet['gender'],
          'location': meet['location'],
          'location_name': meet['location_name'],
          'edit_time': meet['edit_time'],
          'paying': meet['paying'],
          'distance': meet['distance'],
          'age': meet['age'],
        };
        list.add(values);
      } catch (e) {
        print(e);
      }
    }
    return list;
  }

  Future<List> updateMeetingsData(var meetingsList, var meetingsDocs) async {
    var list = meetingsList;
    for (var meet in meetingsDocs) {
      try {
        var values = {
          'uid': meet['uid'],
          'rating': meet['rating'],
          'gender': meet['gender'],
          'location': meet['location'],
          'location_name': meet['location_name'],
          'edit_time': meet['edit_time'],
          'paying': meet['paying'],
          'distance': meet['distance'],
          'age': meet['age'],
        };
        list.add(values);
      } catch (e) {
        print(e);
      }
    }
    return list;
  }
}
