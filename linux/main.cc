#include <string>
#include <limits.h>
#include <unistd.h>
#include "my_application.h"

std::string getexepath() {
  char result[ PATH_MAX ];
  ssize_t count = readlink( "/proc/self/exe", result, PATH_MAX );
  return std::string( result, (count > 0) ? count : 0 );
}

int main(int argc, char** argv) {
  if (argc != 1) {
    std::string arg1 = argv[1];
    if (arg1 == "cli") {
      std::string path = getexepath();
      path += "_cli";
      char* pathptr = new char [path.length()+1];
      strcpy (pathptr, path.c_str());
      char** args = new char*[argc];
      args[0] = pathptr;
      for (int i = 2; i != argc; i++) {
        args[i - 1] = argv[i];
      }
      args[argc - 1] = (char*)0;
      execv(pathptr, args);
      return 0;
    }
  }
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
