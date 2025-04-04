package com.example

import io.ktor.server.application.*
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
    }
}
