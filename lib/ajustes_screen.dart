import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  bool _modoOscuro = false;
  String _idioma = 'es';

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _modoOscuro = prefs.getBool('modoOscuro') ?? false;
      _idioma = prefs.getString('idioma') ?? 'es';
    });
  }

  Future<void> _cambiarModoOscuro(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modoOscuro', value);
    setState(() => _modoOscuro = value);
  }

  Future<void> _cambiarIdioma(String? value) async {
    if (value == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('idioma', value);
    setState(() => _idioma = value);
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
                        "Ajustes",
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
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSettingsSection(
                      title: 'Personalización',
                      icon: Icons.palette_outlined,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.translate, color: Colors.blue),
                          title: Text('Idioma', style: GoogleFonts.montserrat()),
                          trailing: DropdownButton<String>(
                            value: _idioma,
                            items: const [
                              DropdownMenuItem(value: 'es', child: Text('Español')),
                              DropdownMenuItem(value: 'en', child: Text('Inglés')),
                            ],
                            onChanged: _cambiarIdioma,
                          ),
                        ),
                        SwitchListTile(
                          title: Text('Modo Oscuro', style: GoogleFonts.montserrat()),
                          secondary: const Icon(Icons.nightlight_round, color: Colors.blue),
                          value: _modoOscuro,
                          onChanged: _cambiarModoOscuro,
                        ),
                      ],
                    ),
                    const Divider(color: Colors.grey),
                    _buildSettingsSection(
                      title: 'Soporte',
                      icon: Icons.help_outline,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.help, color: Colors.blue),
                          title: Text('Ayuda', style: GoogleFonts.montserrat()),
                          onTap: () => _mostrarDialogoAyuda(context),
                        ),
                        ListTile(
                          leading: const Icon(Icons.info, color: Colors.blue),
                          title: Text('Acerca de', style: GoogleFonts.montserrat()),
                          onTap: () => _mostrarDialogoAcercaDe(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  void _mostrarDialogoAyuda(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda'),
        content: const Text('Configura tus preferencias de la aplicación aquí.'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoAcercaDe(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acerca de'),
        content: const Text('Weather App v1.0\nDesarrollado por Guiu'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}