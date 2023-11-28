#include <string>
#include <unistd.h>
#include "my_application.h"

int main(int argc, char** argv) {
  if (argc != 1) {
    std::string arg1 = argv[1];
    if (arg1 == "cli") {
      std::string path = argv[0];
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
