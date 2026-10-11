{ pkgs, ... }: {
  channel = "stable-23.11";
  packages = [
    pkgs.flutter
    pkgs.dart
  ];
  idx = {
    extensions = [
      "Dart-Code.flutter",
      "Dart-Code.dart-code"
    ];
    workspace = {
      onCreate = {
        pub-get = "flutter pub get";
      };
    };
    previews = {
      enable = true;
      previews = {
        web = {
          command = ["flutter" "run" "--machine" "-d" "web-server" "--web-port" "$PORT" "--web-hostname" "0.0.0.0"];
          manager = "flutter";
        };
      };
    };
  };
}
