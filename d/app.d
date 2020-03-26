import std.stdio;
import std.conv;
import std.file;
import std.string;
import core.stdc.stdlib;
import core.sys.posix.dlfcn;


void main()
{
  writeln(HEADER_COLOR);
  writeln("┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓\n"
        ~ "┃    D Application                           ┃\n"
        ~ "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛");
  writeln(COLOR_RESET);

  foreach(entry; dirEntries("lib", SpanMode.shallow, false)) {
    entry.name.toStringz.openLib.callMethods.dlclose;
  }
}


/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓*\
  ┃                                                      ┃
  ┃    Internal Helpers                                  ┃
  ┃                                                      ┃
\*┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/


private alias helloFn = void function();
private alias addFn   = int function(int, int);


private const string
  HEADER_COLOR = "\033[38;5;69m",
  INFO_COLOR   = "\033[38;5;238m",
  COLOR_RESET  = "\033[0m",
  SYMBOL_COLOR = "\033[38;5;240m";


private void* callMethods(void* handle) {
  loadSymbol!helloFn(handle, "sayHello")();
  writefln("add(1, 3) returned %d", loadSymbol!addFn(handle, "add")(1, 3));
  return handle;
}

private void printInfo(string info) {
  write(INFO_COLOR);
  write("  " ~ info);
  writeln(COLOR_RESET);
}

private void* openLib(const(char*) lib) {
  printInfo("Loading library: " ~ SYMBOL_COLOR ~ lib.to!string);

  void* handle = dlopen(lib, RTLD_LAZY);
  if (!handle) {
    stderr.writefln("Failed to open lib %s: %s", lib.to!string, dlerror().to!string);
    exit(1);
  }

  return handle;
}

private auto loadSymbol(T)(void* handle, const(char*) name) {
  printInfo("Loading Symbol: " ~ SYMBOL_COLOR ~ name.to!string);
  auto sym = dlsym(handle, name);
  auto err = dlerror();
  if (err) {
    stderr.writefln("Failed to load symbol %s: %s", name.to!string, err.to!string);
    exit(1);
  }
  stdout.write("    ");
  stdout.flush();
  return cast(T)sym;
}