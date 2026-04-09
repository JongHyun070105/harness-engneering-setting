allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Flutter 표준: 빌드 결과물을 프로젝트 루트의 build/ 폴더로 리다이렉트
// android/build → ../../build → pitch_connect/build/
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

// 모든 서브프로젝트(app, 플러그인 등)의 빌드 디렉토리도 동일한 루트 빌드 폴더 아래로 전파
subprojects {
    val newSubprojectBuildDir: Directory =
        newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.findByName("android")
            if (android is com.android.build.gradle.BaseExtension) {
                android.compileSdkVersion(36)
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
            force("androidx.core:core:1.13.1")
            force("androidx.core:core-ktx:1.13.1")

            // 모든 의존성의 Kotlin 핵심 라이브러리 버전을 2.1.0으로 통일
            eachDependency {
                if (requested.group == "org.jetbrains.kotlin") {
                    useVersion("2.1.0")
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
