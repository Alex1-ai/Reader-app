import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:reader/dimensions.dart';
// void main() {
//   runApp(const MyApp());
  
  
// }
void main() {
  runApp( MyApp(),
  );
}



class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

enum TtsState { playing, stopped, paused }

class _MyAppState extends State<MyApp> {
  late FlutterTts flutterTts;
  dynamic languages;
  late String language;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;

  late String _newVoiceText;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    _getLanguages();

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setErrorHandler((message) {
      setState(() {
        print("error: $message");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setPauseHandler(() {
      print("Paused");
      ttsState = TtsState.paused;
    });
  }

  Future _getLanguages() async {
    languages = await flutterTts.getLanguages;
    print("Available Languages ${languages}");
    if (languages != null) {
      setState(() {
        return languages;
      });
    }
  }

  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        var result = await flutterTts.speak(_newVoiceText);
        if (result == 1) setState(() => ttsState = TtsState.playing);
      }
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    flutterTts.stop();
  }

  List<DropdownMenuItem<String>> getLangaugeDropDownMenuItems() {
    var items = <DropdownMenuItem<String>>[];
    for (String type in languages) {
      items.add(DropdownMenuItem(
        value: type,
        child: Text(type),
      ));
    }

    return items;
  }

  void changeLanguageDropDownItem(String? selectType) {
    setState(() {
      language = selectType!;
      flutterTts.setLanguage(language);
    });
  }

  void _onChange(String text) {
    setState(() {
      _newVoiceText = text;
    });
  }

  Widget build(BuildContext context) {
  Size  size = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        home: Scaffold(
            
            bottomNavigationBar: bottomBar(),
            appBar: AppBar(
            
              title: Text("Reader"),
              centerTitle: true,
              backgroundColor: Colors.indigo,
            ),
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Center(
                child: Column(children: [
                  SizedBox(height: size.height * 0.1),
                  _inputSection(),
                  languages != null ? _languageDropDownSection() : Text(""),
                  SizedBox(height: size.height * 0.1,),
                  _buildSliders()
                ]),
              ),
            )));
  }

  Widget _buildSliders() {
    return Column(
      children: [
        Text("Volume"),
        _volume(), 
        Text("Pictch"),
        _pitch(),
        Text('Speed'),
         _rate()],
    );
  }

  Widget _volume() {
    return Slider(
        value: volume,
        onChanged: (newVolume) {
          setState(() => volume = newVolume);
        },
        min: 0.0,
        max: 1.0,
        divisions: 10,
        label: "Volume: $volume");
  }

  Widget _pitch() {
    return Slider(
        value: pitch,
        onChanged: (newPitch) {},
        min: 0.5,
        max: 2.0,
        divisions: 15,
        label: "Pitch: $pitch",
        activeColor: Colors.red);
  }

  Widget _rate() {
    return Slider(
        value: rate,
        onChanged: (newRate) {
          setState(() => rate = newRate);
        },
        min: 0.0,
        max: 1.0,
        divisions: 10,
        label: "Rate: $rate",
        activeColor: Colors.indigo);
  }

  Widget _inputSection() => Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
        child: TextField(onChanged: (String value) {
          _onChange(value);

          
        },
        maxLines: 5,
        decoration: InputDecoration(
          hintText: "Enter your text here ...."
        ),
        
        ),
      );

  Widget _languageDropDownSection() => Container(
      padding: EdgeInsets.only(top: 50.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropdownButton(
            value: language,
            items: getLangaugeDropDownMenuItems(),
            onChanged: changeLanguageDropDownItem,
          )
        ],
      ));

  Column _buildButtonColumn(Color color, Color splashColor, IconData icon,
      String label, Function func) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [IconButton(onPressed: () => func, icon: Icon(icon))],
    );
  }

  bottomBar() => Container(
        margin: EdgeInsets.all(10.0),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              onPressed: _speak,
              child: Icon(Icons.play_arrow),
              backgroundColor: Colors.indigo,
            ),
            FloatingActionButton(
              onPressed: _stop,
              backgroundColor: Colors.red,
              child: Icon(Icons.stop),
            )
          ],
        ),
      );
}
