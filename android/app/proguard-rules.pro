# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

#指定压缩级别
-optimizationpasses 5

##不跳过非公共的库的类成员
#-dontskipnonpubliclibraryclassmembers
#
##混淆时采用的算法
#-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*
#
##把混淆类中的方法名也混淆了
#-useuniqueclassmembernames
#
##优化时允许访问并修改有修饰符的类和类的成员
#-allowaccessmodification

#将文件来源重命名为“SourceFile”字符串
-renamesourcefileattribute SourceFile
#保留行号
-keepattributes SourceFile,LineNumberTable
#保持泛型
-keepattributes Signature

#Fragment不需要在AndroidManifest.xml中注册，需要额外保护下
-keep public class * extends android.support.v4.app.Fragment
-keep public class * extends android.app.Fragment

#保持所有实现 Serializable 接口的类成员
-keepclassmembers class * implements java.io.Serializable {
   static final long serialVersionUID;
   private static final java.io.ObjectStreamField[] serialPersistentFields;
   private void writeObject(java.io.ObjectOutputStream);
   private void readObject(java.io.ObjectInputStream);
   java.lang.Object writeReplace();
   java.lang.Object readResolve();
}

-keepattributes Signature
-keepattributes *Annotation*

-keep class com.chivox.** {*;}

-keep class io.flutter.** { *; }
-keep public class * implements io.flutter.embedding.engine.plugins.FlutterPlugin
-keepclassmembers class * implements io.flutter.embedding.engine.plugins.FlutterPlugin

-keep public class * implements io.flutter.plugin.common.MethodChannel.MethodCallHandler
-keepclassmembers class * implements io.flutter.plugin.common.MethodChannel.MethodCallHandler

-keep public class * implements io.flutter.plugin.common.EventChannel.StreamHandler
-keepclassmembers class * implements io.flutter.plugin.common.EventChannel.StreamHandler

-keep class xyz.luan.audioplayers.** { *; }

# fijkplayer
-keep class tv.danmaku.ijk.media.player.** { *; }

#信鸽
-keep class com.tencent.** {*;}
-keep class com.jg.** {*;}
-keep class com.huawei.** {*;}
-keep class com.mcs.** {*;}
-keep class com.vivo.** {*;}

# egret
-keep class org.egret.** {*;}
-keep class com.google.** { *; }
-keep class com.liulishuo.** { *; }

# okhttp
-dontwarn com.squareup.okhttp3.**
-keep class com.squareup.okhttp3.** { *; }
-dontwarn okhttp3.**
-keep class okhttp3.** { *; }
-dontwarn okio.**
-keep class okio.** { *; }

-keep class com.umeng.** {*;}
-keep class com.jarvan.** {*;}
-keep class top.zibin.luban.** {*;}
-keep class org.kxml2.** {*;}
-keep class org.xmlpull.** {*;}
-keep class org.hamcrest.** {*;}
-keep class javax.inject.** {*;}
-keep class com.geetest.** {*;}