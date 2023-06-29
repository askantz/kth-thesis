package com.example.jsonparserkmm

import kotlinx.serialization.*
import kotlinx.serialization.json.*

class JsonParserKmm {

    fun runBenchmark(mockResponse: String) {
        try {
            // Deserialize the JSON string into a GithubResponse object with an array of events
            val dataDecoded = Json{ignoreUnknownKeys = true}.decodeFromString<GithubResponse>(mockResponse)

            // Serialize the array of Github event objects to a JSON string
            val dataEncoded = Json.encodeToString(dataDecoded)
        } catch (ex: Exception) {
            println("Error occurred when decoding or encoding JSON: ${ex.message}")
        }
    }

    @Serializable
    data class GithubResponse(
        @SerialName("GitHub")
        val GitHub: Array<Event> = emptyArray()
    )

    @Serializable
    data class Event(
        val id: String,
        val type: String,
        val actor: Actor,
        val repo: Repo,
        val payload: Payload? = null,
        val pull_request: PullRequest? = null
    )

    @Serializable
    data class Actor(
        val id: Int,
        val login: String
    )

    @Serializable
    data class Repo(
        val id: Int,
        val name: String,
    )

    @Serializable
    data class Payload(
        val action: String? = null,
        val review: Review? = null,
        val repository_id: Int? = null,
    )

    @Serializable
    data class Review(
        val id: Int,
        val user: User,
        val body: String
    )

    @Serializable
    data class PullRequest(
        var url: String,
        var id: Int
    )

    @Serializable
    data class User(
        val login: String,
        val id: Int
    )
}