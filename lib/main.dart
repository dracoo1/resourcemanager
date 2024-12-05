import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'imageinteraction.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/Save.json');
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _currentTitle = "Home";
  String _currentText = "Home Page";
  int _currentID = -1;

  double _scaleFactor = 1.0;
  double _baseScaleFactor = 1.0;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: _appBar(),
        drawer: _sideBar(),
        body: _body(_currentText),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Row(
        children: [
          if (_currentID == -1)
            Text("Home")
          else
            Expanded(
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: "Title"),
              ),
            ),
          if (_currentID >= 0)
            IconButton(
                onPressed: () {
                  pickImage(_currentID);
                },
                icon: Icon(Icons.image)),
          if (_currentID >= 0)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                _currentTitle = _titleController.text;
                _currentText = _contentController.text;
                _saveFile(_currentID, _currentTitle, _currentText);
              },
            ),
        ],
      ),
    );
  }

  Widget _body(String text) {
    _contentController.text = text;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Stack(
            children: [
              if (_currentID == -1)
                const Text("Hold a file to delete")
              else
                ...Stored[_currentID]["Image"].map<Widget>((imagePath) {
                  return Image.file(
                    File(imagePath), // Load image from local file path
                  );
                }).toList(),
              if (_currentID >= 0)
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  autofocus: true,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _sideBar() {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(20.9),
        children: [
          IconButton(
            onPressed: () {
              _createFile();
              setState(() {});
            },
            icon: const Icon(Icons.create),
          ),
          for (var file in Stored)
            ListTile(
              title: ElevatedButton(
                onPressed: () {
                  _scaffoldKey.currentState?.closeDrawer();
                  _openFile(
                      file["ID"], file["Title"] ?? "Untitled", file["Text"]);
                },
                onLongPress: () {
                  DeleteFile(file["ID"]);
                },
                child: Text(file["Title"] ??
                    "Untitled"), // Fallback to "Untitled" if Title is null
              ),
            )
        ],
      ),
    );
  }

  void _createFile() {
    int newId = Stored.isNotEmpty ? Stored.last["ID"] + 1 : 0;
    Stored.add({"Title": "New File", "Text": "", "Image": [], "ID": newId});
    _saveData();
  }

  void DeleteFile(int ToDelete) {
    if (_currentID == ToDelete) {
      print(_currentID.toString() + " : " + ToDelete.toString());
      _currentText = "";
      _currentTitle = "Home";
      _currentID = -1;
      _titleController.text = "Home";
      _contentController.text = "Home Page";
    }

    Stored.removeWhere((file) => file["ID"] == ToDelete);
    _saveData();
    setState(() {});
  }

  void _openFile(int id, String title, String text) {
    setState(() {
      _currentID = id;
      _currentTitle = title;
      _currentText = text;
      _titleController.text = title;
      _contentController.text = text;
    });
  }

  void _saveFile(int id, String newTitle, String newText) {
    final file = Stored.firstWhere((file) => file["ID"] == id);
    if (file != null) {
      setState(() {
        file["Title"] = newTitle;
        file["Text"] = newText;
      });
      _saveData();
    }
  }

  Future<void> _loadData() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonData = jsonDecode(contents);
        setState(() {
          Stored = jsonData.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      print("Error loading stored data: $e");
    }
  }

  Future<void> _saveData() async {
    try {
      final file = await _localFile;
      await file.writeAsString(jsonEncode(Stored));
    } catch (e) {
      print("Error saving stored data: $e");
    }
  }

  Future pickImage(int id) async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final file = Stored.firstWhere((file) => file["ID"] == id);

      setState(() {
        file["Image"]
            .add(pickedImage.path); // Add only the path of the picked image
      });

      print(file); // Debug print to verify the image path addition
      _saveData(); // Save the updated data to persist the change
    }
  }
}

// The list of stored files
List<Map<String, dynamic>> Stored = [];
