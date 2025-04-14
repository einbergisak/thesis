import kotlinx.serialization.Serializable
import org.jetbrains.exposed.dao.id.UUIDTable
import java.util.*

@Serializable
data class DBRow(
    val name: String,
    val id: String,
)

object DBTable : UUIDTable("tableone") {
    val name = varchar("name", 255)
}
