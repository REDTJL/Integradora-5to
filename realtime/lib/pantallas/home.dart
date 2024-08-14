import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:after_layout/after_layout.dart';
import 'package:realtime/pantallas/login_page.dart';
import 'package:realtime/pantallas/seleccionVacunas.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'markerPointer.dart'; // Asegúrate de tener la ruta correcta

class Home extends StatefulWidget {
  final String nombre;
  final String apellido;

  const Home({super.key, required this.nombre, required this.apellido});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AfterLayoutMixin<Home> {
  DatabaseReference? db;
  double temperatura = 0, humedad = 0;
  Timer? _updateTimer;
  Timer? _uploadTimer;

  @override
  void initState() {
    super.initState();
    db = FirebaseDatabase.instance.ref("REFRIGERADOR");

    // Start a timer that updates the data every 5 seconds
    _updateTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      getData();
    });

    // Start a timer that uploads the data to Firestore every 60 segundos
    _uploadTimer = Timer.periodic(Duration(seconds: 60), (timer) {
      uploadDataToFirestore();
    });
  }

  Future<void> getData() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child("REFRIGERADOR/temperature/value").get();
    final snapshot1 = await ref.child("REFRIGERADOR/humidity/value").get();
    if (snapshot.exists) {
      setState(() {
        temperatura = double.parse(snapshot.value.toString());
        humedad = double.parse(snapshot1.value.toString());
      });
      debugPrint(snapshot.value.toString());
      debugPrint(snapshot1.value.toString());
    } else {
      debugPrint('No data available');
      setState(() {
        temperatura = -1;
        humedad = -1;
      });
    }
  }

  Future<void> uploadDataToFirestore() async {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    final documentId =
    now.toIso8601String(); // Use the current timestamp as the document ID

    await firestore.collection('temperatura').doc(documentId).set({
      'fecha': now.toIso8601String(),
      'temperatura': temperatura,
    });

    debugPrint(
        'Data uploaded to Firestore: fecha=${now.toIso8601String()}, temperatura=$temperatura');
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }

  @override
  void dispose() {
    _updateTimer?.cancel(); // Cancel the update timer
    _uploadTimer?.cancel(); // Cancel the upload timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1976D2),
        title: Image.asset('lib/images/logo.png',
            height: 20), // Cambia la ruta de la imagen si es necesario
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.power_settings_new, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Log Out',
          ),
        ],
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            Center(
              child: Text('Bienvenido a BioSafe ${widget.nombre} ${widget.apellido}',
                  style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 20),
            CustomMarkerPointer(
              value: temperatura,
              markerType: MarkerType.rectangle,
              color: Colors.black,
              markerHeight: 3,
              markerWidth: 30,
              annotationText: '$temperatura°C',
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1976D2),
                minimumSize: Size(double.infinity, 50), // Ocupa todo el ancho de la pantalla
                textStyle: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SeleccionVacunas(
                        nombre: widget.nombre,
                        apellido: widget.apellido,
                      )),
                );
              },
              child: Text(
                'Sacar vacunas',
                style: TextStyle(color: Colors.white),

              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Future<FutureOr<void>> afterFirstLayout(BuildContext context) async {
    await getData();
  }
}
