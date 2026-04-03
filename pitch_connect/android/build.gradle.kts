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

subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.findByName("android")
            if (android is com.android.build.gradle.BaseExtension) {
                android.compileSdkVersion(35)
                if (android is com.android.build.gradle.LibraryExtension) {
                    if (android.namespace == null) {
                        android.namespace = project.group.toString()
                    }
                }
            }
        }
    }
}

subprojects {
    configurations.all {
        resolutionStrategy {
            force("androidx.core:core:1.10.1")
            force("androidx.core:core-ktx:1.10.1")
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
