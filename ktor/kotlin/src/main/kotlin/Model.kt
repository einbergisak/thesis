import kotlinx.serialization.Serializable
import org.jetbrains.exposed.sql.Table


@Serializable
data class Movie(
    val film_id: Int,
    val title: String,
    val description: String,
)


object FilmTable : Table("film") {
    val film_id = integer("film_id")
    val title = varchar("title", 255)
    val description = varchar("description", 255)
}
