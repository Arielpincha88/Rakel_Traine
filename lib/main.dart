import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RakeTrainerApp());
}

const kGold = Color(0xFFFFD700);
const String urlLogo = 'https://i.ibb.co/v4BKMvsY/IMG-20260205-WA0021.jpg';

class RakeTrainerApp extends StatelessWidget {
  const RakeTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rake Trainer',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: kGold,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: kGold)));
        }
        if (snapshot.hasData) {
          return const DashboardScreen();
        }
        return const AuthScreen();
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _nombre = TextEditingController();
  bool isLogin = true;
  bool loading = false;
  String error = '';

  Future<void> _submit() async {
    setState(() { loading = true; error = ''; });
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );
      } else {
        UserCredential creds = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );
        await FirebaseFirestore.instance.collection('usuarios').doc(creds.user!.uid).set({
          'nombre': _nombre.text.trim(),
          'email': _email.text.trim(),
          'rol': 'alumno',
          'fechaCreacion': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message ?? 'Error de autenticación');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kGold, width: 3),
                    image: const DecorationImage(image: NetworkImage(urlLogo), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 15),
                const Text('RAKE TRAINER', style: TextStyle(color: kGold, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 3)),
                const SizedBox(height: 25),
                if (!isLogin) _campo('Nombre Completo', _nombre, Icons.person),
                _campo('Correo Electrónico', _email, Icons.email),
                _campo('Contraseña', _password, Icons.lock, obscure: true),
                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(error, style: const TextStyle(color: Colors.redAccent, fontSize: 13), textAlign: TextAlign.center),
                  ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGold,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(isLogin ? 'INICIAR SESIÓN' : 'REGISTRARSE', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin ? '¿No tenés cuenta? Registrate' : '¿Ya tenés cuenta? Ingresá',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(String label, TextEditingController controller, IconData icon, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: kGold),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: kGold)),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('RAKE TRAINER', style: TextStyle(color: kGold, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .collection('planes')
            .orderBy('fechaCreacion', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kGold));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text("NO HAY PLANES GUARDADOS EN TU CUENTA", style: TextStyle(color: Colors.white24)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  title: Text(data['nombre'].toString().toUpperCase(), style: const TextStyle(color: kGold, fontWeight: FontWeight.bold)),
                  subtitle: Text("${data['kcal']} KCAL - ${data['objetivo']}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => docs[i].reference.delete(),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FinalPlanScreen(
                        p: (data['p'] as num).toDouble(),
                        c: (data['c'] as num).toDouble(),
                        g: (data['g'] as num).toDouble(),
                        n: data['comidas'] as int,
                        totalKcal: data['kcal'] as int,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kGold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('NUEVO PLAN', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const DataScreen())),
      ),
    );
  }
}

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});
  @override State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  final nC = TextEditingController();
  final pC = TextEditingController();
  final aC = TextEditingController();
  final eC = TextEditingController();
  String sexo = 'Hombre';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: kGold), title: const Text("DATOS BIOMÉTRICOS")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(children: [
          _in("NOMBRE", nC, Icons.person),
          _in("EDAD", eC, Icons.cake),
          _in("ALTURA (CM)", aC, Icons.height),
          _in("PESO (KG)", pC, Icons.fitness_center),
          RadioListTile(title: const Text("HOMBRE", style: TextStyle(color: Colors.white)), value: 'Hombre', groupValue: sexo, activeColor: kGold, onChanged: (v) => setState(() => sexo = v.toString())),
          RadioListTile(title: const Text("MUJER", style: TextStyle(color: Colors.white)), value: 'Mujer', groupValue: sexo, activeColor: kGold, onChanged: (v) => setState(() => sexo = v.toString())),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (pC.text.isNotEmpty && nC.text.isNotEmpty) {
                Navigator.push(context, MaterialPageRoute(builder: (c) => LifestyleScreen(n: nC.text, p: double.parse(pC.text))));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: kGold, minimumSize: const Size(double.infinity, 55)),
            child: const Text("SIGUIENTE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ]),
      ),
    );
  }

  Widget _in(String l, TextEditingController c, IconData i) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(controller: c, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: l, labelStyle: const TextStyle(color: Colors.grey, fontSize: 12), prefixIcon: Icon(i, color: kGold), enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white10)), focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: kGold)))),
  );
}

