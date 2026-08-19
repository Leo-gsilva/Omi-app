////
////  LivroReceitasViewSimples.swift
////  Omi
////
////  Created by Igor Carrasco on 19/08/26.
////
//
import SwiftUI
import CoreData

struct LivroReceitasViewSimples: View {
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \Receita.titulo,
                ascending: true
            )
        ]
    )
    private var receitas: FetchedResults<Receita>
    
    @State private var categoriaSelecionada = "Sobremesa"

    private let categorias = ["sobremesa", "salgado", "bebida", "massa", "lanche"]
    
    private var receitasFiltradas: [Receita] {
        receitas.filter{
            $0.categoria == categoriaSelecionada
        }
    }

    
    var body: some View {
//        Picker("Categoria", selection: $categoria) {
//            ForEach(categorias, id: \.self) { categoria in
//                Text(categoria).tag(categoria)
//            }
//        }
//        .pickerStyle(.segmented)
        
        TabView {
            ForEach(receitasFiltradas) { receita in
                ReceitaPageView(
                    receita: receita
                )
            }
        }
        .tabViewStyle(.page)
    }
}

#Preview {
    LivroReceitasViewSimples()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
