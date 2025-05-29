plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.fateen"
    compileSdk = 35

    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true  // تأكد من تفعيل Desugaring
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.fateen"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true
    }

    buildTypes {
        release {
            isMinifyEnabled = false // تعطيل تصغير الكود
            isShrinkResources = false // تعطيل إزالة الموارد غير المستخدمة
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")

            // تأكد من استخدام توقيع مناسب عند رفع التطبيق
            signingConfig = signingConfigs.getByName("debug") 
        }
    }

    // إضافة دعم التوافق مع المكتبات المستخدمة
    packagingOptions {
        resources {
            excludes += setOf("META-INF/DEPENDENCIES", "META-INF/LICENSE", "META-INF/LICENSE.txt", "META-INF/license.txt", "META-INF/NOTICE", "META-INF/NOTICE.txt", "META-INF/notice.txt", "META-INF/ASL2.0")
        }
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.6.2")
    
    // دعم Java 8 Desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")

    // دعم MultiDex
    implementation("androidx.multidex:multidex:2.0.1")
    
    // دعم الأذونات - هذه مكتبات مساعدة لتتوافق مع مكتبة permission_handler
    implementation("androidx.core:core:1.12.0")
}

flutter {
    source = "../.."
}