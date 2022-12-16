import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}


enum CaseType { NOTHING, MAIN_CHARACTER, LADDER, COIN, GHOST }

const List<List<CaseType>> level1Map = [
  [
    CaseType.NOTHING,
    CaseType.NOTHING,
    CaseType.NOTHING,
    CaseType.NOTHING,
    CaseType.NOTHING,
  ],
  [
    CaseType.LADDER,
    CaseType.NOTHING,
    CaseType.NOTHING,
    CaseType.NOTHING,
    CaseType.NOTHING,
  ],
  [
    CaseType.NOTHING,
    CaseType.NOTHING,
    CaseType.LADDER,
    CaseType.NOTHING,
    CaseType.NOTHING,
  ],
  [
    CaseType.NOTHING,
    CaseType.NOTHING,
    CaseType.NOTHING,
    CaseType.NOTHING,
    CaseType.LADDER,
  ],
  [
    CaseType.NOTHING,
    CaseType.NOTHING,
    CaseType.NOTHING,
    CaseType.NOTHING,
    CaseType.LADDER,
  ],
];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Flutter game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Simple Flutter game'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _coins = 0;
  int _ghosts = 0;
  int _nbMove = 0;

  bool gameFinished = false;

  List<List<CaseType>> level1 = [
    [
      CaseType.MAIN_CHARACTER,
      CaseType.NOTHING,
      CaseType.NOTHING,
      CaseType.NOTHING,
      CaseType.GHOST,
    ],
    [
      CaseType.NOTHING,
      CaseType.NOTHING,
      CaseType.NOTHING,
      CaseType.COIN,
      CaseType.GHOST,
    ],
    [
      CaseType.NOTHING,
      CaseType.NOTHING,
      CaseType.NOTHING,
      CaseType.COIN,
      CaseType.NOTHING,
    ],
    [
      CaseType.NOTHING,
      CaseType.COIN,
      CaseType.COIN,
      CaseType.NOTHING,
      CaseType.NOTHING,
    ],
    [
      CaseType.GHOST,
      CaseType.GHOST,
      CaseType.NOTHING,
      CaseType.NOTHING,
      CaseType.NOTHING,
    ],
  ];

  List getCharacterPosition() {
    int? characterX;
    int? characterY;
    for (var y = 0; y < level1.length; y++) {
      for (var x = 0; x < level1[y].length; x++) {
        if (level1[y][x] == CaseType.MAIN_CHARACTER) {
          characterX = x;
          characterY = y;
        }
      }
    }
    return [characterX, characterY];
  }

  void onTap(int positionX, int positionY) {
    setState(() {
      if (gameFinished) return;
      List characterPosition = getCharacterPosition();
      int? characterX = characterPosition[0];
      int? characterY = characterPosition[1];
      if (characterX == null || characterY == null) return;

      // can move to the case ?
      if (positionY == characterY) {
        if (characterX == positionX - 1 || characterX == positionX + 1) {
          if (level1[positionY][positionX] == CaseType.COIN) {
            _coins++;
          } else if (level1[positionY][positionX] == CaseType.GHOST) {
            if (_coins > 0) {
              _ghosts++;
              _coins--;
            } else {
              return;
            }
          }

          level1[characterY][characterX] = level1Map[characterY][characterX];
          level1[positionY][positionX] = CaseType.MAIN_CHARACTER;
          _nbMove++;
        }
      } else {
        if (positionX == characterX) {
          if (characterY == positionY - 1 || characterY == positionY + 1) {
            if (level1Map[positionY][positionX] == CaseType.LADDER &&
                positionY == characterY + 1 ||
                level1Map[characterY][characterX] == CaseType.LADDER &&
                    positionY == characterY - 1) {
              if (level1[positionY][positionX] == CaseType.COIN) {
                _coins++;
              } else if (level1[positionY][positionX] == CaseType.GHOST) {
                if (_coins > 0) {
                  _ghosts++;
                  _coins--;
                } else {
                  return;
                }
              }

              level1[characterY][characterX] =
              level1Map[characterY][characterX];
              level1[positionY][positionX] = CaseType.MAIN_CHARACTER;
              _nbMove++;
            }
          }
        }
      }

      checkGameFinished();
    });
  }

  void checkGameFinished() {
    var hasGhost = false;
    for (var y = 0; y < level1.length; y++) {
      for (var x = 0; x < level1[y].length; x++) {
        if (level1[y][x] == CaseType.GHOST) {
          hasGhost = true;
          break;
        }
      }
      if (hasGhost) break;
    }

    gameFinished = !hasGhost;
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: (event) {
        List characterPosition = getCharacterPosition();
        int? characterX = characterPosition[0];
        int? characterY = characterPosition[1];
        if (characterX == null || characterY == null) return;

        if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
          onTap(characterX, characterY - 1);
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
          onTap(characterX, characterY + 1);
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          onTap(characterX + 1, characterY);
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          onTap(characterX - 1, characterY);
        }
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Text(_coins.toString(),
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        Text(
                          getIcon(CaseType.COIN),
                          style:
                          TextStyle(fontSize: getIconSize(CaseType.COIN)),
                        )
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Text(_nbMove.toString(),
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        Text(
                          getIcon(CaseType.MAIN_CHARACTER),
                          style: TextStyle(
                              fontSize: getIconSize(CaseType.MAIN_CHARACTER)),
                        )
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Text(_ghosts.toString(),
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        Text(
                          getIcon(CaseType.GHOST),
                          style:
                          TextStyle(fontSize: getIconSize(CaseType.GHOST)),
                        )
                      ],
                    ),
                  )
                ],
              ),
              Expanded(
                  child: GridView.count(
                    crossAxisCount: 5,
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 0,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    primary: false,
                    children: <Widget>[
                      for (var y = 0; y < level1.length; y++)
                        for (var x = 0; x < level1[y].length; x++)
                          GestureDetector(
                            onTap: () {
                              onTap(x, y);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  border:
                                  Border.all(color: Colors.black, width: 0.5)),
                              child: Stack(
                                children: [
                                  Center(
                                      child: Text(
                                        getIcon(level1Map[y][x]),
                                        style: TextStyle(
                                            fontSize: getIconSize(level1Map[y][x])),
                                      )),
                                  Center(
                                      child: Text(getIcon(level1[y][x]),
                                          style: TextStyle(
                                              fontSize:
                                              getIconSize(level1[y][x])))),
                                ],
                              ),
                            ),
                          )
                    ],
                  )),
              if (gameFinished) const Text("Game finished")
            ],
          )),
    );
  }

  double getIconSize(CaseType type) {
    switch (type) {
      case CaseType.NOTHING:
        return 0;
      case CaseType.MAIN_CHARACTER:
        return 45;
      case CaseType.LADDER:
        return 60;
      case CaseType.COIN:
        return 45;
      case CaseType.GHOST:
        return 45;
    }
  }

  String getIcon(CaseType type) {
    switch (type) {
      case CaseType.NOTHING:
        return "";
      case CaseType.MAIN_CHARACTER:
        return "🕴";
      case CaseType.LADDER:
        return "🪜";
      case CaseType.COIN:
        return "💵";
      case CaseType.GHOST:
        return "👻";
    }
  }
}