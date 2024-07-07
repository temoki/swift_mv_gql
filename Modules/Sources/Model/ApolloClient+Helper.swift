import Apollo
import ApolloAPI
import Foundation

extension ApolloClient {
    func returnCacheDataElseFetch<Query: GraphQLQuery>(
        query: Query,
        contextIdentifier: UUID? = nil,
        queue: DispatchQueue = .main
    ) async throws -> GraphQLResult<Query.Data> {
        for try await result in resultStream(query, .returnCacheDataElseFetch, contextIdentifier, queue).prefix(1) {
            return result
        }
        fatalError("Only one result always returns")
    }
    
    func fetchIgnoringCacheData<Query: GraphQLQuery>(
        query: Query,
        contextIdentifier: UUID? = nil,
        queue: DispatchQueue = .main
    ) async throws -> GraphQLResult<Query.Data> {
        for try await result in resultStream(query, .fetchIgnoringCacheData, contextIdentifier, queue).prefix(1) {
            assert(result.source == .server)
            return result
        }
        fatalError("Only one result always returns")
    }
    
    func fetchIgnoringCacheCompletely<Query: GraphQLQuery>(
        query: Query,
        contextIdentifier: UUID? = nil,
        queue: DispatchQueue = .main
    ) async throws -> GraphQLResult<Query.Data> {
        for try await result in resultStream(query, .fetchIgnoringCacheCompletely, contextIdentifier, queue).prefix(1) {
            assert(result.source == .server)
            return result
        }
        fatalError("Only one result always returns")
    }
    
    func returnCacheDataDontFetch<Query: GraphQLQuery>(
        query: Query,
        contextIdentifier: UUID? = nil,
        queue: DispatchQueue = .main
    ) async throws -> GraphQLResult<Query.Data> {
        for try await result in resultStream(query, .returnCacheDataDontFetch, contextIdentifier, queue).prefix(1) {
            assert(result.source == .cache)
            return result
        }
        fatalError("Only one result always returns")
    }
    
    func returnCacheDataAndFetch<Query: GraphQLQuery>(
        query: Query,
        contextIdentifier: UUID? = nil,
        queue: DispatchQueue = .main
    ) -> AsyncThrowingStream<GraphQLResult<Query.Data>, Error> {
        return resultStream(query, .returnCacheDataAndFetch, contextIdentifier, queue)
    }
    
    // MARK: - Private    

    private func resultStream<Query: GraphQLQuery>(
        _ query: Query,
        _ cachePolicy: CachePolicy,
        _ contextIdentifier: UUID?,
        _ queue: DispatchQueue
    ) -> AsyncThrowingStream<GraphQLResult<Query.Data>, Error> {
        AsyncThrowingStream { continuation in
            let cancellation = fetch(
                query: query,
                cachePolicy: cachePolicy,
                contextIdentifier: contextIdentifier,
                queue: queue
            ) { response in
                switch response {
                case .success(let result):
                    continuation.yield(result)
                    
                    switch (cachePolicy, result.source) {
                    case (.returnCacheDataElseFetch, _),
                        (.fetchIgnoringCacheData, .server),
                        (.fetchIgnoringCacheCompletely, .server),
                        (.returnCacheDataAndFetch, .server),
                        (.returnCacheDataDontFetch, .cache):
                        continuation.finish()
                    default:
                        break
                    }

                case .failure(let error):
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in
                cancellation.cancel()
            }
        }
    }
}
