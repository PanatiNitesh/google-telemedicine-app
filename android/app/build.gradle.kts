plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ✅ Required for Firebase & Vertex AI
}

android {
    namespace = "com.example.flutter_project"
    compileSdk = 35
    ndkVersion = "29.0.13113456" // ✅ Using your NDK version

    defaultConfig {
        applicationId = "com.example.flutter_project"
        minSdk = 23 // ✅ Supports Flutter Local Notifications & Vertex AI
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // ✅ Enable MultiDex for large apps
        multiDexEnabled = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            isMinifyEnabled = false // Keep false for debugging
            isShrinkResources = false // Explicitly disable resource shrinking
            signingConfig = signingConfigs.getByName("debug") // ✅ Allow debug signing in release mode
        }
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.8.22") // ✅ Latest stable Kotlin stdlib

    // ✅ Required for Flutter Local Notifications
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")

    // ✅ Ensures proper desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // ✅ Google Vertex AI + Firebase
    implementation(platform("com.google.firebase:firebase-bom:33.5.1"))
    implementation("com.google.firebase:firebase-core") { version { strictly("21.1.1") } }
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-vertexai")

    // ✅ Required for Flutter Local Notifications
    implementation("com.google.android.material:material:1.10.0")
    implementation("androidx.work:work-runtime-ktx:2.8.1")
}

flutter {
    source = "../.."
}
