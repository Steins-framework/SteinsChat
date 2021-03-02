import 'dart:async';

var jsonDecoder = JsonDecoder();

class JsonDecoder<S,string> implements StreamTransformerBase<String, String>{

  StreamController _controller;

  StreamSubscription _subscription;

  bool cancelOnError;

  bool _sync = false;

  // Original Stream
  Stream<String> _stream;

  JsonDecoder({bool sync: false, this.cancelOnError}) {
    _sync = sync;

    _reload();
  }

  void _reload(){
    _controller = new StreamController<String>.broadcast(onListen: _onListen, onCancel: _onCancel, sync: _sync);
  }

  void _onListen() {
    _subscription = _stream.listen(
        onData,
        onError: _controller.addError,
        onDone: _controller.close,
        cancelOnError: cancelOnError);
  }

  void _onCancel() {
    _subscription.cancel();
    _subscription = null;
  }

  var _buffer = "";
  // List<String> _labelStack = [];

  /// Transformation
  void onData(String data) {
    // print('onData:' + data);

    _buffer += data;

    /**
     * 这段代码有名字的，我把他叫做对生活的妥协。爷的青春，今天被两个反括号结束了
     */

    if (_buffer.startsWith('{') && _buffer.endsWith('}') && ! _buffer.contains('}{')){
      _controller.add(_buffer);
      _buffer = '';
      return;
    }

    if (! _buffer.contains('}{')) {
      return;
    }

    List<String> json = _buffer.split('}{');

    for (int i = 0; i < json.length; i++) {
      if (i == 0) {
        _controller.add(json[i] += '}');
        continue;
      }

      if (i == json.length - 1) {
        if (json[i].endsWith('}')) {
          _controller.add('{' + json[i]);
          _buffer = '';
        } else {
          _buffer = '{' + json.last;
        }
        break;
      }

      _controller.add('{' + json[i] + '}');
    }

    // for(int i = 0; i < _buffer.length; i++){
    //   var s = _buffer[i];
    //
    //   if(_canExist(_labelStack, s)){
    //     _buffer += s;
    //   }
    //
    //   if (_mustIgnore(_labelStack, s)){
    //     continue;
    //   }
    //   if (_isOpen(_labelStack, s)){
    //     _labelStack.add(s);
    //
    //     continue;
    //   }
    //
    //   if(_isClose(_labelStack, s)){
    //     if (_labelStack.isNotEmpty && _isPairs(_labelStack.last, s)){
    //       _labelStack.removeLast();
    //     }else{
    //       // buffer is break
    //       _buffer = '';
    //       _labelStack = [];
    //     }
    //   }
    //
    //   if(_buffer != "" && _labelStack.isEmpty){
    //     _controller.add(_buffer);
    //   }
    // }
  }

  // bool _isOpen(List<String> context, String string){
  //   if(context.isNotEmpty && context.last == '"' && string == '"'){
  //     return false;
  //   }
  //   return ['{', '[', ':'].contains(string);
  // }
  //
  // bool _isClose(List<String> context, String string){
  //   if(context.isEmpty && context.last != '"' && string == '"'){
  //     return false;
  //   }
  //   return ['}', ']', ','].contains(string);
  // }
  //
  // bool _mustIgnore(List<String> context, String string){
  //   if(context.isEmpty){
  //     return string == '{';
  //   }
  //   if (context.last == '"' && string != '"'){
  //     return true;
  //   }
  //   if (context.last == '[' && string == ','){
  //     return true;
  //   }
  //   return false;
  // }
  //
  // bool _canExist(List<String> context, String string){
  //   if(context.isEmpty){
  //     return string == '{';
  //   }
  //
  //   if(context.last == ':' && string != ':'){
  //     return true;
  //   }
  //
  //   return false;
  // }
  //
  // var pairsMap = {
  //   '{' : '}', '[' : ']', ':' : ',',
  // };
  //
  // bool _isPairs(String left, String right){
  //   if(left == '"' && right == '"'){
  //     return true;
  //   }
  //
  //   return pairsMap[left] == right;
  // }


  /// Bind
  Stream<String> bind(Stream<String> stream) {
    _reload();

    this._stream = stream;
    return _controller.stream;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    // TODO: implement cast
    throw UnimplementedError();
  }
}

