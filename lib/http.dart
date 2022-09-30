import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

void requestToServer(String arguments) async {
  var url =
  Uri.https('www.googleapis.com', '/books/v1/volumes', {'q': arguments});

  var response = await http.get(url);
  if (response.statusCode == 200) {
    var jsonResponse =
    convert.jsonDecode(response.body) as Map<String, dynamic>;
    var itemCount = jsonResponse['totalItems'];
    print('Number of books about $arguments: $itemCount.');
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
}