import 'package:get/get.dart';

/// One day's forecast — static demo data until the 7-day series endpoint
/// (see `ApiEndpoints.weatherForecast`) is wired up.
class DailyForecastDemo {
  const DailyForecastDemo({
    required this.dayLabel,
    required this.dateLabel,
    required this.highC,
    required this.lowC,
    required this.condition,
    required this.feelsLike,
    required this.rainfall,
    required this.cloudCoverage,
    required this.humidity,
    required this.soilMoisture,
    required this.sunshine,
    required this.wind,
    required this.windDeg,
    required this.thi,
  });

  final String dayLabel;
  final String dateLabel;
  final String highC;
  final String lowC;
  final String condition;
  final String feelsLike;
  final String rainfall;
  final String cloudCoverage;
  final String humidity;
  final String soilMoisture;
  final String sunshine;
  final String wind;
  final double windDeg;
  final String thi;
}

/// Weather Forecast — screen state. [days] is a static demo list until the
/// forecast series endpoint exists; only the current-conditions card on
/// Home reads live data today.
class WeatherController extends GetxController {
  final isLoading = false.obs;

  /// Index of the day card whose graph is expanded; -1 = all collapsed.
  final expandedIndex = (-1).obs;

  void toggleExpanded(int index) {
    expandedIndex.value = expandedIndex.value == index ? -1 : index;
  }

  final List<DailyForecastDemo> days = const [
    DailyForecastDemo(
      dayLabel: 'Today',
      dateLabel: '20 September 2026',
      highC: '36',
      lowC: '29',
      condition: 'Cloudy with light rain',
      feelsLike: '34°C',
      rainfall: '0-4 mm',
      cloudCoverage: '43%',
      humidity: '89%',
      soilMoisture: '33.3%',
      sunshine: '08 hrs',
      wind: '23 km/h',
      windDeg: 45,
      thi: '73.8',
    ),
    DailyForecastDemo(
      dayLabel: 'Monday',
      dateLabel: '21 September 2026',
      highC: '35',
      lowC: '28',
      condition: 'Partly cloudy',
      feelsLike: '33°C',
      rainfall: '0-2 mm',
      cloudCoverage: '38%',
      humidity: '82%',
      soilMoisture: '31.0%',
      sunshine: '07 hrs',
      wind: '19 km/h',
      windDeg: 70,
      thi: '72.1',
    ),
    DailyForecastDemo(
      dayLabel: 'Tuesday',
      dateLabel: '22 September 2026',
      highC: '34',
      lowC: '27',
      condition: 'Light showers',
      feelsLike: '32°C',
      rainfall: '4-8 mm',
      cloudCoverage: '56%',
      humidity: '91%',
      soilMoisture: '36.4%',
      sunshine: '05 hrs',
      wind: '26 km/h',
      windDeg: 110,
      thi: '71.5',
    ),
    DailyForecastDemo(
      dayLabel: 'Wednesday',
      dateLabel: '23 September 2026',
      highC: '35',
      lowC: '28',
      condition: 'Sunny',
      feelsLike: '34°C',
      rainfall: '0 mm',
      cloudCoverage: '20%',
      humidity: '68%',
      soilMoisture: '27.8%',
      sunshine: '10 hrs',
      wind: '15 km/h',
      windDeg: 200,
      thi: '73.0',
    ),
    DailyForecastDemo(
      dayLabel: 'Thursday',
      dateLabel: '24 September 2026',
      highC: '36',
      lowC: '29',
      condition: 'Cloudy with light rain',
      feelsLike: '34°C',
      rainfall: '0-4 mm',
      cloudCoverage: '43%',
      humidity: '89%',
      soilMoisture: '33.3%',
      sunshine: '08 hrs',
      wind: '23 km/h',
      windDeg: 45,
      thi: '73.8',
    ),
  ];
}
