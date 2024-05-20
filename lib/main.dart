import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'password_manager.dart';
import 'data.dart';
import 'file_writing.dart';

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
  static var data = Data();
  List<Map<String, dynamic>> dataList = data.data['data']!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: dataList.isNotEmpty
                    ? dataList
                        .map((item) => CardServices(
                              item['service'],
                              item['userInfo']['identifier'],
                              item['userInfo']['password'],
                            ))
                        .toList()
                    : [],
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
  final String service;
  final String identifier;
  final String password;

  const CardServices(this.service, this.identifier, this.password, {super.key});

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
        child: Card.outlined(
          child: Padding(
            padding: const EdgeInsets.only(
                left: 20, right: 100, top: 24, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Date de création: ',
                  style: TextStyle(fontSize: 10),
                ),
                const SizedBox(height: 16),
                Text(
                  identifier,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  password,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//"service": "Netflix",
// "id_identifiers": 1,
// "userInfo": {"identifier": "test@free.fr", "password": "Test1998"}
class AddService extends StatelessWidget {
  static var data = Data();
  static var fileActions = FileActions();

  const AddService({super.key});

  static String service = '';
  static int idIdentifiers = data.getCurrentId();
  static String identifier = '';
  static String password = '';

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
                onChanged: (value) => service = value,
                decoration: const InputDecoration(
                  labelText: 'Nom du Service',
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 400,
              child: TextField(
                onChanged: (value) => identifier = value,
                decoration: const InputDecoration(
                  labelText: 'Identifiant',
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 400,
              child: TextField(
                onChanged: (value) => password = value,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                ),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                final Map<String, dynamic> content = {
                  'service': service,
                  'id_identifiers': idIdentifiers,
                  'userInfo': {'identifier': identifier, 'password': password}
                };
                data.addData(content);
                fileActions.writeOnFile(data.data);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddService(),
                  ),
                );
              },
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
