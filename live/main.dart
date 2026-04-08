import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: WelcomeScreen()));

const kGold = Color(0xFFFFD700);
const String urlImagenPrincipal = 'https://i.ibb.co/v4BKMvsY/IMG-20260205-WA0021.jpg';

// --- PANTALLA 1: INICIO ---
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  List<Map<String, dynamic>> perfiles = [];
  @override void initState() { super.initState(); _cargar(); }

  _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('perfiles_rake');
    if (data != null) setState(() => perfiles = List<Map<String, dynamic>>.from(json.decode(data)));
  }

  _borrar(int i) async {
    perfiles.removeAt(i);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('perfiles_rake', json.encode(perfiles));
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(children: [
          const SizedBox(height: 40),
          // IMAGEN MÁS GRANDE
          Center(
            child: Container(
              width: 180, 
              height: 180, 
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                border: Border.all(color: kGold, width: 4), 
                image: const DecorationImage(image: NetworkImage(urlImagenPrincipal), fit: BoxFit.cover)
              )
            )
          ),
          const SizedBox(height: 15),
          const Text('RAKE', style: TextStyle(color: kGold, fontSize: 45, fontWeight: FontWeight.bold, letterSpacing: 3)),
          const Text('TRAINER', style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 10)),
          const Divider(color: Colors.white24, height: 50, indent: 40, endIndent: 40),
          Expanded(
            child: perfiles.isEmpty 
              ? const Center(child: Text("NO HAY PLANES GUARDADOS", style: TextStyle(color: Colors.white24)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  itemCount: perfiles.length,
                  itemBuilder: (context, i) => Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      title: Text(perfiles[i]['nombre'].toString().toUpperCase(), style: const TextStyle(color: kGold, fontWeight: FontWeight.bold)),
                      subtitle: Text("${perfiles[i]['kcal']} KCAL - ${perfiles[i]['objetivo']}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _borrar(i)),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FinalPlanScreen(p: perfiles[i]['p'], c: perfiles[i]['c'], g: perfiles[i]['g'], n: perfiles[i]['comidas'], totalKcal: perfiles[i]['kcal']))),
                    ),
                  ),
                ),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DataScreen())).then((_) => _cargar()), 
              style: ElevatedButton.styleFrom(backgroundColor: kGold, minimumSize: const Size(double.infinity, 65), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35))),
              child: const Text('NUEVO PLAN', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }
}

// --- PANTALLA 2 Y 3 SE MANTIENEN IGUAL (DATOS Y LIFESTYLE) ---
class DataScreen extends StatefulWidget {
  const DataScreen({super.key});
  @override State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  final nC = TextEditingController(); final pC = TextEditingController();
  final aC = TextEditingController(); final eC = TextEditingController();
  String sexo = 'Hombre';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: kGold), title: const Text("DATOS")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(children: [
          _i("NOMBRE", nC, Icons.person), _i("EDAD", eC, Icons.cake), _i("ALTURA (CM)", aC, Icons.height), _i("PESO (KG)", pC, Icons.fitness_center),
          RadioListTile(title: const Text("HOMBRE", style: TextStyle(color: Colors.white)), value: 'Hombre', groupValue: sexo, activeColor: kGold, onChanged: (v) => setState(() => sexo = v.toString())),
          RadioListTile(title: const Text("MUJER", style: TextStyle(color: Colors.white)), value: 'Mujer', groupValue: sexo, activeColor: kGold, onChanged: (v) => setState(() => sexo = v.toString())),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () { if(pC.text.isNotEmpty) Navigator.push(context, MaterialPageRoute(builder: (context) => LifestyleScreen(n: nC.text, p: double.parse(pC.text)))); }, style: ElevatedButton.styleFrom(backgroundColor: kGold, minimumSize: const Size(double.infinity, 60)), child: const Text("SIGUIENTE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))
        ]),
      ),
    );
  }
  Widget _i(String l, TextEditingController c, IconData i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: c, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: l, labelStyle: const TextStyle(color: Colors.grey, fontSize: 12), prefixIcon: Icon(i, color: kGold), enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white10)), focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: kGold)))));
}

