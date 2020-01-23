import 'dart:async';

import 'package:abcradio/pages/contato.dart';
import 'package:abcradio/pages/home_page.dart';
import 'package:abcradio/pages/pedido_musica.dart';
import 'package:flutter/material.dart';
import 'package:abcradio/controllers/player.dart';
import 'package:audio_service/audio_service.dart';
import 'package:share/share.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static const String _title = 'ABC Radio Light';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Color(0xFF1B203C),
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _animateColor;
  Animation<double> _animateIcon;
  Curve _curve = Curves.easeOut;

  @override
  void initState() {
    super.initState();
    player.initPlaying();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animateColor = ColorTween(
      //begin: Color(0xFF1B203C),
       begin: Colors.grey,
      end: Color(0xFFF8665E),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: _curve,
      ),
    ));
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Player player = Player();
  PlaybackState state;

  bool buttonStateIsPlaying;
  Color mainColor = Color(0xFF1B203C);
  PageController _myPage = PageController(initialPage: 0);

  bool buttonChangeAllowed = true;
  Future buttonChange() async {
    if (!buttonChangeAllowed) {
      return Future; 
    }
    print("buttonChange() happening");
    buttonChangeAllowed = false;
    if (state?.basicState == BasicPlaybackState.playing) {
      _animationController.forward();
      await AudioService.pause();
    } else {
      _animationController.reverse();
      await AudioService.play();
    }
    Timer(Duration(milliseconds: 1000), () {
      print("Yeah, this line is printed after 1000 milliseconds");
      buttonChangeAllowed = true;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: <Widget>[
          PageView(
            controller: _myPage,
            children: <Widget>[
              Home(
                key: PageStorageKey('Home')
              ),
              Contato(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
          color: mainColor,
          shape: const CircularNotchedRectangle(),
          notchMargin: 5,
          child: Container(
            height: 90,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.home,
                    color: Colors.white,
                    size: 35,
                  ),
                  onPressed: () {
                    setState(() {
                      _myPage.jumpToPage(0);
                    });
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(right: 120),
                  child: IconButton(
                    icon:
                        Icon(Icons.mail_outline, color: Colors.white, size: 35),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PedidoMusica()));
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.share,
                    color: Colors.white,
                    size: 35,
                  ),
                  onPressed: () {
                    Share.share(
                        "Acompanhe a melhor rádio do Flashback em: https://play.google.com/store/apps/details?id=br.abcradio.web");
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.record_voice_over,
                    color: Colors.white,
                    size: 35,
                  ),
                  onPressed: () {
                    setState(() {
                      _myPage.jumpToPage(1);
                    });
                  },
                )
              ],
            ),
          )),
      floatingActionButton: StreamBuilder(
          stream: AudioService.playbackStateStream,
          builder: (context, snapshot) {
            state = snapshot.data;
            return Container(
                decoration: BoxDecoration(shape: BoxShape.circle),
                height: 120,
                width: 120,
                child: FittedBox(
                  child: buildPlayer(state),
                ));
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget buildPlayer(PlaybackState state) {
    if (buttonStateIsPlaying != null && buttonStateIsPlaying == (state?.basicState == BasicPlaybackState.playing)) {
      print("state is not changed, no change needed.");
    } else {
      if (state?.basicState == BasicPlaybackState.playing) {
        buttonStateIsPlaying = true;
        _animationController.reverse();
        print("state is playing.");
      } else {
        buttonStateIsPlaying = false;
        _animationController.forward();
        print("state is paused.");
      }
    }
    return FloatingActionButton(
      backgroundColor: mainColor,
      onPressed: buttonChange,
      child: Container(
          width: 120,
          margin: EdgeInsets.all(7.5),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
              Border.all(color: _animateColor.value, width: 3.2)),
          child: AnimatedIcon(
            icon: AnimatedIcons.pause_play,
            progress: _animateIcon,
            color: _animateColor.value,
            size: 35,
          )),
    );
  }
}
