class BinaryOperator {
  static String textToBinary(String text) {
    return text.runes.map((rune) {
      return rune.toRadixString(2).padLeft(16, '0');
    }).join();
  }

  static String binaryToText(String binary) {
    List<String> binaryList = [];
    for (int i = 0; i < binary.length; i += 16) {
      binaryList.add(binary.substring(i, i + 16));
    }
    return String.fromCharCodes(
      binaryList.map(
        (binaryChar) => int.parse(binaryChar, radix: 2),
      ),
    );
  }
}
