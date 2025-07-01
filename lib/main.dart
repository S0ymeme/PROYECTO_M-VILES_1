import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

void main() {
  runApp(const MiAppContador());
}

class MiAppContador extends StatefulWidget {
  const MiAppContador({super.key});

  @override
  State<MiAppContador> createState() => _MiAppContadorState();
}

class _MiAppContadorState extends State<MiAppContador> {
  bool _isDarkMode = false;
  double _fontSize = 16.0;
  Color _primaryColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _fontSize = prefs.getDouble('fontSize') ?? 16.0;
      int colorValue = prefs.getInt('primaryColor') ?? Colors.blue.value;
      _primaryColor = Color(colorValue);
    });
  }

  _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setInt('primaryColor', _primaryColor.value);
  }

  void updateTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
    _savePreferences();
  }

  void updateFontSize(double size) {
    setState(() {
      _fontSize = size;
    });
    _savePreferences();
  }

  void updatePrimaryColor(Color color) {
    setState(() {
      _primaryColor = color;
    });
    _savePreferences();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PRUEBA CONTADOR',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
        textTheme: Theme.of(context).textTheme.apply(
          fontSizeFactor: _fontSize / 16.0,
        ),
      ),
      home: mScreen(
        title: 'CONTADOR PRUEBA',
        onThemeChanged: updateTheme,
        onFontSizeChanged: updateFontSize,
        onColorChanged: updatePrimaryColor,
        isDarkMode: _isDarkMode,
        fontSize: _fontSize,
        primaryColor: _primaryColor,
      ),
    );
  }
}

class mScreen extends StatefulWidget {
  const mScreen({
    super.key,
    required this.title,
    required this.onThemeChanged,
    required this.onFontSizeChanged,
    required this.onColorChanged,
    required this.isDarkMode,
    required this.fontSize,
    required this.primaryColor,
  });

  final String title;
  final Function(bool) onThemeChanged;
  final Function(double) onFontSizeChanged;
  final Function(Color) onColorChanged;
  final bool isDarkMode;
  final double fontSize;
  final Color primaryColor;

  @override
  State<mScreen> createState() => _mScreenState();
}

class _mScreenState extends State<mScreen> {
  int _c = 0;
  int _i = 0;
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCounterValue();
  }

  _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? '';
      _userEmail = prefs.getString('userEmail') ?? '';
    });
  }

  _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userName);
    await prefs.setString('userEmail', _userEmail);
  }

  _loadCounterValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _c = prefs.getInt('counterValue') ?? 0;
    });
  }

  _saveCounterValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counterValue', _c);
  }

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
      _saveCounterValue();
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
      _saveCounterValue();
    } else {
      _showSnackBar('No se permiten números negativos');
    }
  }

  void _resetContador() {
    setState(() {
      _c = 0;
    });
    _saveCounterValue();
    _showSnackBar('Contador reiniciado');
  }

  void _onItemTapped(int index) {
    setState(() {
      _i = index;
    });
  }

  void _showUserDataDialog() {
    TextEditingController nameController = TextEditingController(text: _userName);
    TextEditingController emailController = TextEditingController(text: _userEmail);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Datos de Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _userName = nameController.text;
                  _userEmail = emailController.text;
                });
                _saveUserData();
                Navigator.of(context).pop();
                _showSnackBar('Datos guardados correctamente');
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _paginas = <Widget>[
      PaginaContador(contador: _c, userName: _userName),
      PaginaLista(),
      PaginaCard(userName: _userName, userEmail: _userEmail),
      PaginaGrid(),
      PaginaConfiguracion(
        onThemeChanged: widget.onThemeChanged,
        onFontSizeChanged: widget.onFontSizeChanged,
        onColorChanged: widget.onColorChanged,
        isDarkMode: widget.isDarkMode,
        fontSize: widget.fontSize,
        primaryColor: widget.primaryColor,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _showUserDataDialog,
            tooltip: 'Datos de Usuario',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: widget.primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menú',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_userName.isNotEmpty)
                    Text(
                      'Hola, $_userName',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                ],
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
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              selected: _i == 4,
              onTap: () {
                _onItemTapped(4);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _paginas[_i]),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _userName.isNotEmpty ? 'Desarrollado por $_userName' : 'Desarrollado por Usuario',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[400] 
                    : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
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
                  backgroundColor: _c == 0 ? Colors.grey : widget.primaryColor,
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _resetContador,
                  tooltip: 'Reiniciar',
                  backgroundColor: widget.primaryColor,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Config',
          ),
        ],
        currentIndex: _i,
        selectedItemColor: widget.primaryColor,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class PaginaContador extends StatelessWidget {
  final int contador;
  final String userName;

  const PaginaContador({super.key, required this.contador, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            userName.isNotEmpty ? userName : 'Erick',
            style: TextStyle(
              fontSize: 48, 
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white 
                  : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$contador',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : Colors.black,
                ),
          ),
        ],
      ),
    );
  }
}

