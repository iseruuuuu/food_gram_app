.PHONY: setup gen ci

ci:
	fvm flutter pub get --enforce-lockfile
	fvm dart run slang
	fvm dart run build_runner build
	fvm flutter test

setup:
	fvm flutter pub get
	fvm dart run slang
	fvm dart run build_runner build
	fvm dart run flutter_launcher_icons
	fvm dart run flutter_native_splash:create

gen:
	fvm flutter pub get
	fvm dart run slang
	fvm dart run build_runner build

submit_android:
	fvm flutter clean
	fvm flutter pub get
	fvm flutter build appbundle --dart-define-from-file=dart_defines/prod.env
