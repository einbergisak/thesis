package com.example

import DBRow
import DBTable
import DBTable.id
import DBTable.name
import EchoData
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
        get("/lipsum") {
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
                val rows = transaction {
                    DBTable.selectAll().map { row ->
                        DBRow(row[DBTable.name], row[DBTable.id].toString())
                    }
                }
                call.respond(rows)
            } catch (e: Exception) {
                call.respondText("${e.message}", status = io.ktor.http.HttpStatusCode.InternalServerError)
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
