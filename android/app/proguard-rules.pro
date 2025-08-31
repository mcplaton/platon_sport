# Flutter عام
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn javax.**
-dontwarn org.codehaus.**

# VLC
-keep class org.videolan.libvlc.** { *; }
-keep class org.videolan.libvlc.interfaces.** { *; }
-keep class org.videolan.libvlc.util.** { *; }
-keep class org.videolan.libvlc.MediaPlayer$Event { *; }
-keep class org.videolan.libvlc.Media$Event { *; }
-dontwarn org.videolan.**

# Google Play Core (deferred components)
-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.play.**
