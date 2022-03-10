import 'dart:convert';
import 'package:http/http.dart' as http;

class ZipCode {

  ///  郵便番号から住所を取得
  static Future <Map<String, String>> searchAddressFromZipCode(
      String zipCode) async {
    final url = 'https://zipcloud.ibsnet.co.jp/api/search?zipcode=$zipCode';
    Map<String, String> response = {};

    try {
      // 郵便番号データ取得
      final result = await http.get(Uri.parse(url));

      // デコード
      Map<String, dynamic> data = jsonDecode(result.body);

      // debug
      // print('★debug★searchAddressFromZipCode★');
      // print(data);

      // 返却データセット
      if (data['message'] != null) {
        // エラーメッセージがあるの場合
        response['message'] = data['message'];
      } else {
        if (data['results'] == null) {
          // 結果が取得できない場合
          response['message'] = '郵便番号に誤りがあります!!';
        } else {
          // 正常に取得できた場合
          response['address'] = data['results'][0]['address2'];
        }
      }
    } catch (e) {
      print('★ZipCode.searchAddressFromZipCode★CATCH★');
      print(e);
    }

    return response;
  }
}
