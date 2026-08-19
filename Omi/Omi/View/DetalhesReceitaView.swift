//
//  DetalhesReceitaView.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import SwiftUI

struct DetalhesReceitaView: View {
    @State var receita: Receita
    
    var body: some View {
        Text(receita.titulo ?? "")
    }
}

//#Preview {
//    DetalhesReceitaView()
//}
