import Apollo
import Foundation

extension ApolloClient {
    public func fetch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .default,
        contextIdentifier: UUID? = nil,
        queue: DispatchQueue = .main
    ) -> AsyncThrowingStream<GraphQLResult<Query.Data>, Error> {
        AsyncThrowingStream { continuation in
            let request = fetch(
                query: query,
                cachePolicy: cachePolicy,
                contextIdentifier: contextIdentifier,
                queue: queue
            ) { response in
                switch response {
                case .success(let result):
                    continuation.yield(result)
                    
                    switch cachePolicy {
                    case .returnCacheDataElseFetch:
                        continuation.finish()
                        
                    case .fetchIgnoringCacheData, .fetchIgnoringCacheCompletely, .returnCacheDataAndFetch:
                        if result.source == .server {
                            continuation.finish()
                        }
                        
                    case .returnCacheDataDontFetch:
                        if result.source == .cache {
                            continuation.finish()
                        }
                    }
                    
                case .failure(let error):
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in request.cancel() }
        }
    }
}
