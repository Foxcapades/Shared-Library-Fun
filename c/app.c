#include <dlfcn.h>
#include <stdlib.h>
#include <stdio.h>
#include <dirent.h>

const char* COLOR_INFO   = "\033[38;5;238m";
const char* COLOR_RESET  = "\033[0m";
const char* COLOR_SYMBOL = "\033[38;5;240m";

typedef void helloFn();
typedef int  addFn(int, int);

void printHeader();
void libPath(char[], const char*);
void run(const char*);

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓*\
  ┃                                                      ┃
  ┃    Application                                       ┃
  ┃                                                      ┃
\*┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/


int main() {
  printHeader();
  
  DIR* d;
  struct dirent* dir;

  char buf[10] = "lib/";
  if (d = opendir(buf)) {

    while (dir = readdir(d)) {
      if (dir->d_type == DT_REG) {
        libPath(buf, dir->d_name);
        run(buf);
      }
    }
  }
}


/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓*\
  ┃                                                      ┃
  ┃    Internal Helpers                                  ┃
  ┃                                                      ┃
\*┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/


void printHeader() {
  printf(
    "\033[38;5;69m\n"
    "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓\n"
    "┃    C Application                           ┃\n"
    "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
    "\033[0m\n\n"
  );
}

void printInfo(const char* leader, const char* name) {
  printf("  %s%s%s%s%s\n", COLOR_INFO, leader, COLOR_SYMBOL, name, COLOR_RESET);
}

void open(void** handle, const char* name) {
  printInfo("Loading library: ", name);

  *handle = dlopen(name, RTLD_LAZY);

  if (!handle) {
    const char* err = dlerror();
    printf("%s\n", err);
    exit(1);
  }
}

void loadFn(void** sym, void* handle, const char* name) {
  const char* err;

  printInfo("Loading symbol: ", name);

  *sym = dlsym(handle, name);
  err  = dlerror();

  if (err) {
    printf("%s\n", err);
    exit(1);
  }

  printf("    ");
  fflush(stdout);
}

void run(const char* name) {
  void*    handle;
  helloFn* hello;
  addFn*   add;

  open(&handle, name);

  loadFn((void**) &hello, handle, "sayHello");
  (*hello)();

  loadFn((void**) &add, handle, "add");
  printf("add(6, 3) returned %d\n", (*add)(6, 3));
}

void libPath(char buf[10], const char* file) {
  int i = 4;
  for (const char* j = file; i < 10 && *j != '\0'; j++, i++) {
    buf[i] = *j;
  }
  for (; i < 10; i++) {
    buf[i] = '\0';
  }
}
