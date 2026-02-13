# 設計羅針盤 (Design Compass)

> **AI向け設計ガイドライン**  
> このドキュメントは、AIがコードを生成・修正する際に従うべき設計原則と禁止事項を簡潔にまとめたものです。

## 依存関係のルール

### 依存方向（絶対に守る）

```
View → ViewModel → Repository → Service → Supabase
```

**禁止事項:**
- ❌ ViewがRepositoryやServiceを直接参照する
- ❌ ViewModelがSupabaseを直接参照する
- ❌ RepositoryがViewやViewModelを参照する
- ❌ ServiceがViewやViewModelを参照する
- ❌ 内側のレイヤーが外側のレイヤーに依存する

## 各レイヤーの責務と禁止事項

### View (Screen/Component)

**場所**: `lib/ui/screen/`, `lib/ui/component/`

**責務:**
- UIの描画
- ユーザー操作の受け取り
- ViewModelの状態を監視して表示

**禁止事項:**
- ❌ ビジネスロジックを含める
- ❌ RepositoryやServiceを直接呼び出す
- ❌ Supabaseクライアントに直接アクセスする
- ❌ データ変換やバリデーションを行う
- ❌ 複雑な条件分岐（ViewModelに委譲）

**許可事項:**
- ✅ `ref.watch()`でViewModelの状態を監視
- ✅ `ref.read().notifier`でViewModelのメソッドを呼び出し
- ✅ UI固有のロジック（アニメーション、レイアウト）

### ViewModel

**場所**: `*_view_model.dart` (通常はScreenと同じディレクトリ)

**責務:**
- UI状態の管理（State）
- Repository経由でのデータ取得・更新
- UI向けのデータ変換

**禁止事項:**
- ❌ Supabaseクライアントに直接アクセスする
- ❌ Serviceを直接呼び出す（Repository経由のみ）
- ❌ UI Widgetをimportする
- ❌ 複雑なビジネスロジック（Serviceに委譲）
- ❌ データベースクエリを直接書く

**許可事項:**
- ✅ Repositoryのメソッドを呼び出す
- ✅ Stateを更新する
- ✅ 複数のRepository呼び出しを調整する
- ✅ UI向けの軽いデータ変換

**実装パターン:**
```dart
@riverpod
class MyViewModel extends _$MyViewModel {
  @override
  MyState build() {
    return const MyState();
  }
  
  Future<void> loadData() async {
    state = const MyState.loading();
    final result = await ref.read(repositoryProvider.notifier).getData();
    result.when(
      success: (data) => state = MyState.data(data),
      failure: (_) => state = const MyState.error(),
    );
  }
}
```

### Repository

**場所**: `lib/core/*/repository/*_repository.dart`

**責務:**
- Service呼び出しの抽象化
- キャッシュ管理
- エラーハンドリングの統一

**禁止事項:**
- ❌ Supabaseクライアントに直接アクセスする（Service経由のみ）
- ❌ ViewやViewModelを参照する
- ❌ UI Widgetをimportする
- ❌ 複雑なビジネスロジック（Serviceに委譲）

**許可事項:**
- ✅ Serviceのメソッドを呼び出す
- ✅ キャッシュの無効化・更新
- ✅ 複数のService呼び出しを調整
- ✅ Result型でのエラーハンドリング

**実装パターン:**
```dart
@riverpod
class MyRepository extends _$MyRepository {
  @override
  Future<void> build() async {}
  
  Future<Result<Data, Exception>> getData() async {
    try {
      final data = await ref.read(serviceProvider.notifier).fetchData();
      return Success(data);
    } on Exception catch (e) {
      logger.e('Failed to get data: $e');
      return Failure(e);
    }
  }
}
```

### Service

**場所**: `lib/core/*/services/*_service.dart`

**責務:**
- Supabaseへの直接アクセス
- ビジネスロジックの実装
- データ変換・バリデーション

**禁止事項:**
- ❌ ViewやViewModelを参照する
- ❌ UI Widgetをimportする
- ❌ Repositoryを参照する（循環依存防止）

**許可事項:**
- ✅ Supabaseクライアントに直接アクセス
- ✅ 複雑なビジネスロジック
- ✅ データ変換・バリデーション
- ✅ 外部API呼び出し

