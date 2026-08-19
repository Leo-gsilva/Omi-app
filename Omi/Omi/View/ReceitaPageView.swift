//
//  ReceitaPageView.swift
//  Omi
//
//  Created by Igor Carrasco on 19/08/26.
//

import SwiftUI
import CoreData

struct ReceitaPageView: View {
    let receita: Receita
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 20) {
                Text(receita.titulo ?? "")
                    .font(.largeTitle)
                    .bold()
                
                Text(receita.descricao ?? "")
                
                Divider()
                
                Text("Tempo: \(receita.tempoDePreparo) min")
                Text("Porções: \(receita.porcoes ?? "")")
                Text("Categoria: \(receita.categoria ?? "")")
            }
            .padding()
        }
    }
}

#Preview {
    let context =
        PersistenceController.preview
            .container
            .viewContext

    let receita = Receita(context: context)

    receita.id = UUID()
    receita.titulo = "Bolo de Cenoura"
    receita.descricao = """
    Receita de teste para Preview.
    """
    receita.categoria = "Sobremesas"
    receita.porcoes = "8"
    receita.tempoDePreparo = 45

    return ReceitaPageView(
        receita: receita
    )
}
