package com.example

import io.ktor.serialization.kotlinx.json.*
import io.ktor.server.application.*
import io.ktor.server.plugins.contentnegotiation.*
import org.jetbrains.exposed.sql.Database

fun main(args: Array<String>) {
    io.ktor.server.netty.EngineMain.main(args)
}

fun Application.module() {
    install(ContentNegotiation) {
        json()
    }

    Database.connect(
        "jdbc:postgresql://db:5432/postgres", // Network configured with Docker compose (docker-compose.yml)
        user = "postgres",
        password = "password"
    )

    configureRouting()
}
