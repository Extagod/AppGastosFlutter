import 'package:flutter/material.dart';

const double kButtonHeight = 50.0;
const double kSpacing = 16.0;
const EdgeInsets kPadding = EdgeInsets.all(24.0);
const TextStyle kTitleStyle = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  fontFamily: 'RobotoMono',
);

class MenuPrincipalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
      appBar: AppBar(
        title: const Text(
          'Gestor de Finanzas Kevin Cantos',
          style: TextStyle(fontFamily: 'RobotoMono'),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 123, 255),
      ),
      body: SingleChildScrollView(
        padding: kPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Text(
              '¡Bienvenido!',
              style: kTitleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Crear un nuevo Gasto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 140, 224, 139),
                minimumSize: const Size(double.infinity, kButtonHeight),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/crearGasto');
              },
            ),
            const SizedBox(height: kSpacing),
            ElevatedButton.icon(
              icon: const Icon(Icons.list),
              label: const Text('Mostrar Listado de Gastos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 107, 151, 238),
                minimumSize: const Size(double.infinity, kButtonHeight),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/listaGastos');
              },
            ),
            const SizedBox(height: kSpacing),
            ElevatedButton.icon(
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Salir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 121, 121),
                minimumSize: const Size(double.infinity, kButtonHeight),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 32),
            const SizedBox(height: 40),
            Image.asset(
              'assets/images/logo.png',
              height: 300,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