class LifestyleScreen extends StatefulWidget {
  final String n; final double p;
  const LifestyleScreen({super.key, required this.n, required this.p});
  @override State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  String act = 'Pasiva'; String obj = 'Ganar músculo'; double dias = 4;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: kGold)),
      body: Padding(padding: const EdgeInsets.all(25), child: Column(children: [
        _drop("ACTIVIDAD", ['Sedentaria', 'Pasiva', 'Activa'], act, (v) => setState(() => act = v!)),
        const SizedBox(height: 30),
        Text("ENTRENO: ${dias.round()} DÍAS", style: const TextStyle(color: kGold, fontWeight: FontWeight.bold)),
        Slider(value: dias, min: 0, max: 7, divisions: 7, activeColor: kGold, onChanged: (v) => setState(() => dias = v)),
        _drop("OBJETIVO", ['Déficit Calórico', 'Mantenimiento', 'Ganar músculo'], obj, (v) => setState(() => obj = v!)),
        const Spacer(),
        ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ResultScreen(n: widget.n, p: widget.p, act: act, dias: dias.round(), obj: obj))), style: ElevatedButton.styleFrom(backgroundColor: kGold, minimumSize: const Size(double.infinity, 60)), child: const Text("CALCULAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))
      ])),
    );
  }
  Widget _drop(String t, List<String> items, String v, Function(String?) fn) => DropdownButtonFormField<String>(value: v, decoration: InputDecoration(labelText: t, labelStyle: const TextStyle(color: kGold)), dropdownColor: Colors.grey[900], style: const TextStyle(color: Colors.white), items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: fn);
}

// --- PANTALLA 4: RESULTADOS (CON KCAL GRANDES) ---
class ResultScreen extends StatefulWidget {
  final String n, act, obj; final double p; final int dias;
  const ResultScreen({super.key, required this.n, required this.p, required this.act, required this.dias, required this.obj});
  @override State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int com = 4;

  void _finalizar(double p, double c, double g, int kcal) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('perfiles_rake');
    List lista = data != null ? json.decode(data) : [];
    lista.add({'nombre': widget.n, 'kcal': kcal, 'p': p, 'c': c, 'g': g, 'comidas': com, 'objetivo': widget.obj});
    await prefs.setString('perfiles_rake', json.encode(lista));
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => FinalPlanScreen(p: p, c: c, g: g, n: com, totalKcal: kcal)));
  }

  @override
  Widget build(BuildContext context) {
    double fa = (widget.act == 'Sedentaria' ? 1.2 : widget.act == 'Pasiva' ? 1.4 : 1.6);
    double kcal = (widget.p * 22 * fa) + (widget.dias * 50);
    if (widget.obj == 'Déficit Calórico') kcal -= 400; if (widget.obj == 'Ganar músculo') kcal += 400;
    double p = widget.p * 2.2; double g = widget.p * 0.9; double c = (kcal - (p*4) - (g*9)) / 4;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: kGold)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(children: [
          Text(widget.n.toUpperCase(), style: const TextStyle(color: Colors.white, letterSpacing: 2)),
          // KCAL MUY GRANDES
          Text("${kcal.round()}", style: const TextStyle(color: kGold, fontSize: 100, fontWeight: FontWeight.bold, height: 1)),
          const Text("KCAL TOTALES", style: TextStyle(color: Colors.white38, fontSize: 16, letterSpacing: 4)),
          const SizedBox(height: 40),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_m("PROT", "${p.round()}g"), _m("GRAS", "${g.round()}g"), _m("CARB", "${c.round()}g")]),
          const SizedBox(height: 40),
          const Text("¿EN CUÁNTAS COMIDAS DIVIDIR?", style: TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 15),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [4, 5, 6].map((num) => Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: ChoiceChip(label: Text("$num"), selected: com == num, onSelected: (v) => setState(() => com = num), selectedColor: kGold))).toList()),
          const SizedBox(height: 40),
          ElevatedButton(onPressed: () => _finalizar(p, c, g, kcal.round()), style: ElevatedButton.styleFrom(backgroundColor: kGold, minimumSize: const Size(double.infinity, 70), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: const Text("VER DIVISIÓN DE MACROS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18))),
        ]),
      ),
    );
  }
  Widget _m(String l, String v) => Column(children: [Text(l, style: const TextStyle(color: kGold, fontSize: 12)), Text(v, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))]);
}

// --- PANTALLA 5: DISTRIBUCIÓN FINAL ---
class FinalPlanScreen extends StatelessWidget {
  final double p, c, g; final int n; final int totalKcal;
  const FinalPlanScreen({super.key, required this.p, required this.c, required this.g, required this.n, required this.totalKcal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("PLAN: $totalKcal KCAL", style: const TextStyle(color: kGold, fontSize: 16)), backgroundColor: Colors.black, iconTheme: const IconThemeData(color: kGold)),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: n,
        itemBuilder: (context, i) => Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 20),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("INGESTA ${i + 1}", style: const TextStyle(color: kGold, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _macroRow("PROTEÍNA", "${(p/n).toStringAsFixed(1)}g", Colors.redAccent),
              _macroRow("CARBOHIDRATO", "${(c/n).toStringAsFixed(1)}g", Colors.blueAccent),
              _macroRow("GRASA", "${(g/n).toStringAsFixed(1)}g", Colors.orangeAccent),
            ]),
          ),
        ),
      ),
    );
  }
  Widget _macroRow(String l, String v, Color col) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(color: Colors.white70, fontSize: 16)), Text(v, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 22))]));
}
