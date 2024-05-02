import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Gestionnaire de Mot de Passe',
      home: HomePage(),
    );
  }
}

class MyAppState extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void authenticate() {
    _isAuthenticated = true;
    notifyListeners();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: Consumer<MyAppState>(
        builder: (context, appState, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Gestionnaire de Mot de Passe'),
            ),
            body: appState.isAuthenticated
                ? const PasswordsList()
                : const MasterPasswordForm(),
            floatingActionButton: FloatingActionButton(
              elevation: 0,
              backgroundColor: Colors.blueAccent,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddService(),
                ),
              ),
              tooltip: 'Ajouter un service',
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}

class MasterPasswordForm extends StatelessWidget {
  const MasterPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return (Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Entrez votre mot de passe principal',
            style: TextStyle(
                fontSize: 24, color: Color.fromARGB(255, 9, 102, 148)),
          ),
          const SizedBox(height: 20),
          const SizedBox(
            width: 400,
            child: TextField(
              style: TextStyle(
                fontSize: 16,
              ),
              obscureText: true,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              appState.authenticate();
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    ));
  }
}

class PasswordsList extends StatefulWidget {
  const PasswordsList({super.key});

  @override
  State<PasswordsList> createState() => _PasswordsListState();
}

class _PasswordsListState extends State<PasswordsList> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CardServices(),
                CardServices(),
                CardServices(),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CardServices extends StatelessWidget {
  const CardServices({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ServiceDetails(),
          ),
        ),
        child: const Card.outlined(
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 100, top: 24, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Date de création: ',
                  style: TextStyle(fontSize: 10),
                ),
                SizedBox(height: 16),
                Text(
                  'Identifiant:',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  'Mot de passe:',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddService extends StatelessWidget {
  const AddService({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 400,
              child: TextField(
                onChanged: (value) => print(value),
                decoration: const InputDecoration(
                  labelText: 'Identifiant',
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 400,
              child: TextField(
                onChanged: (value) => print(value),
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddService(),
                ),
              ),
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceDetails extends StatelessWidget {
  const ServiceDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Service'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Service:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Nom du Service',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 30),
            Text(
              'Identifiant:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Identifiant de l\'utilisateur',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 30),
            Text(
              'Mot de passe:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Mot de passe de l\'utilisateur',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
