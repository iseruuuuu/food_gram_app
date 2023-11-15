.PHONY: setup
setup:
	fvm flutter pub get
	fvm flutter pub run build_runner build --delete-conflicting-outputs
	fvm flutter pub run flutter_launcher_icons
    dart run flutter_native_splash:create
