import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_animation/weather_animation.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class PantallaPronostico extends StatefulWidget {
  const PantallaPronostico({super.key});

  @override
  State<PantallaPronostico> createState() => _PantallaPronosticoState();
}

class _PantallaPronosticoState extends State<PantallaPronostico> {
  List<MapEntry<String, List<dynamic>>> _pronostico = [];
  bool _cargando = true;
  String _ciudadActual = '';
  double _latitud = 0;
  double _longitud = 0;
  String _mesActual = '';
  final TextEditingController _controller = TextEditingController();
  final String _apiKey = 'b69a509cbbc3883026b545eb5a3fde71';

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionYPronostico();
  }

  Future<void> _obtenerUbicacionYPronostico() async {
    setState(() {
      _cargando = true;
    });
    final location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() => _cargando = false);
        return;
      }
    }
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() => _cargando = false);
        return;
      }
    }
    final locData = await location.getLocation();
    _latitud = locData.latitude ?? 0.0;
    _longitud = locData.longitude ?? 0.0;
    await _obtenerPronosticoPorCoordenadas(_latitud, _longitud);
  }

  Future<void> _obtenerPronosticoPorCoordenadas(double lat, double lon) async {
    setState(() {
      _cargando = true;
    });
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=es';
    final respuesta = await http.get(Uri.parse(url));
    if (respuesta.statusCode == 200) {
      final datos = json.decode(respuesta.body);
      final Map<String, List<dynamic>> dias = {};
      for (var item in datos['list']) {
        final fecha = item['dt_txt'].substring(0, 10);
        dias.putIfAbsent(fecha, () => []).add(item);
      }
      setState(() {
        _pronostico = dias.entries.take(5).toList();
        _ciudadActual = datos['city']['name'] ?? '';
        _latitud = datos['city']['coord']['lat'] ?? lat;
        _longitud = datos['city']['coord']['lon'] ?? lon;
        DateTime fecha = DateTime.parse(_pronostico[0].key);
        _mesActual = DateFormat('MMMM', 'es').format(fecha).capitalize();
        _cargando = false;
      });
    } else {
      setState(() => _cargando = false);
    }
  }

  Future<void> _buscarCiudad(String ciudad) async {
    if (ciudad.trim().isEmpty) {
      await _obtenerUbicacionYPronostico();
      return;
    }
    setState(() {
      _cargando = true;
    });
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?q=$ciudad&appid=$_apiKey&units=metric&lang=es';
    final respuesta = await http.get(Uri.parse(url));
    if (respuesta.statusCode == 200) {
      final datos = json.decode(respuesta.body);
      final Map<String, List<dynamic>> dias = {};
      for (var item in datos['list']) {
        final fecha = item['dt_txt'].substring(0, 10);
        dias.putIfAbsent(fecha, () => []).add(item);
      }
      setState(() {
        _pronostico = dias.entries.take(5).toList();
        _ciudadActual = datos['city']['name'] ?? '';
        _latitud = datos['city']['coord']['lat'] ?? 0.0;
        _longitud = datos['city']['coord']['lon'] ?? 0.0;
        DateTime fecha = DateTime.parse(_pronostico[0].key);
        _mesActual = DateFormat('MMMM', 'es').format(fecha).capitalize();
        _cargando = false;
      });
    } else {
      setState(() {
        _cargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ciudad no encontrada')),
      );
    }
  }

  Widget _widgetMeteorologico(String main) {
    main = main.toLowerCase();
    if (main.contains('rain') || main.contains('lluvia') || main.contains('drizzle')) {
      return _rainyOvercast();
    } else if (main.contains('cloud') || main.contains('nube')) {
      return _sunset();
    } else if (main.contains('snow') || main.contains('nieve')) {
      return _snowfall();
    } else if (main.contains('thunder') || main.contains('tormenta')) {
      return _stormy();
    } else {
      return _scorchingSun();
    }
  }

  Widget _scorchingSun() => const WrapperScene(
    sizeCanvas: Size(350, 180),
    isLeftCornerGradient: false,
    colors: [Color(0xffd50000), Color(0xffffd54f)],
    children: [
      SunWidget(
        sunConfig: SunConfig(
          width: 180,
          blurSigma: 10,
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
    sizeCanvas: Size(350, 180),
    isLeftCornerGradient: true,
    colors: [Color(0xff283593), Color(0xffff8a65)],
    children: [
      SunWidget(
        sunConfig: SunConfig(
          width: 120,
          blurSigma: 7,
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
      CloudWidget(
        cloudConfig: CloudConfig(
          size: 100,
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
    sizeCanvas: Size(350, 180),
    isLeftCornerGradient: true,
    colors: [Color(0xff424242), Color(0xffcfd8dc)],
    children: [
      RainWidget(
        rainConfig: RainConfig(
          count: 15,
          lengthDrop: 10,
          widthDrop: 3,
          color: Color(0xff9e9e9e),
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
      CloudWidget(
        cloudConfig: CloudConfig(
          size: 120,
          color: Color(0xccbdbdbd),
          icon: IconData(63056, fontFamily: 'MaterialIcons'),
          widgetCloud: null,
          x: 119,
          y: -10,
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
    sizeCanvas: Size(350, 180),
    isLeftCornerGradient: true,
    colors: [Color(0xff3949ab), Color(0xff90caf9), Color(0xffd6d6d6)],
    children: [
      SnowWidget(
        snowConfig: SnowConfig(
          count: 10,
          size: 10,
          color: Color(0xb3ffffff),
          icon: IconData(57399, fontFamily: 'MaterialIcons'),
          widgetSnowflake: null,
          areaXStart: 42,
          areaXEnd: 240,
          areaYStart: 60,
          areaYEnd: 180,
          waveRangeMin: 10,
          waveRangeMax: 30,
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
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
                        "$_ciudadActual · $_mesActual",
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: TextField(
                  controller: _controller,
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
                  onSubmitted: (value) {
                    _buscarCiudad(value);
                    _controller.clear();
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _cargando
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: _pronostico.length,
                  itemBuilder: (context, indice) {
                    final dia = _pronostico[indice];
                    final fecha = dia.key;
                    final items = dia.value;

                    final weather = (items[0]['weather'] != null && items[0]['weather'].isNotEmpty)
                        ? items[0]['weather'][0]
                        : {};
                    final main = items[0]['main'] ?? {};
                    final wind = items[0]['wind'] ?? {};
                    final pop = items[0]['pop'] ?? 0.0;
                    final temp = main['temp']?.round() ?? 0;
                    final tempMin = main['temp_min']?.round() ?? 0;
                    final tempMax = main['temp_max']?.round() ?? 0;
                    final humidity = main['humidity'] ?? 0;
                    final pressure = main['pressure'] ?? 0;
                    final feelsLike = main['feels_like']?.round() ?? 0;
                    final windSpeed = wind['speed'] != null
                        ? wind['speed'].toStringAsFixed(1)
                        : '0.0';
                    final clima = weather['description'] ?? '';
                    final mainWeather = weather['main'] ?? '';

                    final DateTime fechaDT = DateTime.parse(fecha);
                    final DateTime hoy = DateTime.now();
                    final bool esHoy = hoy.year == fechaDT.year &&
                        hoy.month == fechaDT.month &&
                        hoy.day == fechaDT.day;
                    final String nombreDia = esHoy
                        ? "Hoy"
                        : DateFormat('EEEE', 'es').format(fechaDT).capitalize();
                    final String numeroDia = DateFormat('d', 'es').format(fechaDT);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$nombreDia $numeroDia",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$clima, $temp°C',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
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
                                    _infoChip(Icons.opacity, 'Lluvia: ${(pop * 100).round()}%', Colors.indigo),
                                    _infoChip(Icons.speed, 'Presión: $pressure hPa', Colors.orange),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _infoChip(Icons.device_thermostat, 'Sensación: $feelsLike°C', Colors.deepOrange),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 120,
                                  width: double.infinity,
                                  child: _widgetMeteorologico(mainWeather),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}