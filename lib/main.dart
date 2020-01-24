import 'dart:async';

import 'package:abcradio/pages/contato.dart';
import 'package:abcradio/pages/home_page.dart';
import 'package:abcradio/pages/pedido_musica.dart';
import 'package:flutter/material.dart';
import 'package:abcradio/controllers/player.dart';
import 'package:audio_service/audio_service.dart';
import 'package:share/share.dart';

import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_spin_fade_loader_indicator.dart';

void main() => runApp(MyApp());

class Delayer {
  ValueNotifier<bool> _shouldWaitVn = ValueNotifier<bool>(false);
  ValueNotifier<bool> get shouldWaitVn => _shouldWaitVn;
  bool  get shouldWait => _shouldWaitVn.value;

  void set() {
    _shouldWaitVn.value = true;
    Timer.periodic(Duration(milliseconds: 1000), (t) {
      _shouldWaitVn.value = false;
      t.cancel();
    });
  }
}

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

class FloatinActionButtonWidget extends StatefulWidget {
  final Delayer delayer;
  final Color mainColor;
  final Animation<Color> animateColor;
  final Animation<double> animateIcon;
  final Function buttonChangeFn;

  FloatinActionButtonWidget(this.delayer, this.mainColor, this.animateColor, this.animateIcon, this.buttonChangeFn);

  @override
  _FloatinActionButtonWidgetState createState() => _FloatinActionButtonWidgetState();
}

class _FloatinActionButtonWidgetState extends State<FloatinActionButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.delayer._shouldWaitVn]),
      builder: (context, _) {
        return _buildContent();
      }
    );

  }

   Widget _buildContent() {
    if (widget.delayer.shouldWait) {
      return FloatingActionButton(
        backgroundColor: widget.mainColor,
        onPressed: widget.buttonChangeFn,
        child: Container(
            width: 120,
            margin: EdgeInsets.all(7.5),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                Border.all(color: Colors.grey, width: 3.2)),
            child: Loading(indicator: BallSpinFadeLoaderIndicator(), size: 35.0, color: Colors.grey)
        )
      );
     } else {
        return FloatingActionButton(
          backgroundColor: widget.mainColor,
          onPressed: widget.buttonChangeFn,
          child: Container(
              width: 120,
              margin: EdgeInsets.all(7.5),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                  Border.all(color: widget.animateColor.value, width: 3.2)),
              child: AnimatedIcon(
                icon: AnimatedIcons.pause_play,
                progress: widget.animateIcon,
                color: widget.animateColor.value,
                size: 35,
              )),
          );
     }
   }
}

class MyStatefulWidget extends StatefulWidget {
  final Delayer delayer = Delayer();
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
    widget.delayer.set();
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

  Future buttonChange() async {
    if (widget.delayer.shouldWait) {
      return Future; 
    }
    print("buttonChange() happening");
    
    if (state?.basicState == BasicPlaybackState.playing) {
      _animationController.forward();
      await AudioService.pause();
    } else {
      _animationController.reverse();
      await AudioService.play();
    }
    widget.delayer.set();
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
                  child: FloatinActionButtonWidget(widget.delayer, mainColor, _animateColor, _animateIcon, buttonChange)
                ));
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
