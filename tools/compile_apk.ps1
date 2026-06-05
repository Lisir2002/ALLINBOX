# ALL IN BOX - APK 编译脚本
# 用法: .\compile_apk.ps1 -ProjectPath "C:\path\to\project" -PackageName "com.allinbox.app"
param(
    [string]$ProjectPath,
    [string]$PackageName = "com.allinbox.generated",
    [string]$AppName = "Generated App"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " ALL IN BOX - APK 编译引擎" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "项目路径: $ProjectPath" -ForegroundColor Yellow
Write-Host "包名: $PackageName" -ForegroundColor Yellow
Write-Host "应用名: $AppName" -ForegroundColor Yellow
Write-Host ""

# 检查 Flutter SDK
Write-Host "[1/5] 检查 Flutter SDK..." -ForegroundColor Green
try {
    $flutterVersion = flutter --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "错误: 未找到 Flutter，请确保 Flutter SDK 已安装并加入 PATH" -ForegroundColor Red
        exit 1
    }
    Write-Host "  Flutter OK" -ForegroundColor Green
} catch {
    Write-Host "错误: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 创建完整的 Flutter 项目
Write-Host "[2/5] 创建 Flutter 项目..." -ForegroundColor Green
$tempDir = Join-Path $env:TEMP "allinbox_gen_$(Get-Date -Format 'yyyyMMddHHmmss')"

try {
    flutter create --org com.allinbox --project-name $PackageName.Replace('.','_') $tempDir 2>&1 | Out-Null
    
    # 替换 main.dart
    $mainDart = Join-Path $ProjectPath "lib" "main.dart"
    $targetMain = Join-Path $tempDir "lib" "main.dart"
    if (Test-Path $mainDart) {
        Copy-Item $mainDart $targetMain -Force
        Write-Host "  源码已复制" -ForegroundColor Green
    }

    # 替换 pubspec.yaml
    $pubspec = Join-Path $ProjectPath "pubspec.yaml"
    $targetPubspec = Join-Path $tempDir "pubspec.yaml"
    if (Test-Path $pubspec) {
        Copy-Item $pubspec $targetPubspec -Force
    }

    # 添加 webview_flutter 依赖
    Write-Host "  添加依赖..." -ForegroundColor Green
    Push-Location $tempDir
    flutter pub add webview_flutter 2>&1 | Out-Null
    Pop-Location

    Write-Host "  项目创建完成" -ForegroundColor Green
} catch {
    Write-Host "错误: 项目创建失败 - $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 生成签名密钥
Write-Host "[3/5] 生成签名密钥..." -ForegroundColor Green
$keystorePath = Join-Path $tempDir "android" "app" "upload-keystore.jks"
$keytool = "keytool"
try {
    & $keytool -genkey -v -keystore $keystorePath -keyalg RSA -keysize 2048 -validity 10000 -alias upload -storepass allinbox2024 -keypass allinbox2024 -dname "CN=$AppName, OU=ALLINBOX, O=ALLINBOX, L=Beijing, ST=Beijing, C=CN" 2>&1 | Out-Null
    Write-Host "  密钥生成完成" -ForegroundColor Green
} catch {
    Write-Host "警告: 密钥生成使用默认方式" -ForegroundColor Yellow
}

# 创建 key.properties
$keyProps = Join-Path $tempDir "android" "key.properties"
@"
storePassword=allinbox2024
keyPassword=allinbox2024
keyAlias=upload
storeFile=upload-keystore.jks
"@ | Out-File $keyProps -Encoding UTF8

# 更新 Android build.gradle
Write-Host "[4/5] 配置签名..." -ForegroundColor Green
$buildGradle = Join-Path $tempDir "android" "app" "build.gradle"
if (Test-Path $buildGradle) {
    $content = Get-Content $buildGradle -Raw
    # 添加签名配置
    if ($content -notmatch "keystoreProperties") {
        $signConfig = @"

// ALL IN BOX 签名配置
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
"@
        $content = $signConfig + $content
        $content | Out-File $buildGradle -Encoding UTF8
    }
}

# 编译 APK
Write-Host "[5/5] 编译 APK..." -ForegroundColor Green
Write-Host "  这可能需要 2-5 分钟..." -ForegroundColor Yellow
Push-Location $tempDir
flutter pub get 2>&1 | Out-Null
$buildResult = flutter build apk --release 2>&1
$buildExitCode = $LASTEXITCODE
Pop-Location

if ($buildExitCode -eq 0) {
    $apkPath = Join-Path $tempDir "build" "app" "outputs" "flutter-apk" "app-release.apk"
    if (Test-Path $apkPath) {
        $outputPath = Join-Path $ProjectPath "app-release.apk"
        Copy-Item $apkPath $outputPath -Force
        
        Write-Host "" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host " 编译成功!" -ForegroundColor Green
        Write-Host " APK 路径: $outputPath" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        
        # 尝试安装到设备
        $adbPath = Join-Path $env:ANDROID_HOME "platform-tools" "adb.exe"
        if (Test-Path $adbPath) {
            Write-Host "正在安装到设备..." -ForegroundColor Yellow
            & $adbPath install -r $outputPath
        }
        
        # 返回 APK 路径
        Write-Output $outputPath
    }
} else {
    Write-Host "" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host " 编译失败!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host $buildResult -ForegroundColor Red
    exit 1
}
