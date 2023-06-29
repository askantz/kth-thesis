pluginManagement {
    repositories {
        google()
        gradlePluginPortal()
        mavenCentral()
    }
}

dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "kmm"
include(":androidApp")
include(":shared")
include(":fannkuchReduxKmm")
include(":nBodyKmm")
include(":fastaKmm")
include(":reverseComplementKmm")
include(":httpRequesterKmm")
include(":jsonParserKmm")
include(":databaseOperatorKmm")
