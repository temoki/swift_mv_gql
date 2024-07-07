import Apollo
import Combine
import Dependencies
import SWGraphQL

public typealias Film = GraphQL.AllFilmsQuery.Data.AllFilms.Film

@MainActor
public protocol AllFilmsModelProtocol: ObservableObject {
    var films: [Film] { get }
    func load()
}

public class AllFilmsModel: AllFilmsModelProtocol {
    @Dependency(\.apolloClient) var apolloClient
    
    @Published public private(set) var films: [Film] = []
    
    public func load() {
        Task {
            do {
                let query = GraphQL.AllFilmsQuery()
                let result = try await apolloClient.returnCacheDataElseFetch(query: query)
                if let data = result.data {
                    films = data.allFilms?.films?.compactMap { $0 } ?? []
                } else if let errors = result.errors {
                    print(errors)
                }
            } catch {
                print(error)
            }
        }
        .eraseToAnyCancellable()
        .store(in: &cancellables)
    }
    
    // MARK: - Private
    
    private var cancellables: Set<AnyCancellable> = []
}
