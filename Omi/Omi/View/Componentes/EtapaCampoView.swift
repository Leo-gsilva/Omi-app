//
//  EtapaCampoView\.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 23/08/26.
//

import SwiftUI

struct EtapaCampoView: View {
    let numero: Int
    @Binding var texto: String

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            Text("Etapa \(numero):")
                .font(FontesApp.corpo)
                .foregroundStyle(.cordosTextos)

            TextField("Ex: Misture os ovos e a manteiga", text: $texto, axis: .vertical)
                .font(FontesApp.corpo)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.corFundoCapsula))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
#Preview {
    EtapaCampoView(numero: 1, texto: .constant(""))
}
