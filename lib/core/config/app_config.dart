class AppConfig {
  // change this one value depending on where you run:
  // '10.0.2.2'   → Android emulator
  // 'localhost'  → web or iOS simulator
  // '192.168.x.x' → physical Android device (your PC's local IP)
  static const String host = 'localhost'; // 👈 change this only

  static const String apiBaseUrl = 'http://$host:4000';
  static const String minioBaseUrl = 'http://$host:9000';
}
