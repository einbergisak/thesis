import kotlinx.serialization.Serializable

@Serializable
data class EchoData(
    val message: String
)