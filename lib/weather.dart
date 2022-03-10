import 'dart:convert';
import 'package:http/http.dart' as http;

class Weather {
  int? temp; // 気温
  int? tempMax; // 最高気温
  int? tempMin; // 最低気温
  String? description; // 天気状態
  double? lon; // 経度
  double? lat; // 緯度
  String? icon; // 画像アイコン
  DateTime? time; // 時刻
  int? rainyPercent; // 降水確率

  Weather({
    this.temp,
    this.tempMax,
    this.tempMin,
    this.description,
    this.lon,
    this.lat,
    this.icon,
    this.time,
    this.rainyPercent,
  });

  static const urlBase = 'https://api.openweathermap.org/data/2.5/';
  static const language = '&lang=ja';
  static const id = '&appid=19ba9d1e11d9116f25d61dc1cdaefb0b';
  static const units = '&units=metric';
  static const cnvRatio = 1000; //UnixTime10桁を13桁変換するための係数

  /// 現在天気データ取得
  static Future<Weather> getCurrentWeather(String zipCode) async {
    Weather currentWeather = Weather();

    // 郵便番号フォーマット
    final _zipCode = zipCode.contains('-')
        ? zipCode
        : zipCode.substring(0, 3) + '-' + zipCode.substring(3);

    // リクエストURL生成
    final url = '$urlBase/weather?zip=$_zipCode,jp$language$units$id';

    try {
      // 天気データ取得
      final result = await http.get(Uri.parse(url));

      // JSONデコード
      Map<String, dynamic> data = jsonDecode(result.body);

      // 返却データセット
      currentWeather = Weather(
        temp: double.parse(data['main']['temp'].toString()).toInt(),
        tempMax: double.parse(data['main']['temp_max'].toString()).toInt(),
        tempMin: double.parse(data['main']['temp_min'].toString()).toInt(),
        description: data['weather'][0]['description'],
        lon: data['coord']['lon'],
        lat: data['coord']['lat'],
        icon: data['weather'][0]['icon'],
        time: DateTime.fromMillisecondsSinceEpoch(data['dt'] * cnvRatio),
        //rainyPercent:
      );
    } catch (e) {
      print('★Weather.getCurrentWeather★CATCH★');
      print(e);
    }
    return currentWeather;
  }

  /// 予報データ取得
  static Future<Map<String, List<Weather>>> getForecastWeather(
      {required double lon, required double lat}) async {
    Map<String, List<Weather>> response = <String, List<Weather>>{};
    List<Weather> hourlyWeather = <Weather>[];
    List<Weather> dailyWeather = <Weather>[];

    // リクエストURL生成
    String url =
        '$urlBase/onecall?lat=$lat&lon=$lon&exclude=minutely$language$units$id';

    try {
      // 天気データ取得
      final result = await http.get(Uri.parse(url));

      // JSONデコード
      Map<String, dynamic> data = jsonDecode(result.body);

      // 返却データセット
      // 毎時データ
      List<dynamic> hourlyWeatherData = data['hourly'];
      hourlyWeather = hourlyWeatherData.map((weather) {
        return Weather(
          temp: double.parse(weather['temp'].toString()).toInt(),
          //tempMax:
          //tempMin:
          //description:
          //lon:
          //lat:
          icon: weather['weather'][0]['icon'],
          time: DateTime.fromMillisecondsSinceEpoch(weather['dt'] * cnvRatio),
          //rainyPercent:
        );
      }).toList();
      response['hourly'] = hourlyWeather;

      // 日データ
      List<dynamic> dailyWeatherData = data['daily'];
      dailyWeather = dailyWeatherData.map((weather) {
        return Weather(
          time: DateTime.fromMillisecondsSinceEpoch(weather['dt'] * cnvRatio),
          tempMax: double.parse(weather['temp']['max'].toString()).toInt(),
          tempMin: double.parse(weather['temp']['min'].toString()).toInt(),
          //description:
          //lon:
          //lat:
          icon: weather['weather'][0]['icon'],
          rainyPercent: weather.containsKey('rain')
              ? double.parse(weather['rain'].toString()).toInt()
              : 0,
        );
      }).toList();
      response['daily'] = dailyWeather;
    } catch (e) {
      print('★Weather.getForecastWeather★CATCH★');
      print(e);
    }
    return response;
  }
}
