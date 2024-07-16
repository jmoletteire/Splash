class CustomKey {
  final String variable1;
  final String variable2;

  CustomKey(this.variable1, this.variable2);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CustomKey) return false;
    return other.variable1 == variable1 && other.variable2 == variable2;
  }

  @override
  int get hashCode => variable1.hashCode ^ variable2.hashCode;
}
