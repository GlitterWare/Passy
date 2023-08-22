#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <string.h>

#include "flutter_window.h"
#include "utils.h"

std::string wchar_to_UTF8(const wchar_t* in) {
  std::string out;
  unsigned int codepoint = 0;
  for (in;  *in != 0;  ++in) {
    if (*in >= 0xd800 && *in <= 0xdbff) codepoint = ((*in - 0xd800) << 10) + 0x10000;
    else {
      if (*in >= 0xdc00 && *in <= 0xdfff) codepoint |= *in - 0xdc00;
      else codepoint = *in;

      if (codepoint <= 0x7f) out.append(1, static_cast<char>(codepoint));
      else if (codepoint <= 0x7ff) {
        out.append(1, static_cast<char>(0xc0 | ((codepoint >> 6) & 0x1f)));
        out.append(1, static_cast<char>(0x80 | (codepoint & 0x3f)));
      }
      else if (codepoint <= 0xffff) {
        out.append(1, static_cast<char>(0xe0 | ((codepoint >> 12) & 0x0f)));
        out.append(1, static_cast<char>(0x80 | ((codepoint >> 6) & 0x3f)));
        out.append(1, static_cast<char>(0x80 | (codepoint & 0x3f)));
      }
      else {
        out.append(1, static_cast<char>(0xf0 | ((codepoint >> 18) & 0x07)));
        out.append(1, static_cast<char>(0x80 | ((codepoint >> 12) & 0x3f)));
        out.append(1, static_cast<char>(0x80 | ((codepoint >> 6) & 0x3f)));
        out.append(1, static_cast<char>(0x80 | (codepoint & 0x3f)));
      }
      codepoint = 0;
    }
  }
  return out;
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();
  size_t argc = command_line_arguments.size();
  if (int(argc) != 0) {
    if (command_line_arguments[0].find("cli") != std::string::npos) {
      std::wstring cliArgs = L"";
      for (int i = 1; i != argc; i++) {
        std::string arg = command_line_arguments[i];
        std::wstring argWide(arg.begin(), arg.end());
        cliArgs += argWide;
      }
      if (cliArgs.length() != 0) {
        cliArgs = L" " + cliArgs;
      }
      std::vector<wchar_t> pathBuf; 
      DWORD copied = 0;
      do {
        pathBuf.resize(pathBuf.size() + MAX_PATH);
        copied = static_cast<DWORD>(GetModuleFileName(0, &pathBuf.at(0), static_cast<DWORD>(pathBuf.size())));
      } while(copied >= pathBuf.size());
      pathBuf.resize(copied);
      std::wstring path(pathBuf.begin(), pathBuf.end());
      path = path.substr(0, path.length() - 9);
      path = path + L"passy_cli.exe";
      std::wstring command = L"start " + path + cliArgs;
      std::string commandShort = wchar_to_UTF8(command.c_str());
      std::system(commandShort.c_str());
      return EXIT_SUCCESS;
    }
  }

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.CreateAndShow(L"Passy", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
