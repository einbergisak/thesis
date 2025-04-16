import kotlinx.serialization.Serializable

@Serializable
data class EchoData(
    val id: Int,
    val message: String,
    val innerDataList: List<InnerData>
)

@Serializable
data class InnerData(
    val id: Int,
    val number: Double,
    val itemList: List<ListItem>
)

@Serializable
data class ListItem(
    val id: Int,
    val boolean: Boolean,
    val string: String,
)