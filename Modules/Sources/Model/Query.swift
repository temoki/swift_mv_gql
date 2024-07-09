import Apollo
import ApolloAPI
import Combine
import Dependencies
import Foundation

@MainActor
public class Query<Q: ApolloAPI.GraphQLQuery>: Combine.ObservableObject {
    @Combine.Published public private(set) var state: QueryState<Q.Data> = .initial
    
    public init(query: Q) {
        self.query = query
        self.update()
    }
    
    public func update() {
        Task {
            do {
                state = switch state {
                case .data(let data): .loading(data)
                case .loading(let previousData): .loading(previousData)
                default: .loading(nil)
                }
                
                for try await result in apolloClient.returnCacheDataAndFetch(query: query) {
                    switch result.source {
                    case .cache:
                        if let data = result.data {
                            state = .loading(data)
                        } else if let errors = result.errors {
                            assertionFailure(errors.description)
                        } else {
                            assertionFailure("Server result has neither data nor errors")
                        }
                        
                    case .server:
                        if let data = result.data {
                            state = .data(data)
                        } else if let errors = result.errors {
                            state = .error(.graphqlErrors(errors))
                        } else {
                            assertionFailure("Server result has neither data nor errors")
                        }
                    }
                }
            } catch {
                state = .error(.apolloError(error))
            }
        }
        .eraseToAnyCancellable()
        .store(in: &cancellables)
    }
    
    // MARK: - Private
    
    @Dependencies.Dependency(\.apolloClient) private var apolloClient
    private let query: Q
    private var cancellables: Set<Combine.AnyCancellable> = []
}

public enum QueryError: Error {
    case graphqlErrors([GraphQLError])
    case apolloError(Error)
}

public enum QueryState<Data> {
    case initial
    case loading(_ previous: Data?)
    case data(Data)
    case error(QueryError)
}

extension QueryState {
    public var isLoading: Bool {
        return switch self {
        case .loading: true
        default: false
        }
    }
    
    public var data: Data? {
        return switch self {
        case .data(let data): data
        case .loading(let data): data
        default: nil
        }
    }
    
    public var hasData: Bool {
        data != nil
    }
    
    public var error: Error? {
        return switch self {
        case .error(let error): error
        default: nil
        }
    }
    
    public var hasError: Bool {
        error != nil
    }
}
