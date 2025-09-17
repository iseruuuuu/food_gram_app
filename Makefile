.PHONY: setup
setup:
	fvm flutter pub get
	fvm flutter pub run build_runner build --delete-conflicting-outputs
	fvm dart run flutter_launcher_icons
    dart run flutter_native_splash:create

gen:
	fvm flutter pub get
	fvm flutter pub run build_runner build --delete-conflicting-outputs

submit_android:
	flutter clean
	flutter pub get
	fvm flutter build appbundle --dart-define-from-file=dart_defines/prod.env

# セキュリティチェック
security-check:
	./scripts/security_check.sh

# セットアップ時にセキュリティチェックも実行
setup-secure: setup security-check

# 環境ファイルのテンプレートからコピー
setup-env:
	@if [ ! -f dart_defines/dev.env ]; then \
		cp dart_defines/dev.env.template dart_defines/dev.env; \
		echo "✅ dev.env を作成しました"; \
	else \
		echo "⚠️  dev.env は既に存在します"; \
	fi
	@if [ ! -f dart_defines/prod.env ]; then \
		cp dart_defines/prod.env.template dart_defines/prod.env; \
		echo "✅ prod.env を作成しました"; \
	else \
		echo "⚠️  prod.env は既に存在します"; \
	fi
