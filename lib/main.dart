import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fp_weather_app/models/city.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ICM Weather App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedCityIdx = 0;
  final List<City> _cities = [
    City(name: '🇲🇽  Hermosillo', coordinates: '29.0948207,-110.9692202'),
    City(name: '🇬🇧  London', coordinates: '51.5073219,-0.1276474'),
    City(name: '🇧🇷  São Paulo', coordinates: '-23.5506507,-46.6333824'),
    City(name: '🇦🇺  Sydney', coordinates: '-33.8698439,151.2082848'),
    City(name: '🇯🇵  Tokyo', coordinates: '35.6840574,139.7744912'),
  ];

  changeCity(int? value) {
    if (value == null) {
      return;
    }
    setState(() {
      _selectedCityIdx = value;
    });
  }

  String _appBarTitle = 'Clima';
  final List<String> _titles = ['Clima', 'Ciudades', 'Acerca de...'];
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _appBarTitle = _titles[index];
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/cover.jpg"),
                      fit: BoxFit.cover)),
              child: Text(
                'ICM Weather App',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.thermostat),
              title: const Text('Clima'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.place_outlined),
              title: const Text('Ciudades'),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outlined),
              title: const Text('Acerca de...'),
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(_appBarTitle),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          HomePage(city: _cities[_selectedCityIdx]),
          SettingsPage(
              cities: _cities,
              selectedCityIdx: _selectedCityIdx,
              onChanged: changeCity),
          const AboutPage(),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final City city;
  const HomePage({Key? key, required this.city}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  City get city => widget.city;

  final List<String> _icono = [
    /*== Day Icons ==*/
    //1 Clear sky
    'clear_sky.png',
    //2 Lightly cloudy
    'lightly_cloudy.png',
    //3 Partly cloudy
    'partly_cloudy.png',
    //4 Cloudy
    'cloudy.png',
    //5 Rain
    'rain.png',
    //6 Cloudy with heavy rain
    'heavy_rain.png',
    //7 Snow
    'snowflake.png',
    //8 Rain shower
    'rain_shower.png',
    //9, Snow shower
    'snow.png',
    //10 Sleet shower
    'sleet.png',
    //11 Fog
    'fog.png',
    //12 Dense Fog
    'dense_fog.png',
    //13 Freezing rain / Slipperness
    'sleet.png',
    //14 Thunderstorms
    'thunderstorms.png',
    //15 Drizzle
    'drizzle.png',
    //16 Sandstorms
    'sandstorms.png',

    /*== Night Icons ==*/
    //101 Clear sky
    'clear_night.png',
    //102 Lightly cloudy
    'lightly_cloudy_n.png',
    //103 Partly cloudy
    'partly_cloudy_n.png',
    //104 Cloudy
    'cloudy.png',
    //105 Rain
    'rain.png',
    //106 Cloudy with heavy rain
    'heavy_rain.png',
    //107 Snow
    'snowflake.png',
    //108 Rain shower
    'rain_shower.png',
    //109, Snow shower
    'snow.png',
    //110 Sleet shower
    'sleet.png',
    //111 Fog
    'fog.png',
    //112 Dense Fog
    'dense_fog.png',
    //113 Freezing rain / Slipperness
    'sleet.png',
    //114 Thunderstorms
    'thunderstorms.png',
    //115 Drizzle
    'drizzle.png',
    //116 Sandstorms
    'sandstorms.png',

    //Unknown - idx 32
    'unknown.png',
  ];

  // Starting values
  bool _isButtonDisabled = false;
  int _idx = 32;
  var _ultimaActualizacion = "N/A";
  String _temperatura = "?? °C";
  //String _unit = 'C';

  void _actualiza() async {
    String username = 'unison_z_carlos';
    String password = 'M8L55zyYf8';

    var token = await fetchToken(username, password);
    Map<String, dynamic> data = await fetchJSON(token);
    print(data); // Print the JSON in console

    setState(() {
      try {
        _ultimaActualizacion =
            data['data'][0]['coordinates'][0]['dates'][0]['date'];
        _temperatura =
            data['data'][0]['coordinates'][0]['dates'][0]['value'].toString();
        _temperatura = "$_temperatura °C";
        _idx = data['data'][1]['coordinates'][0]['dates'][0]['value'];
        if (_idx > 100) {
          _idx = _idx -
              85; // =100-15 diff between day and night Meteomatics' indexes
        }
      } catch (e) {
        print(e);
      }
    });

    _isButtonDisabled = true; // Disable button...
    Timer(const Duration(seconds: 5), () {
      setState(() {
        _isButtonDisabled = false; // ...and re-enable it after 5 seconds
      });
    });
  }

  Future<String> fetchToken(String username, String password) async {
    final String auth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final Uri apiUrl = Uri.parse('https://login.meteomatics.com/api/v1/token');

    try {
      final http.Response response = await http.get(
        apiUrl,
        headers: {'Authorization': auth},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String token = data['access_token'];
        return token;
      } else {
        print('Error: ${response.statusCode}');
        print('Something went wrong');
        throw Exception(
            'Falla al obtener el token'); // or throw an exception if you prefer
      }
    } catch (error) {
      print('Exception: $error');
      print('Something went wrong');
      throw Exception(
          'Falla al obtener el token'); // or throw an exception if you prefer
    }
  }

  Future<Map<String, dynamic>> fetchJSON(String token) async {
    var nowDT = DateTime.now();
    // Date format: YYYY-MM-DD; pad month and day, hour and minute, to always be 2 digits
    String date =
        '${nowDT.year}-${nowDT.month.toString().padLeft(2, '0')}-${nowDT.day.toString().padLeft(2, '0')}';
    String time =
        '${nowDT.hour.toString().padLeft(2, '0')}:${nowDT.minute.toString().padLeft(2, '0')}';

    String apiURL =
        //'https://api.meteomatics.com/2023-11-29T11:08:00.000-07:00/t_2m:C,weather_symbol_1h:idx/29.0948207,-110.9692202/json?access_token=$token';
        'https://api.meteomatics.com/${date}T$time:30.000-00:00/t_2m:C,weather_symbol_1h:idx/${city.coordinates}/json?access_token=$token';
    print(apiURL);
    final response = await http.get(Uri.parse(apiURL));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load JSON data');
    }
  }

  Image imageFromBase64String(String base64String) {
    return Image.memory(base64Decode(base64String));
  }

  Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  String base64String(Uint8List data) {
    return base64Encode(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display the blank spaces
            Text(
              _temperatura,
              style: const TextStyle(
                  fontSize: 30,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              city.name,
              style: const TextStyle(fontSize: 20, letterSpacing: 1.5),
              textAlign: TextAlign.center,
            ),
            Text(
              "Actualizado a:\n$_ultimaActualizacion",
              style: const TextStyle(fontSize: 18, letterSpacing: 1.5),
              textAlign: TextAlign.center,
            ),
            /* Text( // For icon index debugging
              "Ícono índice: $_idx",
              style: const TextStyle(fontSize: 20, letterSpacing: 1.5),
            ), */
            // Display the first image
            SizedBox(
              // Set the height and width of the Container
              height: 300,
              width: 300,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 50,
                    left: 75, //give the values according to your requirement
                    child: SizedBox(
                      width: 150,
                      //child: imageFromBase64String(_icono[_idx]),
                      child: Image.asset('assets/images/${_icono[_idx]}'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isButtonDisabled ? null : _actualiza,
              child: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  final List<City> cities;
  final int selectedCityIdx;
  final void Function(int?) onChanged;
  const SettingsPage(
      {Key? key,
      required this.cities,
      required this.selectedCityIdx,
      required this.onChanged})
      : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<City> get cities => widget.cities;
  int get selectedCityIdx => widget.selectedCityIdx;
  void Function(int?) get onChanged => widget.onChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Elegir ciudad...",
              style: TextStyle(fontSize: 24, letterSpacing: 1.5),
            ),
            Expanded( //Magic ✨
              child: ListView.builder( // Builder to create as much RadioButton's as necessary
                shrinkWrap: true,
                itemCount: cities.length,
                itemBuilder: (BuildContext context, int index) {
                  return RadioListTile<int>(
                    title: Text(cities[index].name),
                      value: index,
                      groupValue: selectedCityIdx,
                      onChanged: onChanged);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display the blank spaces
            const Text(
              "ICM Weather App",
              style: TextStyle(fontSize: 24, letterSpacing: 1.5),
              textAlign: TextAlign.center,
            ),
            const Text(
              "Alumno:\nZatarain Palma Carlos Alberto\n",
              style: TextStyle(fontSize: 18, letterSpacing: 1.0),
              textAlign: TextAlign.center,
            ),
            Image.asset('assets/images/author.png',
                height: 256, width: 256), // Image
            const Text(
              "\n*==== CRÉDITOS ====*\n> Conocimientos del curso y código base:\nFederico Miguel Cirett Galán\n> Ayuda en State-Drilling y RadioButton's:\nSaúl Alberto Ramos Laborín\n> Proveedor de servicio y API del clima:\nMeteomatics (https://www.meteomatics.com/)",
              style: TextStyle(fontSize: 18, letterSpacing: 1.0),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
