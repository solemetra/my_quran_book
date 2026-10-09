import org.gradle.api.plugins.ExtensionAware

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

open class FlutterShim {
    val compileSdkVersion: Int = 35
    val minSdkVersion: Int = 21
    val targetSdkVersion: Int = 35
}

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    if (project.name != "app") {
        val shim = FlutterShim()
        extensions.add("flutter", shim)
        extra["flutter"] = shim

        project.plugins.withId("com.android.library") {
            val androidExt = project.extensions.findByName("android")
            (androidExt as? ExtensionAware)?.extensions?.add("flutter", shim)
            (androidExt as? com.android.build.gradle.BaseExtension)?.compileSdkVersion(35)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
