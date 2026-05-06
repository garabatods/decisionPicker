import 'dart:convert';

import '../models/decision_group.dart';

class ShareService {
  static const String scheme = 'decisionpicker';
  static const String host = 'add-picker';

  /// Encodes a DecisionGroup into a shareable URL
  static String encodePickerToUrl(DecisionGroup picker) {
    final json = picker.toJson();
    print('Picker JSON: $json');
    final encoded = base64Url.encode(utf8.encode(jsonEncode(json)));
    final url = '$scheme://$host?data=$encoded';
    print('Encoded URL: $url');
    return url;
  }

  /// Decodes a URL into a DecisionGroup, returns null if invalid
  static DecisionGroup? decodeUrlToPicker(String url) {
    try {
      print('Decoding URL: $url');
      final uri = Uri.parse(url);
      print('Parsed URI: $uri');
      if (uri.scheme != scheme || uri.host != host) {
        print('Scheme or host mismatch');
        return null;
      }

      final data = uri.queryParameters['data'];
      print('Data parameter: $data');
      if (data == null) {
        print('No data parameter');
        return null;
      }

      final decoded = utf8.decode(base64Url.decode(data));
      print('Decoded data: $decoded');
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      print('Parsed JSON: $json');
      return DecisionGroup.fromJson(json);
    } catch (e) {
      print('Error decoding picker: $e');
      return null;
    }
  }
}