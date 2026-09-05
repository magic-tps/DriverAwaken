import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val releaseBuildRequested = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}
if (releaseBuildRequested) {
    require(keystorePropertiesFile.exists()) {
        "Falta android/key.properties para compilar un release firmado."
    }
}
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

fun requiredReleaseProperty(name: String): String {
    val value = keystoreProperties.getProperty(name)?.trim()
    require(!value.isNullOrEmpty()) {
        "Falta la propiedad $name en android/key.properties."
    }
    return value
}

android {
    namespace = "com.magicdrive.alert"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.magicdrive.alert"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (releaseBuildRequested) {
                keyAlias = requiredReleaseProperty("keyAlias")
                keyPassword = requiredReleaseProperty("keyPassword")
                val releaseStoreFile = rootProject.file(requiredReleaseProperty("storeFile"))
                require(releaseStoreFile.exists()) {
                    "No existe el keystore release configurado."
                }
                storeFile = releaseStoreFile
                storePassword = requiredReleaseProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            if (releaseBuildRequested) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}
