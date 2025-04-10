package com.example

import EchoData
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun Application.configureRouting() {
    routing {
        get("/") {
            call.respondText("Hello World!")
        }
        get("/lipsum") {
            val lipsumText = java.io.File("/tmp/lipsum.txt").readText()
            call.respondText(lipsumText)
        }
        post("/json") {
            try {
                // Receive and deserialize JSON into EchoData
                val data = call.receive<EchoData>()

                // Serializes EchoData and responds
                call.respond(HttpStatusCode.OK, data)
            } catch (e: Exception) {
                call.respond(HttpStatusCode.BadRequest, "Invalid request")
            }
        }
    }
}
