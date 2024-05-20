import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'password_manager.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Gestionnaire de Mot de Passe',
      home: AppContainer(),
    );
  }
}

class MyAppState extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isFirstLaunch = true;
  final PasswordManager _passwordManager = PasswordManager();

  bool get isAuthenticated => _isAuthenticated;
  bool get isFirstLaunch => _isFirstLaunch;

  MyAppState() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isFirstLaunch = !await _passwordManager.masterPasswordExists();
    notifyListeners();
  }

  Future<void> authenticate(String password) async {
    _isAuthenticated = await _passwordManager.verifyMasterPassword(password);
    notifyListeners();
  }

  Future<void> setMasterPassword(String password) async {
    await _passwordManager.setMasterPassword(password);
    _isFirstLaunch = false;
    _isAuthenticated = true;
    notifyListeners();
  }
}

class AppContainer extends StatefulWidget {
  const AppContainer({super.key});

  @override
  State<AppContainer> createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: Consumer<MyAppState>(
        builder: (context, appState, _) {
          if (appState.isFirstLaunch) {
            return const CreateMasterPasswordForm();
          } else {
            return appState.isAuthenticated
                ? const PasswordsList()
                : const MasterPasswordForm();
          }
        },
      ),
    );
  }
}

class MasterPasswordForm extends StatefulWidget {
  const MasterPasswordForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MasterPasswordFormState createState() => _MasterPasswordFormState();
}

class _MasterPasswordFormState extends State<MasterPasswordForm> {
  final TextEditingController _controller = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      body: Center(
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
            SizedBox(
              width: 400,
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 16),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_controller.text.isEmpty) {
                  setState(() {
                    _errorMessage = 'Le mot de passe ne peut pas être vide';
                  });
                } else {
                  await appState.authenticate(_controller.text);
                  if (!appState.isAuthenticated) {
                    setState(() {
                      _errorMessage = 'Mot de passe incorrect';
                    });
                  }
                }
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateMasterPasswordForm extends StatefulWidget {
  const CreateMasterPasswordForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateMasterPasswordFormState createState() =>
      _CreateMasterPasswordFormState();
}

class _CreateMasterPasswordFormState extends State<CreateMasterPasswordForm> {
  final TextEditingController _controller = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Créez votre mot de passe principal',
              style: TextStyle(
                  fontSize: 24, color: Color.fromARGB(255, 9, 102, 148)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 400,
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 16),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_controller.text.isEmpty) {
                  setState(() {
                    _errorMessage = 'Le mot de passe ne peut pas être vide';
                  });
                } else {
                  await appState.setMasterPassword(_controller.text);
                }
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionnaire de Mot de Passe'),
      ),
      body: const Center(
        child: PasswordsList(),
      ),
    );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
      ),
      body: const Center(
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
      ),
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
                  labelText: 'Nom du Service',
                ),
              ),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 50),
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
      body: Center(
        child: Table(children: const [
          TableRow(children: [
            TableCell(child: Text('Nom du Service')),
            TableCell(child: Text('Service')),
          ]),
        ]),
      ),
    );
  }
}
