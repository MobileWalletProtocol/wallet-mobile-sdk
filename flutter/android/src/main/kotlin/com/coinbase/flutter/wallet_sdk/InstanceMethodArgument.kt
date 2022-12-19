import kotlinx.serialization.Serializable

@Serializable
data class InstanceMethodArgument<T> {
    val wallet: Wallet
    val argument: T?
}

@Serializable
data class NoArgument {}
