class Earthquake {
  final String id;
  final String latitude;
  final String longitude;
  final String depth;
  final String mag;
  final String location;
  final String date;
  final String time;

  Earthquake({required this.id, required this.latitude, required this.longitude, required this.depth, required this.mag, required this.location, required this.date, required this.time});

  factory Earthquake.fromFirestore(Map<String, dynamic> data, String id) {
    return Earthquake(
        id: id,
        latitude: data['Latitude'] as String,
        longitude: data['Longitude'] as String,
        depth: data['Depth'] as String,
        mag: data['Mag'] as String,
        location: data['Location'] as String,
        date: data['Date'] as String,
        time: data['Time'] as String

    );
  }
}