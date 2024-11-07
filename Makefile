.PHONY: setup
setup:
	fvm flutter pub get
	fvm flutter pub run build_runner build --delete-conflicting-outputs
	fvm flutter pub run flutter_launcher_icons
    dart run flutter_native_splash:create

gen:
	fvm flutter pub get
	fvm flutter pub run build_runner build --delete-conflicting-outputs

submit_android:
	flutter clean
	flutter pub get
	fvm flutter build appbundle --dart-define-from-file=dart_defines/prod.env

widgetbook:
	fvm flutter run -d Chrome -t lib/widgetbook/widgetbook.dart
