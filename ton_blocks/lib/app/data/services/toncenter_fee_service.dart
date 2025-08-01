import 'dart:convert';
import 'package:http/http.dart' as http;

class TonFeeService {
static const String backendUrl = 'http://192.168.1.104:3000/generate-boc';
  static const String tonCenterUrl = 'https://toncenter.com/api/v2/estimateFee';
  static const String tonApiKey = '2c964ec467e0583745f7c835c2e0d3a63049e6ece293648319e1fe0d664fd57c';

  static Future<String?> getBoc(String toAddress, String amount) async {
    final response = await http.post(
      Uri.parse(backendUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'toAddress': toAddress, 'amount': amount}),
    );

    if (response.statusCode == 200) {
      final boc = jsonDecode(response.body)['boc'];
      print('Generated BOC: $boc');
      return boc;
    } else {
      print('Error fetching BOC: ${response.body}');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> estimateFee(String address, String boc) async {
    final response = await http.post(
      Uri.parse(tonCenterUrl),
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': tonApiKey,
      },
      body: jsonEncode({
        'address': address,
        'body': boc,
        'init_code': null,
        'init_data': null,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['ok'] == true && data['result'] != null && data['result']['source_fees'] != null) {
        return data['result']['source_fees'];
      }
    }
    print('Error estimating fee: ${response.body}');
    return null;
  }
}
