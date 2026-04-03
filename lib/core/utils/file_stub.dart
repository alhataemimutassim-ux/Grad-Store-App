// Stub File for web builds when dart:io is not available.
// This provides a minimal compatible `File` class used only for typing
// so the code can compile on the web. The real `dart:io` File will be
// used on non-web platforms via conditional import.

class File {
  final String path;
  File(this.path);
}
