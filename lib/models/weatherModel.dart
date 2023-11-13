class WeatherModel {
  final double temp;
  final int humidity;
  final String weather;
  final String description;
  final String icon;

  WeatherModel.fromJson(Map<String, dynamic> json)
      : temp = (json['main']['temp'] as num).toDouble(),
        humidity = json['main']['humidity'],
        weather = json['weather'][0]['main'],
        description = json['weather'][0]['description'],
        icon = json['weather'][0]['icon'];

  Map<String, dynamic> toJson() {
    return {
      'temp': temp,
      'humidity': humidity,
      'weather': weather,
      'description': description,
      'icon': icon,
    };
  }
}
