import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:evaluacion_interciclo/screens/main_screen.dart';
import 'package:evaluacion_interciclo/screens/gasto_screen.dart';
import 'package:evaluacion_interciclo/screens/ListaGastosScreen.dart';
import 'package:evaluacion_interciclo/screens/editar_gasto_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestor de Gastos',
      theme: ThemeData(primarySwatch: Colors.blue),

      locale: Locale("es", "ES"),
      supportedLocales: [Locale("es", "ES")],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Ruta inicial
      initialRoute: '/',

      // Mapa de rutas estáticas
      routes: {
        '/': (context) => MenuPrincipalScreen(),
        '/crearGasto': (context) => GastoScreen(),
        '/listaGastos': (context) => ListaGastosScreen(),
      },

      // Ruta dinámica para editar
      onGenerateRoute: (settings) {
        if (settings.name == '/editarGasto') {
          final args = settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
            builder:
                (context) => EditarGastoScreen(
                  id: args['id'],
                  descripcion: args['descripcion'],
                  monto: args['monto'],
                  fecha: args['fecha'],
                  idCategoria: args['idCategoria'],
                  idTipo: args['idTipo'],
                  observaciones: args['observaciones'],
                ),
          );
        }
        return null;
      },
    );
  }
}