**実装パターン:**
```dart
@riverpod
class MyService extends _$MyService {
  SupabaseClient get supabase => ref.read(supabaseProvider);
  
  @override
  Future<void> build() async {}
  
  Future<Map<String, dynamic>> fetchData() async {
    final response = await supabase.from('table').select();
    return response.data;
  }
}
```

### Model

**場所**: `lib/core/model/`

**責務:**
- データ構造の定義
- JSON変換

**禁止事項:**
- ❌ ビジネスロジックを含める
- ❌ ViewやViewModelを参照する
- ❌ RepositoryやServiceを参照する

**許可事項:**
- ✅ Freezedやjson_serializableを使ったデータクラス
- ✅ fromJson/toJsonメソッド

## Riverpod使用ルール

### Providerの種類と使い分け

**Global Provider (keepAlive: true)**
- アプリ全体で共有される状態
- 例: `supabaseProvider`, `currentUserProvider`

**Feature Provider**
- 特定の機能で使用される状態
- 通常は`keepAlive: false`（デフォルト）

**禁止事項:**
- ❌ 不要な`keepAlive: true`の使用
- ❌ ViewModelで`ref.read()`を多用（`ref.watch()`を優先）
- ❌ Providerの循環依存

**命名規則:**
- Provider定義: `*_provider.dart`
- Provider名: `*Provider` (例: `userRepositoryProvider`)
- ViewModel: `*ViewModel` (例: `MyProfileViewModel`)
- Repository: `*Repository` (例: `UserRepository`)
- Service: `*Service` (例: `AuthService`)

### Providerの依存関係

```
ViewModel Provider
  ↓ depends on
Repository Provider
  ↓ depends on
Service Provider
  ↓ depends on
Global Providers (supabase, currentUser)
```

**禁止事項:**
- ❌ ServiceがViewModel Providerに依存する
- ❌ RepositoryがViewModel Providerに依存する

## エラーハンドリング

### Result型の使用

**必須**: 非同期処理は`Result<T, E>`型で返す

```dart
Future<Result<Data, Exception>> getData() async {
  try {
    final data = await service.fetchData();
    return Success(data);
  } on Exception catch (e) {
    return Failure(e);
  }
}
```

**禁止事項:**
- ❌ `Result`型を使わずに例外をthrowする
- ❌ ViewModelで例外をcatchせずに放置する

**ViewModelでの処理:**
```dart
final result = await ref.read(repositoryProvider.notifier).getData();
result.when(
  success: (data) => state = MyState.data(data),
  failure: (error) => state = MyState.error(),
);
```

## State管理

### Stateクラスの定義

**パターン1: Sealed Class (推奨)**
```dart
@freezed
abstract class MyState with _$MyState {
  const factory MyState.loading() = MyStateLoading;
  const factory MyState.data(Data data) = MyStateData;
  const factory MyState.error() = MyStateError;
}
```

**パターン2: 通常のFreezed Class**
```dart
@freezed
class MyState with _$MyState {
  const factory MyState({
    @Default(false) bool isLoading,
    Data? data,
    String? errorMessage,
  }) = _MyState;
}
```

**禁止事項:**
- ❌ Stateにビジネスロジックを含める
- ❌ Stateにメソッドを定義する（ViewModelに定義）

## ファイル命名規則

- Screen: `*_screen.dart` (例: `my_profile_screen.dart`)
- ViewModel: `*_view_model.dart` (例: `my_profile_view_model.dart`)
- State: `*_state.dart` (例: `my_profile_state.dart`)
- Repository: `*_repository.dart` (例: `user_repository.dart`)
- Service: `*_service.dart` (例: `auth_service.dart`)
- Provider: `*_provider.dart` (例: `user_provider.dart`)
- Model: `*.dart` (例: `users.dart`)


**禁止事項:**
- ❌ レイヤーを跨いだファイル配置
- ❌ 循環参照を生むimport

## その他の重要なルール

### キャッシュ管理

- Repositoryでキャッシュの無効化を行う
- Serviceではキャッシュを扱わない

### ログ出力

- ServiceとRepositoryで`Logger`を使用
- ViewModelでは必要最小限
- Viewでは使用しない

### 認証チェック

- `currentUserProvider`を使用してユーザーIDを取得
- ServiceやRepositoryで認証が必要な処理を行う前にチェック

### 非同期処理

- ViewModelの`build()`メソッドで非同期初期化を行う場合は、`build()`内で`Future`を返すか、別メソッドを呼び出す

---

**このドキュメントは、AIがコードを生成・修正する際の指針として使用してください。**