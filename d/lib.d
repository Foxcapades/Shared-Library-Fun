module d.lib;

import std.stdio: writeln;

extern(C)
void sayHello() {
  writeln("Hello from D");
}

extern(C)
int add(int a, int b) {
  return a + b;
}