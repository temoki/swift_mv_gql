import Apollo
import Combine
import Dependencies
import SWGraphQL

@MainActor
public class AllFilmsModel: ObservableObject {
    @Dependency(\.apolloClient) var apolloClient
    public typealias Film = GraphQL.AllFilmsQuery.Data.AllFilms.Film
    
    @Published public private(set) var films: [Film] = []
    @Published public private(set) var graphQlErrors: [GraphQLError] = []
    @Published public private(set) var error: Error?
    
    public init() {
        update()
    }
    
    public func update() {
        Task {
            do {
                graphQlErrors = []
                error = nil
                for try await result in apolloClient.returnCacheDataAndFetch(query: GraphQL.AllFilmsQuery()) {
                    if let data = result.data {
                        films = data.allFilms?.films?.compactMap { $0 } ?? []
                    } else if let errors = result.errors {
                        graphQlErrors = errors
                    }
                }
            } catch {
                self.error = error
            }
        }
        .eraseToAnyCancellable()
        .store(in: &cancellables)
    }
    
    // MARK: - Private
    
    private var cancellables: Set<AnyCancellable> = []
}
