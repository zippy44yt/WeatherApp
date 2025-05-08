import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:weather_animation/weather_animation.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final String _apiKey = 'b69a509cbbc3883026b545eb5a3fde71';
  final Location _locationService = Location();

  Map<String, dynamic>? _weatherData;
  bool _loading = true;
  bool _searching = false;
  String _currentTime = '';
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es', null).then((_) {
      _startClock();
      _initLocationAndWeather();
    });
  }

  void _startClock() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    });
  }

  Future<void> _initLocationAndWeather() async {
    if (!await _locationService.serviceEnabled() &&
        !await _locationService.requestService()) return;

    var p = await _locationService.hasPermission();
    if (p == PermissionStatus.denied) {
      p = await _locationService.requestPermission();
      if (p != PermissionStatus.granted) return;
    }

    final loc = await _locationService.getLocation();
    await _fetchWeather(loc.latitude!, loc.longitude!);
    setState(() => _loading = false);
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    final resp = await http.get(Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather'
          '?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=es',
    ));
    if (resp.statusCode == 200) {
      setState(() => _weatherData = json.decode(resp.body));
    }
  }

  Future<void> _searchCity(String city) async {
    setState(() {
      _searching = true;
      _weatherData = null;
    });

    final resp = await http.get(Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather'
          '?q=$city&appid=$_apiKey&units=metric&lang=es',
    ));
    if (resp.statusCode == 200) {
      setState(() => _weatherData = json.decode(resp.body));
    }

    setState(() => _searching = false);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _getWeatherDescription() {
    if (_weatherData == null) return '';
    return _weatherData!['weather'][0]['description'].toString().capitalize();
  }

  Color _getBackgroundColor() {
    if (_weatherData == null) return Colors.blue;
    final main = (_weatherData!['weather'][0]['main'] as String).toLowerCase();

    if (main.contains('rain') || main.contains('drizzle')) {
      return Colors.blueGrey;
    } else if (main.contains('cloud')) {
      return Colors.grey[700]!;
    } else if (main.contains('snow')) {
      return Colors.lightBlue[900]!;
    } else if (main.contains('thunder')) {
      return Colors.deepPurple[900]!;
    } else {
      return Colors.orange;
    }
  }

  Widget _buildScene() {
    if (_loading || _weatherData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final main = (_weatherData!['weather'][0]['main'] as String).toLowerCase();
    if (main.contains('rain') || main.contains('drizzle')) {
      return _rainyOvercast();
    } else if (main.contains('cloud')) {
      return _sunset();
    } else if (main.contains('snow')) {
      return _snowfall();
    } else if (main.contains('thunder')) {
      return _stormy();
    } else {
      return _scorchingSun();
    }
  }

  Widget _buildInfoBox() {
    if (_loading || _weatherData == null) {
      return const SizedBox();
    }
    final temp = (_weatherData!['main']['temp'] as num?)?.round() ?? 0;
    final city = _weatherData!['name'] as String? ?? '';
    final description = _getWeatherDescription();
    final humidity = _weatherData!['main']['humidity'] ?? 0;
    final windSpeed = (_weatherData!['wind']['speed'] as num?)?.toStringAsFixed(1) ?? '0.0';
    final tempMin = (_weatherData!['main']['temp_min'] as num?)?.round() ?? 0;
    final tempMax = (_weatherData!['main']['temp_max'] as num?)?.round() ?? 0;
    final feelsLike = (_weatherData!['main']['feels_like'] as num?)?.round() ?? 0;
    final pressure = _weatherData!['main']['pressure'] ?? 0;
    final pop = 0;
    final dateStr = DateFormat('EEEE, d MMMM', 'es').format(DateTime.now()).capitalize();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            city,
                            style: GoogleFonts.montserrat(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$temp°C',
                        style: GoogleFonts.montserrat(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    _infoChip(Icons.thermostat, 'Mín: $tempMin°C', Colors.blue),
                    _infoChip(Icons.thermostat_auto, 'Máx: $tempMax°C', Colors.red),
                    _infoChip(Icons.water_drop, 'Humedad: $humidity%', Colors.cyan),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    _infoChip(Icons.air, 'Viento: $windSpeed m/s', Colors.green),
                    _infoChip(Icons.opacity, 'Lluvia: ${pop.round()}%', Colors.indigo),
                    _infoChip(Icons.speed, 'Presión: $pressure hPa', Colors.orange),
                  ],
                ),
                const SizedBox(height: 8),
                _infoChip(Icons.device_thermostat, 'Sensación: $feelsLike°C', Colors.deepOrange),
                const SizedBox(height: 15),
                Text(
                  dateStr,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.montserrat(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.lightBlueAccent,
            Colors.lightBlueAccent.withOpacity(0.8),
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "Weather App Guiu",
                        style: GoogleFonts.montserrat(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  style: GoogleFonts.montserrat(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Buscar ciudad...",
                    hintStyle: GoogleFonts.montserrat(color: Colors.black54),
                    prefixIcon: const Icon(Icons.search, color: Colors.black54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  onSubmitted: _searchCity,
                ),
              ),
              if (_searching)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                width: double.infinity,
                child: _buildScene(),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildInfoBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scorchingSun() => const WrapperScene(
    sizeCanvas: Size(350, 540),
    isLeftCornerGradient: false,
    colors: [Color(0xffd50000), Color(0xffffd54f)],
    children: [
      SunWidget(
        sunConfig: SunConfig(
          width: 360,
          blurSigma: 17,
          blurStyle: BlurStyle.solid,
          isLeftLocation: true,
          coreColor: Color(0xfff57c00),
          midColor: Color(0xffffed58),
          outColor: Color(0xffffa726),
          animMidMill: 1500,
          animOutMill: 1500,
        ),
      ),
    ],
  );

  Widget _sunset() => const WrapperScene(
    sizeCanvas: Size(350, 540),
    isLeftCornerGradient: true,
    colors: [Color(0xff283593), Color(0xffff8a65)],
    children: [
      SunWidget(
        sunConfig: SunConfig(
          width: 262,
          blurSigma: 10,
          blurStyle: BlurStyle.solid,
          isLeftLocation: true,
          coreColor: Color(0xffffa726),
          midColor: Color(0xd6ffee58),
          outColor: Color(0xffff9800),
          animMidMill: 2000,
          animOutMill: 2000,
        ),
      ),
      WindWidget(
        windConfig: WindConfig(
          width: 5,
          y: 208,
          windGap: 10,
          blurSigma: 6,
          color: Color(0xff607d8b),
          slideXStart: 0,
          slideXEnd: 350,
          pauseStartMill: 50,
          pauseEndMill: 6000,
          slideDurMill: 1000,
          blurStyle: BlurStyle.solid,
        ),
      ),
      CloudWidget(
        cloudConfig: CloudConfig(
          size: 250,
          color: Color(0x66000000),
          icon: IconData(63056, fontFamily: 'MaterialIcons'),
          widgetCloud: null,
          x: 20,
          y: 35,
          scaleBegin: 1,
          scaleEnd: 1.08,
          scaleCurve: Cubic(0.40, 0.0, 0.20, 1.0),
          slideX: 20,
          slideY: 0,
          slideDurMill: 3000,
          slideCurve: Cubic(0.40, 0.0, 0.20, 1.0),
        ),
      ),
    ],
  );

  Widget _rainyOvercast() => const WrapperScene(
    sizeCanvas: Size(350, 540),
    isLeftCornerGradient: true,
    colors: [Color(0xff424242), Color(0xffcfd8dc)],
    children: [
      RainWidget(
        rainConfig: RainConfig(
          count: 30,
          lengthDrop: 13,
          widthDrop: 4,
          color: Color(0xff9e9e9e),
          isRoundedEndsDrop: true,
          widgetRainDrop: null,
          fallRangeMinDurMill: 500,
          fallRangeMaxDurMill: 1500,
          areaXStart: 41,
          areaXEnd: 264,
          areaYStart: 208,
          areaYEnd: 620,
          slideX: 2,
          slideY: 0,
          slideDurMill: 2000,
          slideCurve: Cubic(0.40, 0.0, 0.20, 1.0),
          fallCurve: Cubic(0.55, 0.09, 0.68, 0.53),
          fadeCurve: Cubic(0.95, 0.05, 0.80, 0.04),
        ),
      ),
      CloudWidget(
        cloudConfig: CloudConfig(
          size: 270,
          color: Color(0xccbdbdbd),
          icon: IconData(63056, fontFamily: 'MaterialIcons'),
          widgetCloud: null,
          x: 119,
          y: -50,
          scaleBegin: 1,
          scaleEnd: 1.1,
          scaleCurve: Cubic(0.40, 0.0, 0.20, 1.0),
          slideX: 11,
          slideY: 13,
          slideDurMill: 4000,
          slideCurve: Cubic(0.40, 0.0, 0.20, 1.0),
        ),
      ),
    ],
  );

  Widget _stormy() => const WrapperScene(
    sizeCanvas: Size(350, 180),
    isLeftCornerGradient: false,
    colors: [Color(0xff263238), Color(0xff78909c)],
    children: [
      CloudWidget(
        cloudConfig: CloudConfig(
          size: 120,
          color: Color(0xccbdbdbd),
          icon: IconData(63056, fontFamily: 'MaterialIcons'),
          widgetCloud: null,
          x: 80,
          y: -20,
          scaleBegin: 1,
          scaleEnd: 1.1,
          scaleCurve: Cubic(0.40, 0.0, 0.20, 1.0),
          slideX: 11,
          slideY: 13,
          slideDurMill: 4000,
          slideCurve: Cubic(0.40, 0.0, 0.20, 1.0),
        ),
      ),
      CloudWidget(
        cloudConfig: CloudConfig(
          size: 80,
          color: Color(0xffbdbdbd),
          icon: IconData(63056, fontFamily: 'MaterialIcons'),
          widgetCloud: null,
          x: 140,
          y: 30,
          scaleBegin: 1,
          scaleEnd: 1.08,
          scaleCurve: Cubic(0.40, 0.0, 0.20, 1.0),
          slideX: 20,
          slideY: 0,
          slideDurMill: 3000,
          slideCurve: Cubic(0.40, 0.0, 0.20, 1.0),
        ),
      ),
      WindWidget(
        windConfig: WindConfig(
          width: 5,
          y: 80,
          windGap: 10,
          blurSigma: 6,
          color: Color(0xff607d8b),
          slideXStart: 0,
          slideXEnd: 350,
          pauseStartMill: 50,
          pauseEndMill: 6000,
          slideDurMill: 1000,
          blurStyle: BlurStyle.solid,
        ),
      ),
      RainWidget(
        rainConfig: RainConfig(
          count: 20,
          lengthDrop: 10,
          widthDrop: 3,
          color: Color(0xff78909c),
          isRoundedEndsDrop: true,
          widgetRainDrop: null,
          fallRangeMinDurMill: 500,
          fallRangeMaxDurMill: 1500,
          areaXStart: 41,
          areaXEnd: 264,
          areaYStart: 60,
          areaYEnd: 180,
          slideX: 2,
          slideY: 0,
          slideDurMill: 2000,
          slideCurve: Cubic(0.40, 0.0, 0.20, 1.0),
          fallCurve: Cubic(0.55, 0.09, 0.68, 0.53),
          fadeCurve: Cubic(0.95, 0.05, 0.80, 0.04),
        ),
      ),
      ThunderWidget(
        thunderConfig: ThunderConfig(
          thunderWidth: 8,
          blurSigma: 18,
          blurStyle: BlurStyle.solid,
          color: Color(0xd6ffee58),
          flashStartMill: 50,
          flashEndMill: 300,
          pauseStartMill: 50,
          pauseEndMill: 6000,
          points: [Offset(110, 80), Offset(120, 120)],
        ),
      ),
    ],
  );

  Widget _snowfall() => const WrapperScene(
    sizeCanvas: Size(350, 540),
    isLeftCornerGradient: true,
    colors: [Color(0xff3949ab), Color(0xff90caf9), Color(0xffd6d6d6)],
    children: [
      SnowWidget(
        snowConfig: SnowConfig(
          count: 30,
          size: 20,
          color: Color(0xb3ffffff),
          icon: IconData(57399, fontFamily: 'MaterialIcons'),
          widgetSnowflake: null,
          areaXStart: 42,
          areaXEnd: 240,
          areaYStart: 200,
          areaYEnd: 540,
          waveRangeMin: 20,
          waveRangeMax: 70,
          waveMinSec: 5,
          waveMaxSec: 20,
          waveCurve: Cubic(0.45, 0.05, 0.55, 0.95),
          fadeCurve: Cubic(0.60, 0.04, 0.98, 0.34),
          fallMinSec: 10,
          fallMaxSec: 60,
        ),
      ),
    ],
  );
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}