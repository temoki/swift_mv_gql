import Model
import SwiftUI

public struct AllFilmsView: View {
    @StateObject private var model: AllFilmsModel = .init()
    
    public var body: some View {
        Text("films count = ")
    }
}

#Preview {
    AllFilmsView()
}
