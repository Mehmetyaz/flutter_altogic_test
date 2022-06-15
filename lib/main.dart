import 'package:altogic_dart/altogic_dart.dart';
import 'package:flutter/material.dart';

void main() async {
  createClientTest();

  await setUpEmailUser();

  runApp(const MyApp());
}

late AltogicClient client;

const envUrl = "https://c1-na.altogic.com/e:62a30491f3a9efcc5eb71193";
const clientKey = "abb823877b764da9a2a21c7318cd9d23";

void createClientTest() {
  client = createClient(envUrl, clientKey);
}

const email = 'mehmedyaz@gmail.com';
const phone = '+905530635063';
const pwd = 'mehmetyaz';

Future<APIResponse> clearUser([AltogicClient? clientInstance]) {
  return (clientInstance ?? client)
      .endpoint
      .delete('/clear_user', body: {'email': email, 'phone': phone}).asMap();
}

Future<APIResponse> validateMail([AltogicClient? clientInstance]) {
  return (clientInstance ?? client)
      .endpoint
      .post('/validate_mail', body: {'email': email, 'phone': phone}).asMap();
}

Future<void> setUpEmailUser(
    [bool signIn = true, AltogicClient? clientInstance]) async {
  await clearUser(clientInstance);
  await signUpWithEmailCorrect(clientInstance);
  await validateMail(clientInstance);
  if (signIn) await signInWithEmailCorrect(clientInstance);
}

Future<UserSessionResult> signUpWithEmailCorrect(
    [AltogicClient? clientInstance]) {
  return (clientInstance ?? client).auth.signUpWithEmail(email, pwd);
}

Future<UserSessionResult> signInWithEmailCorrect(
    [AltogicClient? clientInstance]) {
  return (clientInstance ?? client).auth.signInWithEmail(email, pwd);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Car {
  Car({required this.id, required this.brand, required this.engineVolume});

  String brand, id;
  int engineVolume;
}

class _MyHomePageState extends State<MyHomePage> {
  String? id;

  void _get() async {
    getting = true;
    if (mounted) {
      setState(() {});
    }

    var res = await client.db.model('car').getRandom(1);

    print(res.errors);
    print(res.data);

    if (res.errors != null) {
      setState(() {
        error = res.errors;
        getting = false;
      });
      return;
    }

    Map? data;

    if (res.data?.isEmpty ?? false) {
      isEmpty = true;
      getting = false;
      setState(() {});
      return;
    } else {
      data = res.data?.first;
    }

    setState(() {
      isEmpty = data == null;
      getting = false;
      if (isEmpty) return;

      id = data!['_id'];

      car = Car(
          id: data['_id'],
          brand: data['brand'],
          engineVolume: data['engine_volume']);
    });
  }

  static final List<String> brands = [
    'Mercedes',
    'Peugeot',
    'Range Rover',
    'Tesla',
  ];

  static final List<int> volumes = [
    1500,
    2000,
    3000,
    4000,
  ];

  Future<void> _update() async {
    if (mounted) {
      setState(() {});
    }

    if (isEmpty) return _create();
    if (id == null) return;
    var res = await client.db.model('car').object(id).update({
      'engine_volume': (volumes..shuffle()).first,
      'brand': (brands..shuffle()).first,
      'type': 'test1'
    });

    if (res.errors != null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('An Error: ${res.errors}')));
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Car Updated: ${res.data}')));
    }
  }

  Future<void> _create() async {
    var res = await client.db.model('car').create({
      'engine_volume': (volumes..shuffle()).first,
      'brand': (brands..shuffle()).first,
      'type': 'test1'
    });

    if (res.errors != null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('An Error: ${res.errors}')));
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Car Created: ${res.data}')));
    }
    return;
  }

  Future<void> _delete() async {
    if (mounted) {
      setState(() {});
    }
    if (id == null) return;
    var res = await client.db.model('car').object(id).delete();

    if (res.errors != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An Error On Delete: ${res.errors}')));
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Cars Deleted: ${res.data}')));
    }
  }

  APIError? error;

  Car? car;

  bool isEmpty = true, getting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: _get, child: const Text('Read / Refresh')),
                ElevatedButton(onPressed: _update, child: const Text('Update')),
                ElevatedButton(onPressed: _delete, child: const Text('Delete'))
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Expanded(
                child: getting
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          if (isEmpty)
                            const Text(
                              'There Is No Car',
                            ),
                          if (!isEmpty && car != null)
                            Text(
                              'Car: : \n'
                              'Brand: ${car!.brand}\n'
                              'Volume: ${car!.engineVolume} cc\n',
                            ),
                          if (error != null)
                            Text(
                              'Error: $error',
                              style: Theme.of(context).textTheme.headline4,
                            ),
                        ],
                      ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _get,
        tooltip: 'Get',
        child: const Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
