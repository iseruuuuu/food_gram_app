#!/bin/bash

# セキュリティチェックスクリプト
# 機密情報の漏洩を防ぐための検証

set -e

echo "🔍 セキュリティチェックを開始します..."

# 1. テンプレートファイルに機密情報が含まれていないかチェック
echo "📋 テンプレートファイルのチェック..."

TEMPLATE_FILES=(
    "dart_defines/dev.env.template"
    "dart_defines/prod.env.template"
)

for file in "${TEMPLATE_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  - $file をチェック中..."
        
        # 機密情報のパターンをチェック
        if grep -q -E "(api|key|secret|token|password|auth)" "$file" -i; then
            echo "❌ エラー: $file に機密情報が含まれている可能性があります"
            exit 1
        fi
        
        echo "  ✅ $file は安全です"
    else
        echo "  ⚠️  $file が見つかりません"
    fi
done

# 2. 実際の環境ファイルがgitignoreに含まれているかチェック
echo "📁 Gitignoreのチェック..."

if grep -q "dart_defines/" .gitignore; then
    echo "  ✅ dart_defines/ はgitignoreに含まれています"
else
    echo "  ❌ エラー: dart_defines/ がgitignoreに含まれていません"
    exit 1
fi

# 3. 環境変数ファイルの権限チェック
echo "🔐 ファイル権限のチェック..."

ENV_FILES=(
    "dart_defines/dev.env"
    "dart_defines/prod.env"
    ".env"
    ".env.dev"
    ".env.prod"
)

for file in "${ENV_FILES[@]}"; do
    if [ -f "$file" ]; then
        perms=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%A" "$file" 2>/dev/null)
        if [ "$perms" != "600" ]; then
            echo "  ⚠️  $file の権限が600ではありません (現在: $perms)"
            chmod 600 "$file"
            echo "  ✅ 権限を600に修正しました"
        else
            echo "  ✅ $file の権限は適切です"
        fi
    fi
done

# 4. 機密情報のパターンチェック
echo "🔍 機密情報パターンのチェック..."

# プロジェクト全体で機密情報のパターンを検索
if grep -r -E "(api[_-]?key|secret[_-]?key|auth[_-]?key|password|token)" . --exclude-dir=.git --exclude-dir=build --exclude-dir=.dart_tool --exclude="*.g.dart" --exclude="*.template" | grep -v "scripts/security_check.sh" | grep -v "docs/SECURITY_GUIDELINES.md"; then
    echo "  ⚠️  機密情報のパターンが検出されました。上記のファイルを確認してください。"
else
    echo "  ✅ 機密情報のパターンは検出されませんでした"
fi

echo "🎉 セキュリティチェックが完了しました！"
