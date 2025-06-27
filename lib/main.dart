import 'package:flutter/material.dart';
import 'dart:convert';

void main() {
  runApp(const MiAppContador());
}

class MiAppContador extends StatelessWidget {
  const MiAppContador({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PRUEBA CONTADOR',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const mScreen(title: 'CONTADOR PRUEBA'),
    );
  }
}

class mScreen extends StatefulWidget {
  const mScreen({super.key, required this.title});

  final String title;

  @override
  State<mScreen> createState() => _mScreenState();
}

class _mScreenState extends State<mScreen> {
  int _c = 0;
  int _i = 0;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final snackBar = SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'Aceptar',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _sumContador() {
    if (_c < 20) {
      setState(() {
        _c++;
      });
      if (_c == 20) {
        _showSnackBar('Se alcanzó el valor máximo (20)');
      }
    } else {
      _showSnackBar('No se puede incrementar más (máximo 20)');
    }
  }

  void _resContador() {
    if (_c > 0) {
      setState(() {
        _c--;
      });
    } else {
      _showSnackBar('No se permiten números negativos');
    }
  }

  void _resetContador() {
    setState(() {
      _c = 0;
    });
    _showSnackBar('Contador reiniciado');
  }

  void _onItemTapped(int index) {
    setState(() {
      _i = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _paginas = <Widget>[
      PaginaContador(contador: _c),
      PaginaLista(),
      const PaginaCard(),
      PaginaGrid(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menú',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Contador'),
              selected: _i == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Lista'),
              selected: _i == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Card'),
              selected: _i == 2,
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_on),
              title: const Text('Grid'),
              selected: _i == 3,
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _paginas[_i],
      floatingActionButton: _i == 0
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: _sumContador,
                  tooltip: 'Incrementar',
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _resContador,
                  tooltip: 'Decrementar',
                  backgroundColor: _c == 0 ? Colors.grey : Colors.blue,
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _resetContador,
                  tooltip: 'Reiniciar',
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.refresh),
                ),
              ],
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Contador',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Lista',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Card',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_on),
            label: 'Grid',
          ),
        ],
        currentIndex: _i,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class PaginaContador extends StatelessWidget {
  final int contador;

  const PaginaContador({super.key, required this.contador});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Erick',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            '$contador',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class PaginaLista extends StatelessWidget {
  PaginaLista({super.key});

  final String jsonData = '''
    [
      {"nombre": "Elemento 1", "descripcion": "Descripción de elemento 1"},
      {"nombre": "Elemento 2", "descripcion": "Descripción de elemento 2"},
      {"nombre": "Elemento 3", "descripcion": "Descripción de elemento 3"}
    ]
  ''';

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = json.decode(jsonData);

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: const Icon(Icons.label),
          title: Text(item['nombre']),
          subtitle: Text(item['descripcion']),
        );
      },
    );
  }
}

class PaginaCard extends StatelessWidget {
  const PaginaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 320,
          height: 200,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.person, size: 60, color: Colors.blue),
                SizedBox(height: 16),
                Text(
                  'Erick Ricardo',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Desarrollador de software',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PaginaGrid extends StatelessWidget {
  PaginaGrid({super.key});

  final List<Map<String, String>> imagenes = [
    {
      'url': 'https://picsum.photos/id/237/200/300',
      'desc': 'Imagen 1'
    },
    {
      'url': 'https://picsum.photos/id/300/200/200',
      'desc': 'Imagen 2'
    },
    {
      'url': 'https://picsum.photos/id/1000/200/200',
      'desc': 'Imagen 3'
    },
    {
      'url': 'https://picsum.photos/id/1100/200/200',
      'desc': 'Imagen 4'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: imagenes.length,
      itemBuilder: (context, index) {
        final img = imagenes[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ImagenDetalle(
                  url: img['url']!,
                  descripcion: img['desc']!,
                ),
              ),
            );
          },
          child: Hero(
            tag: img['url']!,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(img['url']!, fit: BoxFit.cover),
            ),
          ),
        );
      },
    );
  }
}

class ImagenDetalle extends StatelessWidget {
  final String url;
  final String descripcion;

  const ImagenDetalle({super.key, required this.url, required this.descripcion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Imagen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: url,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(url, width: 300, height: 300, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              descripcion,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
