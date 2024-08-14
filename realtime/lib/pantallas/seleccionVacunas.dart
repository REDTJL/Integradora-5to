import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realtime/pantallas/home.dart'; // Importa tu pantalla de home

class SeleccionVacunas extends StatefulWidget {
  final String nombre;
  final String apellido;

  const SeleccionVacunas({super.key, required this.nombre, required this.apellido});

  @override
  _SeleccionVacunasState createState() => _SeleccionVacunasState();
}

class _SeleccionVacunasState extends State<SeleccionVacunas> {
  List<Map<String, dynamic>> vacunasData = [];
  List<int?> selectedCantidades = [];
  String pinAleatorio = '';

  @override
  void initState() {
    super.initState();
    fetchVacunasData();
  }

  Future<void> fetchVacunasData() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('Vacunas').get();

    final data = snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'nombre': doc['nVacunas'],
        'cantidad': int.parse(doc['cantidad']),
      };
    }).toList();

    setState(() {
      vacunasData = data;
      selectedCantidades = List<int?>.filled(data.length, null);
    });
  }

  void enviarDatos(String pin, String nombreCompleto) async {
    final dbRef = FirebaseDatabase.instance.ref();
    await dbRef.child('/PinEntrada').set(pin);
    await dbRef.child('/whoIsIt').set(nombreCompleto);

    final extraidosRef = dbRef.child('/Extraidos');
    Map<String, dynamic> extraidosData = {};
    for (int i = 0; i < vacunasData.length; i++) {
      if (selectedCantidades[i] != null && selectedCantidades[i]! > 0) {
        extraidosData[vacunasData[i]['id']] = {'cantidad': selectedCantidades[i]};
      }
    }
    await extraidosRef.set(extraidosData);
  }

  String generarPinAleatorio() {
    final random = Random();
    String pin = '';
    for (int i = 0; i < 4; i++) {
      pin += random.nextInt(10).toString();
    }
    return pin;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1976D2),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Seleccionar vacunas', style: TextStyle(color: Colors.white)),
      ),
      body: vacunasData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Text('Vacuna:', style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text('Cantidad:', style: TextStyle(fontSize: 18)),
          for (int i = 0; i < vacunasData.length; i++)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(vacunasData[i]['nombre'], style: TextStyle(fontSize: 16)),
                DropdownButton<int>(
                  value: selectedCantidades[i],
                  hint: Text(vacunasData[i]['cantidad'] == 0 ? 'Agotado' : 'Selecciona cantidad'),
                  items: List.generate(
                    vacunasData[i]['cantidad'] + 1,
                        (index) => DropdownMenuItem(
                      value: index,
                      child: Text(index.toString()),
                    ),
                  ),
                  onChanged: vacunasData[i]['cantidad'] == 0
                      ? null
                      : (value) {
                    setState(() {
                      selectedCantidades[i] = value;
                    });
                  },
                ),
              ],
            ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1976D2),
              minimumSize: Size(double.infinity, 50),
              textStyle: TextStyle(fontSize: 18),
            ),
            onPressed: pinAleatorio.isEmpty
                ? () {
              setState(() {
                pinAleatorio = generarPinAleatorio();
              });
              enviarDatos(pinAleatorio, '${widget.nombre} ${widget.apellido}');
            }
                : () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Home(nombre: widget.nombre, apellido: widget.apellido)),
              );
            },
            child: Text(
              pinAleatorio.isEmpty ? 'Abrir refrigerador' : 'Regresar',
              style: TextStyle(color: Colors.white),
            ),
          ),
          if (pinAleatorio.isNotEmpty) ...[
            SizedBox(height: 20),
            Text('PIN: $pinAleatorio', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Ingresa este PIN en el refrigerador', style: TextStyle(fontSize: 18)),
          ],
        ],
      ),
    );
  }
}
