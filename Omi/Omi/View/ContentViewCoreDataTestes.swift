//
//  ContentView.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 14/08/26.
//

import SwiftUI
import SwiftData

struct ContentViewCoreDataTestes: View {
    // É o contexto do Persistence, lida com a persistência no CoreData
    @Environment(\.modelContext) private var contexto
    
    @State private var mostrarForm: Bool = false
        
    var body: some View {
        NavigationStack {
            VStack{
                LivroReceitasViewSimples(viewModel: LivroReceitasViewModel(repo: ReceitaRepositorioSwiftData(context: contexto)))
            }
            .navigationTitle("Minhas Receitas")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button{
                        mostrarForm.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $mostrarForm) {
                        CriarReceitaView(viewModel: CriarReceitaViewModel(repo: ReceitaRepositorioSwiftData(context: contexto)))
                    }
                }
            }
        }
    }
}

#Preview {
    // recebe o .preview que é uma inicialização em ambiente controlado, ambiente de pre-visualização. Em ambiente de produção/buildado o banco tem outros elementos.
    ContentViewCoreDataTestes()
        .modelContainer(PersistenceSwiftData.container)

}
