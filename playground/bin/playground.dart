import 'package:playground/playground.dart' as playground;

void main(List<String> arguments) {
  contador().listen((valor) {
    print("Valor: $valor");
  });
}

Stream<int> contador() async* {
  for(int i = 1; i <= 5; i++){
    await Future.delayed(Duration(seconds: 1));
    yield i;
  }
}
