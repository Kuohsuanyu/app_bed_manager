import org.gradle.api.file.Directory

pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    // 引入 Flutter 工具
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

// 插ty件管理
plugins {
    // Flutter plugin loader
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"

    // Android & Kotlin 插ty件，版本須與你的 Flutter/AGP 相容
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
}

// 將模組（app）包含進去
include(":app")

// 讓所有專案都能抓到 google(), mavenCentral()
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ===== 以下為自訂 buildDir 路徑的設定 (可選) =====

// 1. 將根專案的 build 輸出位置移到專案根目錄的「上一層再上一層」(../../build)。
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

// 2. 所有子模組（含 :app）的輸出路徑都改到同一個大 buildDir 的子資料夾
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    layout.buildDirectory.set(newSubprojectBuildDir)

    // 確保在評估子專案時已先評估 :app
    evaluationDependsOn(":app")
}

// 定義全域清理任務
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
