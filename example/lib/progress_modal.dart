import 'package:flutter/material.dart';

class ProgressModal {
  _Progress _progress;
  BuildContext _context;
  BuildContext _cancelContext;
  bool displayed;

  ProgressModal(BuildContext context) {
    _context = context;
    displayed = false;
  }

  void show(String message, {Function cancelFunction}) {
    if (displayed) {
      return;
    }
    if (cancelFunction == null) {
      _progress = new _Progress(message);
    } else {
      _progress = new _Progress(message, cancelFunction: () {
        cancelFunction();
        hide();
      });
    }

    showDialog<dynamic>(
        context: _context,
        barrierDismissible: cancelFunction != null,
        builder: (BuildContext context) {
          _cancelContext = context;
          return new WillPopScope(
              onWillPop: () async => cancelFunction != null,
              child: Dialog(
                  backgroundColor: Colors.white,
                  insetAnimationCurve: Curves.easeInOut,
                  insetAnimationDuration: Duration(milliseconds: 100),
                  elevation: 10.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: _progress));
        });

    displayed = true;
  }

  void update({String message}) {
    if (displayed) {
      _progress.update(message: message);
    }
  }

  void hide() {
    if (displayed) {
      Navigator.of(_cancelContext).pop();
      displayed = false;
    }
  }
}

class _Progress extends StatefulWidget {
  final _ProgressState _progressState;

  _Progress(String message, {Function cancelFunction})
      : _progressState =
            _ProgressState(message, cancelFunction: cancelFunction);

  update({String message}) {
    _progressState.update(message: message);
  }

  @override
  State<StatefulWidget> createState() {
    return _progressState;
  }
}

class _ProgressState extends State<_Progress> {
  String _message;
  Function _cancelFunction;

  _ProgressState(this._message, {Function cancelFunction})
      : _cancelFunction = cancelFunction;

  update({String message}) {
    if (message != null) {
      _message = message;
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                  _message,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600),
                  textDirection: TextDirection.ltr,
                )),
              ],
            ),
          ],
        ),
      ),
    );

    var cancelRow = Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Container(
        padding: const EdgeInsets.only(top: 10),
        child: new InkWell(
          onTap: () => _cancelFunction(),
          child: new Container(
            width: 100,
            height: 38,
            decoration: new BoxDecoration(
              color: Color(0xFF2ECC71),
              borderRadius: new BorderRadius.circular(5),
            ),
            child: new Center(
              child: new Text(
                'CANCEL',
                style: new TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ),
      )
    ]);

    var widgets = _cancelFunction == null
        ? <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(width: 10.0),
                SizedBox(
                  width: 40.0,
                  height: 40.0,
                  child: CircularProgressIndicator(),
                ),
                const SizedBox(width: 20.0),
                text,
                const SizedBox(width: 20.0)
              ],
            )
          ]
        : <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(width: 10.0),
                SizedBox(
                  width: 40.0,
                  height: 40.0,
                  child: CircularProgressIndicator(),
                ),
                const SizedBox(width: 20.0),
                text,
                const SizedBox(width: 20.0)
              ],
            ),
            cancelRow
          ];

    return Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
            mainAxisSize: MainAxisSize.min, children: widgets) // row body
        );
  }
}