class LifestyleScreen extends StatefulWidget {
  final String n; final double p;
  const LifestyleScreen({super.key, required this.n, required this.p});
  @override State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  String act = 'Pasiva';
  String obj = 'Ganar músculo';
  double dias = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: kGold)),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(children: [
          _drop("ACTIVIDAD", ['Sedentaria', 'Pasiva', 'Activa'], act, (v) => setState(() => act = v!)),
          const SizedBox(height: 30),
          Text("ENTRENO: ${dias.round()} DÍAS", style: const TextStyle(color: kGold, fontWeight: FontWeight.bold)),
          Slider(value: dias, min: 0, max: 7, divisions: 7, activeColor: kGold, onChanged: (v) => setState(() => dias = v)),
          _drop("OBJETIVO", ['Déficit Calórico', 'Mantenimiento', 'Ganar músculo'], obj, (v) => setState(() => obj = v!)),
          const Spacer(),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ResultScreen(n: widget.n, p: widget.p, act: act, dias: dias.round(), obj: obj))),
            style: ElevatedButton.styleFrom(backgroundColor: kGold, minimumSize: const Size(double.infinity, 55)),
            child: const Text("CALCULAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ]),
      ),
    );
  }

  Widget _drop(String t, List<String> items, String v, Function(String?) fn) => DropdownButtonFormField<String>(
    value: v,
    decoration: InputDecoration(labelText: t, labelStyle: const TextStyle(color: kGold)),
    dropdownColor: Colors.grey[900],
    style: const TextStyle(color: Colors.white),
    items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
    onChanged: fn,
  );
}

class ResultScreen extends StatefulWidget {
  final String n, act, obj; final double p; final int dias;
  const ResultScreen({super.key, required this.n, required this.p, required this.act, required this.dias, required this.obj});
  @override State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int com = 4;
  bool guardando = false;

  @override
  Widget build(BuildContext context) {
    double fa = (widget.act == 'Sedentaria' ? 1.2 : widget.act == 'Pasiva' ? 1.4 : 1.6);
    double kcalTotal = (widget.p * 22 * fa) + (widget.dias * 50);
    if (widget.obj == 'Déficit Calórico') kcalTotal -= 400;
    if (widget.obj == 'Ganar músculo') kcalTotal += 400;

    double prot = widget.p * 2.2;
    double gras = widget.p * 0.9;
    double carb = (kcalTotal - (prot * 4) - (gras * 9)) / 4;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: kGold)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(children: [
          Text(widget.n.toUpperCase(), style: const TextStyle(color: Colors.white, letterSpacing: 2)),
          Text("${kcalTotal.round()}", style: const TextStyle(color: kGold, fontSize: 90, fontWeight: FontWeight.bold)),
          const Text("KCAL TOTALES", style: TextStyle(color: Colors.white38, fontSize: 14, letterSpacing: 4)),
          const SizedBox(height: 30),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _m("PROT", "${prot.round()}g"),
            _m("GRAS", "${gras.round()}g"),
            _m("CARB", "${carb.round()}g")
          ]),
          const SizedBox(height: 35),
          const Text("¿EN CUÁNTAS COMIDAS DIVIDIR?", style: TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [4, 5, 6].map((num) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ChoiceChip(
                label: Text("$num"),
                selected: com == num,
                onSelected: (v) => setState(() => com = num),
                selectedColor: kGold,
              ),
            )).toList(),
          ),
          const SizedBox(height: 35),
          ElevatedButton(
            onPressed: guardando ? null : () async {
              setState(() => guardando = true);
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                await FirebaseFirestore.instance.collection('usuarios').doc(uid).collection('planes').add({
                  'nombre': widget.n,
                  'kcal': kcalTotal.round(),
                  'p': prot,
                  'c': carb,
                  'g': gras,
                  'comidas': com,
                  'objetivo': widget.obj,
                  'fechaCreacion': FieldValue.serverTimestamp(),
                });
              }
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => FinalPlanScreen(p: prot, c: carb, g: gras, n: com, totalKcal: kcalTotal.round())),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: kGold, minimumSize: const Size(double.infinity, 60)),
            child: guardando
                ? const CircularProgressIndicator(color: Colors.black)
                : const Text("VER DIVISIÓN DE MACROS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ]),
      ),
    );
  }

  Widget _m(String l, String v) => Column(children: [
    Text(l, style: const TextStyle(color: kGold, fontSize: 12)),
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold))
  ]);
}

class FinalPlanScreen extends StatelessWidget {
  final double p, c, g; final int n; final int totalKcal;
  const FinalPlanScreen({super.key, required this.p, required this.c, required this.g, required this.n, required this.totalKcal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PLAN: $totalKcal KCAL", style: const TextStyle(color: kGold, fontSize: 16)), backgroundColor: Colors.black, iconTheme: const IconThemeData(color: kGold)),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: n,
        itemBuilder: (context, i) => Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("INGESTA ${i + 1}", style: const TextStyle(color: kGold, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _macroRow("PROTEÍNA", "${(p / n).toStringAsFixed(1)}g", Colors.redAccent),
              _macroRow("CARBOHIDRATO", "${(c / n).toStringAsFixed(1)}g", Colors.blueAccent),
              _macroRow("GRASA", "${(g / n).toStringAsFixed(1)}g", Colors.orangeAccent),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _macroRow(String l, String v, Color col) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l, style: const TextStyle(color: Colors.white70, fontSize: 15)),
        Text(v, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 20)),
      ],
    ),
  );
}