class PaginaLista extends StatefulWidget {
  const PaginaLista({super.key});

  @override
  State<PaginaLista> createState() => _PaginaListaState();
}

class _PaginaListaState extends State<PaginaLista> {
  List<dynamic> items = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadJsonData();
  }

  Future<void> _loadJsonData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/elementos.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      
      setState(() {
        items = jsonData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error al cargar los datos: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              error!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  error = null;
                });
                _loadJsonData();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No hay elementos disponibles',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJsonData,
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                item['nombre'] ?? 'Sin nombre',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(item['descripcion'] ?? 'Sin descripción'),
              trailing: item['icono'] != null 
                  ? Icon(
                      _getIconData(item['icono']),
                      color: Theme.of(context).primaryColor,
                    )
                  : const Icon(Icons.label_outline),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'star':
        return Icons.star;
      case 'favorite':
        return Icons.favorite;
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'school':
        return Icons.school;
      case 'shopping':
        return Icons.shopping_cart;
      default:
        return Icons.label;
    }
  }
}

class PaginaCard extends StatelessWidget {
  final String userName;
  final String userEmail;

  const PaginaCard({super.key, required this.userName, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 320,
          height: 250,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 60, color: Colors.blue),
                const SizedBox(height: 16),
                Text(
                  userName.isNotEmpty ? userName : 'Erick Ricardo',
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userEmail.isNotEmpty ? userEmail : 'Desarrollador de software',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                if (userName.isNotEmpty && userEmail.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Datos guardados',
                      style: TextStyle(
                        color: Colors.green, 
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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

class PaginaConfiguracion extends StatelessWidget {
  final Function(bool) onThemeChanged;
  final Function(double) onFontSizeChanged;
  final Function(Color) onColorChanged;
  final bool isDarkMode;
  final double fontSize;
  final Color primaryColor;

  const PaginaConfiguracion({
    super.key,
    required this.onThemeChanged,
    required this.onFontSizeChanged,
    required this.onColorChanged,
    required this.isDarkMode,
    required this.fontSize,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> availableColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tema',
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Modo oscuro'),
                  subtitle: const Text('Cambiar entre tema claro y oscuro'),
                  value: isDarkMode,
                  onChanged: onThemeChanged,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tamaño de fuente',
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Tamaño actual: ${fontSize.toInt()}px',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[300] 
                        : Colors.grey[700],
                  ),
                ),
                Slider(
                  value: fontSize,
                  min: 12.0,
                  max: 24.0,
                  divisions: 6,
                  label: fontSize.toInt().toString(),
                  onChanged: onFontSizeChanged,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Color principal',
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: availableColors.map((color) {
                    return GestureDetector(
                      onTap: () => onColorChanged(color),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(25),
                          border: primaryColor == color
                              ? Border.all(
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.white 
                                      : Colors.black54, 
                                  width: 3
                                )
                              : null,
                        ),
                        child: primaryColor == color
                            ? Icon(
                                Icons.check, 
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.white 
                                    : Colors.white
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
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
