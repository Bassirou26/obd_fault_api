import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diagnostic Moteur',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController rpmController = TextEditingController();
  final TextEditingController fuelRateController = 
TextEditingController();
  final TextEditingController throttleController = 
TextEditingController();
  final TextEditingController speedController = TextEditingController();
  final TextEditingController tempController = TextEditingController();
  final TextEditingController mafController = TextEditingController();

  String resultText = "";

  Future<void> sendData() async {
    try {
      final Map<String, dynamic> data = {
        "rpm": double.parse(rpmController.text),
        "fuel_rate": double.parse(fuelRateController.text),
        "throttle_pos": double.parse(throttleController.text),
        "speed": double.parse(speedController.text),
        "engine_temp": double.parse(tempController.text),
        "maf": double.parse(mafController.text),
      };

      final response = await http.post(
        Uri.parse('https://obd-fault-api.onrender.com/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          resultText =
              "🔧 Injecteur: ${result['injector_fault'] ? '❌ Défaut' : '✅ OK'}\n"
              "⛽ Surconsommation: ${result['fuel_overconsumption'] ? '❌ Oui' : '✅ Non'}";
        });
      } else {
        setState(() {
          resultText = "Erreur : ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        resultText = "Erreur de saisie ou serveur : $e";
      });
    }
  }

  Widget buildInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diagnostic Moteur 🚗"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            buildInput("RPM", rpmController),
            buildInput("Fuel rate (L/h)", fuelRateController),
            buildInput("Throttle position (%)", throttleController),
            buildInput("Vitesse (km/h)", speedController),
            buildInput("Température moteur (°C)", tempController),
            buildInput("MAF (g/s)", mafController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("🔍 Diagnostiquer", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            Text(
              resultText,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

