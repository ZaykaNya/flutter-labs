class MyBaseClass {
  int x;
  int y;

  MyBaseClass.init(this.x, this.y);
}

class MyClass extends MyBaseClass {
  int a;
  int b;
  int _privateNum = 10;

  // MyClass(this.a, this.b);

  MyClass({required this.a, required this.b}) : super.init(0, 0);

  MyClass.init({required this.a, required this.b}) : super.init(a, b);

  factory MyClass.factory(flag, a, b) {
    return flag ? MyClass(a: a, b: b) : MyClass.init(a: a, b: b);
  }

  @override
  String toString() => "a = $a, b = $b, x = $x, y = $y";

  get getPrivateNum => _privateNum;

  set setPrivateNum(int num) =>
      num > 20 ? _privateNum = num - 5 : _privateNum = num + 5;

  checkNull(dynamic num) {
    dynamic x;
    x ??= 10;
    dynamic a = num ?? 10;
    return [a, x];
  }
}

Function sum(int acc) {
  return (val) => val + acc;
}

void func(x, {y, z = 0}) {
  print("$x $y $z");
}

void assertExample(dynamic number) {
  assert(number > 10, "number should be > 10");
  print(number);
}

enum Color { red, yellow, green }

mixin Mixin {
  late Color _color;

  void setColor(Color color) {
    _color = color;
  }

  Color get color => _color;
}

class SelectColor with Mixin {
  void showColor() {
    print('Selected color $color');
  }
}
