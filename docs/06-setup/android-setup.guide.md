# Android 네이티브 설정 가이드 (token-vault)

> Flutter 코드(lib/)만으로는 안 되는 **네이티브 설정**. `flutter create .` 직후 1회 적용.
> 보안 근거: Design §7 Security Considerations.

## 0. 사전 준비

```bash
flutter create .            # android/ ios/ 네이티브 셸 생성 (lib/, pubspec 보존)
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # app_database.g.dart 생성
```

> `flutter create .`는 기존 `lib/`·`pubspec.yaml`을 덮어쓰지 않습니다(없는 것만 생성).

---

## 1. minSdk 23 + multiDex — `android/app/build.gradle.kts`

SQLCipher와 Keystore `setUserAuthenticationRequired`는 API 23+ 필요.

```kotlin
android {
    defaultConfig {
        minSdk = 23                 // SQLCipher / Keystore 요구
        multiDexEnabled = true
    }
}
```

> 구버전(Groovy `build.gradle`)이면:
> ```groovy
> defaultConfig { minSdkVersion 23; multiDexEnabled true }
> ```

---

## 2. AndroidManifest — `android/app/src/main/AndroidManifest.xml`

핵심: **INTERNET 권한 없음**(오프라인), **allowBackup=false**(adb 평문 백업 차단), 알림 권한.

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- 알림 (Android 13+) -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <!-- workmanager 주기 작업 부팅 후 재등록 -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <!-- 생체인증 -->
    <uses-permission android:name="android.permission.USE_BIOMETRIC"/>

    <!-- ⚠️ INTERNET 권한은 의도적으로 추가하지 않음 (외부 전송 0) -->

    <application
        android:label="TokenManager"
        android:icon="@mipmap/ic_launcher"
        android:allowBackup="false"
        android:fullBackupContent="false"
        android:dataExtractionRules="@xml/data_extraction_rules">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme"/>
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2"/>
    </application>
</manifest>
```

> `flutter create`가 만든 manifest에서 위 권한/속성만 추가·수정하면 됩니다.

### 2-1. 백업 제외 규칙 (Android 12+) — `android/app/src/main/res/xml/data_extraction_rules.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup><exclude domain="root" path="."/></cloud-backup>
    <device-transfer><exclude domain="root" path="."/></device-transfer>
</data-extraction-rules>
```

---

## 3. MainActivity — FlutterFragmentActivity + FLAG_SECURE

`android/app/src/main/kotlin/.../MainActivity.kt`

- `local_auth`는 **FlutterFragmentActivity** 요구 (기본 FlutterActivity면 BiometricPrompt 크래시).
- `FLAG_SECURE`로 스크린샷·최근앱 미리보기 차단 (Design §7).

```kotlin
package com.example.token_manager   // 실제 패키지명으로 교체

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // 민감 화면 보호: 스크린샷 / 최근앱 썸네일 차단
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
        super.onCreate(savedInstanceState)
    }
}
```

---

## 4. 테마 styles.xml (local_auth 다크모드 충돌 방지, 선택)

`values/styles.xml`·`values-night/styles.xml`의 부모 테마가 `Theme.AppCompat` 계열인지 확인. Flutter 기본 `LaunchTheme`/`NormalTheme` 유지하면 대부분 OK.

---

## 5. 검증 체크리스트

| 항목 | 확인 |
|------|------|
| `flutter analyze` 무경고 | ☐ |
| `flutter test` (L1 단위) 그린 | ☐ |
| 앱 실행 시 LockScreen → 생체/PIN 인증 후 목록 진입 | ☐ |
| 토큰 추가 → 재실행 → 데이터 유지(DB 암호화 동작) | ☐ |
| 노트에 `ghp_xxx...` 입력 시 경고 다이얼로그(저장은 가능) | ☐ |
| 백업 export → 데이터 삭제 → import → 복원 | ☐ |
| 잘못된 패스프레이즈 복원 → "비밀번호가 올바르지 않습니다" | ☐ |
| 스크린샷 시도 → 차단(FLAG_SECURE) | ☐ |

---

## 6. Flutter 3.44 / AGP 9 빌드 호환성 (실제 적용됨)

Flutter 3.44.2 템플릿 기본값(AGP 9 + Built-in Kotlin)에서 다수 플러그인이 미대응 → 아래로 고정:

| 파일 | 변경 | 이유 |
|------|------|------|
| `android/settings.gradle.kts` | AGP `9.0.1`→`8.11.1`, kotlin `2.3.20`→`2.2.20` | share_plus/workmanager가 KGP 자체 적용 → AGP9 Built-in Kotlin과 충돌. AGP8 레거시 경로로 통일 (8.11.1은 Flutter 권장 하한, validation 경고 제거) |
| `android/gradle/wrapper/...properties` | Gradle `9.1.0`→`8.13` | AGP 8.11.1 호환 |
| `android/gradle.properties` | `android.builtInKotlin=false`, `kotlin.incremental=false` | 레거시 KGP / Windows 증분캐시 버그 우회 |
| `android/app/build.gradle.kts` | `compileSdk=36`, `minSdk=max(23,..)`, `multiDexEnabled`, `isCoreLibraryDesugaringEnabled=true` + `desugar_jdk_libs:2.1.4` | 플러그인 API36 요구 / flutter_local_notifications desugaring 요구 |
| `pubspec.yaml` | `workmanager 0.5.2→0.9.0+3`, `file_picker 8→11` | 0.5.2/8.x는 AGP8+최신Kotlin 컴파일 실패 |

> 향후 Flutter는 KGP 자체적용 플러그인 빌드를 막을 예정(경고 출력 중). 플러그인들이 Built-in Kotlin 지원하면 AGP 9로 복귀 가능.

## 7. 자동 실행

`run_emulator.bat` 더블클릭 → (flutter 경로 자동) pub get → build_runner → analyze → test → 에뮬레이터(`MangaView_API35_64GB`) 기동 → run.

### 검증 완료 (2026-06-12)
- `flutter analyze`: No issues found ✅
- `flutter test`: 11/11 passed ✅ (상태분류 7 + 백업 암복호 4)
- `flutter build apk --debug`: 성공 (app-debug.apk 생성) ✅
