    //
    //  ContentView.swift
    //  Omi
    //
    //  Created by Leonardo Gonçalves da Silva on 14/08/26.
    //

import SwiftUI
import CoreData

struct ContentViewCoreDataTestes: View {
    // É o contexto do Persistence, lida com a persistência no CoreData
    @Environment(\.managedObjectContext) private var contexto
    
    // Faz o request do que está salvo no banco a partir de, no caso, .dataCriacao e quem recebe o resultado é a var receitas.
//    @FetchRequest(
//        sortDescriptors: [
//            NSSortDescriptor(keyPath: \Receita.dataCriacao, ascending: true)
//        ]
//    )
//    private var receitas: FetchedResults<Receita>
    
//    @State private var paginaAtual: Int = 0
    @State private var mostrarForm: Bool = false
    
    //let receita = receitas[paginaAtual]
    
    var body: some View {
        NavigationStack {
            LivroReceitasViewSimples(viewModel: LivroReceitasViewModel(repo: ReceitaRepositorioCoreData(context: contexto)))
                .navigationTitle("Minhas Receitas")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button{
                            mostrarForm.toggle()
                        } label: {
                            Image(systemName: "plus")
                        }
                        .sheet(isPresented: $mostrarForm) {
                            CriarReceitaView(viewModel: CriarReceitaViewModel(repo: ReceitaRepositorioCoreData(context: contexto)))
                        }
                    }
                }
        }
    }
}

#Preview {
    // recebe o .preview que é uma inicialização em ambiente controlado, ambiente de pre-visualização. Em ambiente de produção/buildado o banco tem outros elementos.
    ContentViewCoreDataTestes()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
