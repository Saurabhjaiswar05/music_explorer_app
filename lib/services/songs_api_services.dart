import 'dart:convert';

import 'package:http/http.dart' as http;

class SongsApiServices {
  Future<dynamic> getAllSongs() async {
    try {
      final response = await http.get(
        Uri.parse("https://itunes.apple.com/search?term=pop&entity=song"),
      );

      print("status code : ${response.statusCode}");
      // print("body : ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data;
      }
    } catch (e) {
      print(e);
    }
  }
}
