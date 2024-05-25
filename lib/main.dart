import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'password_manager.dart';
import 'data.dart';

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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
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
              child:
                  const Text('Valider', style: TextStyle(color: Colors.white)),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              onPressed: () async {
                if (_controller.text.isEmpty) {
                  setState(() {
                    _errorMessage = 'Le mot de passe ne peut pas être vide';
                  });
                } else {
                  await appState.setMasterPassword(_controller.text);
                }
              },
              child: const Text('Créer', style: TextStyle(color: Colors.white)),
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
  final Data? data;

  const PasswordsList({this.data, super.key});

  @override
  State<PasswordsList> createState() => _PasswordsListState();
}

class _PasswordsListState extends State<PasswordsList> {
  late Future<Data> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture =
        widget.data != null ? Future.value(widget.data) : _initializeData();
  }

  Future<Data> _initializeData() async {
    var data = Data();
    await data.initialize();
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
      ),
      body: Center(
        child: FutureBuilder<Data>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final dataList = snapshot.data!.data['data'];
              return Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: dataList.isNotEmpty
                          ? dataList.map<Widget>((item) {
                              return CardServices(
                                item['service'],
                                item['userInfo']['identifier'],
                                item['userInfo']['password'],
                              );
                            }).toList()
                          : [],
                    ),
                  )
                ],
              );
            } else {
              return const Text('Pas de Services enregistrés');
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddService(dataFuture: Future.value(_dataFuture)),
            ),
          );

          if (result == true) {
            setState(() {
              _dataFuture = _initializeData();
            });
          }
        },
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
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Identifiant :',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  identifier,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Mot de passe :',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '*' * password.length,
                      style: const TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.blue),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: password));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.blue,
                            content: Text('Mot de passe copié'),
                          ),
                        );
                      },
                    ),
                  ],
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
  final Future<Data> dataFuture;

  const AddService({required this.dataFuture, super.key});

  static String service = '';
  static int idIdentifiers = 1;
  static String identifier = '';
  static String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service'),
      ),
      body: FutureBuilder<Data>(
        future: dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            idIdentifiers = data.getCurrentId();
            return Center(
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
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                    onPressed: () {
                      final Map<String, dynamic> content = {
                        'service': service,
                        'id_identifiers': idIdentifiers,
                        'userInfo': {
                          'identifier': identifier,
                          'password': password
                        }
                      };
                      data.addData(content);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PasswordsList(data: data),
                        ),
                      );
                    },
                    child: const Text('Valider',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          } else {
            return const Text('Une erreur est survenue');
          }
        },
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
