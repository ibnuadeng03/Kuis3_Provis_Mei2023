import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

class umkm {
  String nama;
  String jenis;
  umkm({required this.nama, required this.jenis});
}

class listUmkm {
  List<umkm> ListPop = <umkm>[];

  listUmkm(Map<String, dynamic> json) {
    // isi listPop disini
    var data = json["data"];
    for (var val in data) {
      var nama = val["nama"];
      var jenis = val["jenis"];
      ListPop.add(umkm(nama: nama, jenis: jenis));
    }
  }
  //map dari json ke atribut
  factory listUmkm.fromJson(Map<String, dynamic> json) {
    return listUmkm(json);
  }
}

// deklarasi cubit
class PopulasiCubit extends Cubit<List<umkm>> {
  PopulasiCubit() : super([]);

  // fetch data
  Future<void> fetchPopulasi() async {
    String url = "http://178.128.17.76:8000/daftar_umkm";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // jika server mengembalikan 200 OK (berhasil),
      // parse json
      final jenis = listUmkm.fromJson(jsonDecode(response.body));
      emit(jenis.ListPop);
    } else {
      // jika gagal (bukan  200 OK),
      // lempar exception
      throw Exception('Gagal load');
    }
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'coba http',
      home: BlocProvider(
        create: (_) => PopulasiCubit(),
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final PopulasiCubit _populasiCubit;

  @override
  void initState() {
    super.initState();
    _populasiCubit = context.read<PopulasiCubit>();
    _populasiCubit.fetchPopulasi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('My App'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '2101995: Muhammad Firdaus\n2101769: Ibnu Adeng Kurnia\nSaya berjanji tidak akan berbuat curang data atau membantu\norang lain berbuat curang',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyApp(),
                        ),
                      );
                    },
                    child: Text('Reload Daftar UMKM'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: BlocBuilder<PopulasiCubit, List<umkm>>(
                builder: (context, populasiList) {
                  if (populasiList.isNotEmpty) {
                    return ListView.builder(
                      itemCount: populasiList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          child: Container(
                            decoration: BoxDecoration(border: Border.all()),
                            padding: const EdgeInsets.all(14),
                            child: ListTile(
                                onTap: () {},
                                leading: Image.network(
                                    'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
                                trailing: const Icon(Icons.more_vert),
                                title: Text(populasiList[index].nama),
                                subtitle: Text(populasiList[index].jenis),
                                tileColor: Colors.white70),
                          ),
                        );
                      },
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
