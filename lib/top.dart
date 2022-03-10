import 'package:flutter/material.dart';
import 'package:flutter_weather/zip_code.dart';
import 'package:flutter_weather/weather.dart';
import 'weather.dart';

import 'package:intl/intl.dart';

class TopPage extends StatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  late Weather currentWeather = Weather();
  late Map<String, List<Weather>> forecastWeather = <String, List<Weather>>{};
  late List<Weather> hourlyWeather = <Weather>[];
  late List<Weather> dailyWeather = <Weather>[];

  List<String> weekDay = ['月', '火', '水', '木', '金', '土', '日'];
  Map<String, String> response = {};
  String? errorMessage;
  String? address = '*';

  static const String imgPathBase = 'https://openweathermap.org/img/wn/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: 200,
              child: TextField(
                //keyboardAppearance: TextInputType.number,
                decoration: const InputDecoration(hintText: '郵便番号を入力'),
                onSubmitted: (value) async {
                  // 住所データ取得
                  response = await ZipCode.searchAddressFromZipCode(value);

                  if (response.containsKey('address')) {
                    address = response['address'];

                    // 現在の天気データ取得
                    currentWeather = await Weather.getCurrentWeather(value);

                    // 予報データ取得
                    forecastWeather = await Weather.getForecastWeather(
                      lon: currentWeather.lon!,
                      lat: currentWeather.lat!,
                    );
                    hourlyWeather = forecastWeather['hourly']!;
                    dailyWeather = forecastWeather['daily']!;
                  } else {
                    errorMessage = response['message'];
                  }
                  setState(() {});
                },
              ),
            ),
            Text(
              errorMessage == null ? '' : errorMessage.toString(),
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 50),
            Text(
              address.toString(),
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            Image.network('$imgPathBase${currentWeather.icon}.png'),
            Text(currentWeather.description == null
                ? '*'
                : currentWeather.description!),
            Text(
                currentWeather.temp == null
                    ? '*'
                    : currentWeather.temp!.toString() + '℃',
                style: const TextStyle(fontSize: 30)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(currentWeather.tempMin == null
                    ? '*'
                    : '最高:${currentWeather.tempMin}℃'),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('/'),
                ),
                Text(currentWeather.tempMax == null
                    ? '*'
                    : '最低:${currentWeather.tempMax}℃'),
              ],
            ),
            const SizedBox(height: 50),
            const Divider(height: 3),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: hourlyWeather.map((weather) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: Column(
                      children: [
                        Text('${DateFormat('HH').format(weather.time!)}時'),
                        Image.network('$imgPathBase${weather.icon}.png'),
                        Text('${weather.temp}℃'),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: dailyWeather.map((weather) {
                      return SizedBox(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 90,
                              child: Text(
                                  '${weather.time!.month}/${weather.time!.day}(${weekDay[weather.time!.weekday - 1]})'),
                            ),
                            Row(
                              children: [
                                Image.network(
                                    '$imgPathBase${weather.icon}.png'),
                                Text(
                                  '${weather.rainyPercent}%',
                                  style: const TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 90,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${weather.tempMin}℃'),
                                  const Text('/'),
                                  Text('${weather.tempMax}℃'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
