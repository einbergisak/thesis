package com.example

import EchoData
import FilmTable
import Movie
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import java.io.File

fun Application.configureRouting() {
    routing {
        get("/") {
            call.respondText("Hello World!")
        }
        get("/lipsum.txt") {
            call.respondFile(File("/tmp/lipsum.txt"))
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

        get("/postgres") {
            try {
                val randomId = (1..1000).random()
                val result = transaction {
                    FilmTable
                        .selectAll().where { FilmTable.film_id eq randomId }
                        .map {
                            Movie(
                                it[FilmTable.film_id],
                                it[FilmTable.title],
                                it[FilmTable.description]
                            )
                        }
                        .first()
                }
                call.respond(result)
            } catch (e: Exception) {
                call.respond(HttpStatusCode.InternalServerError)
            }
        }

        get("/fibonacci") {
            fun fib(n: Int): Int {
                if (n <= 1) {
                    return n
                } else {
                    return fib(n - 1) + fib(n - 2)
                }
            }
            call.respond(fib(40))
        }
    }
}
