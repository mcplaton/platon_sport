plugins {
    id("com.android.application")
    id("kotlin-android")
    // يجب أن يأتي بعد Android/Kotlin
    id("dev.flutter.flutter-gradle-plugin")
    // إن كنت تستخدم خدمات Google فعّل السطر التالي:
    // id("com.google.gms.google-services")
}

android {
    namespace = "com.example.platon_sport"
    compileSdk = flutter.compileSdkVersion

    // ✅ طابق أعلى NDK مطلوبة من الإضافات
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.platon_sport"

        // ✅ Firestore يتطلب 23+
        minSdk = 23
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // لتفادي أخطاء حجم الديكسبات عند كثرة الحزم
        multiDexEnabled = true

        // ✅ إلغاء وضع Play Store Split Application لتجنب مراجع Play Core
        manifestPlaceholders += mapOf(
            "applicationName" to "io.flutter.app.FlutterApplication"
        )
    }

    // ✅ مهم لتحميل مكتبات libVLC الأصلية في إصدار الريليز
    packagingOptions {
        jniLibs {
            useLegacyPackaging = true
        }
    }

    buildTypes {
        getByName("release") {
            // استخدم توقيعك الفعلي لاحقاً
            signingConfig = signingConfigs.getByName("debug")

            // ✅ تقليل الحجم مع قواعد ProGuard مخصّصة
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        getByName("debug") {
            // الإعدادات الافتراضية تكفي
        }
    }
}

flutter {
    source = "../.."
}

// (اختياري) إن أردت إضافة تبعيات أخرى
dependencies {
    // لا حاجة لأي شيء إضافي هنا عادةً
    // إن رغبت بإسكات تحذيرات Java 8 القديمة لا يؤثر ذلك على الوظيفة
}
