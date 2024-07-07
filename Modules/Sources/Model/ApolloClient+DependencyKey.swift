import Apollo
import ApolloAPI
import Dependencies
import Foundation

extension ApolloClient: DependencyKey {
    public static let liveValue = ApolloClient(
        url: URL(string: "https://swapi-graphql.netlify.app/.netlify/functions/index")!
    )
}

extension DependencyValues {
    public var apolloClient: ApolloClient {
        get { self[ApolloClient.self] }
        set { self[ApolloClient.self] = newValue }
    }
}
