    //
    //  ContentView.swift
    //  Omi
    //
    //  Created by Leonardo Gonçalves da Silva on 14/08/26.
    //

import SwiftUI
import CoreData

struct ContentView: View {
    // É o contexto do Persistence, lida com a persistência no CoreData
    @Environment(\.managedObjectContext) private var context
    
    // Faz o request do que está salvo no banco a partir de, no caso, .dataCriacao e quem recebe o resultado é a var receitas.
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \Receita.dataCriacao,
                ascending: false
            )
        ]
    )
    private var receitas: FetchedResults<Receita>
            
    @State private var mostrarForm: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(receitas) { receita in
                    NavigationLink {
                        // CRIAR DetalheReceitaView(receita: receita)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(receita.titulo ?? "Sem título")
                                .font(.headline)
                                .bold()
                            
                            Text(receita.descricao ?? "Vazio")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
                .onDelete(perform: deletarReceita)
            }
            .navigationTitle("Receitas")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button{
                        mostrarForm.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $mostrarForm) {
                        CriarReceitaView(
                            viewModel: CriarReceitaViewModel(
                                repo: ReceitasRepo(
                                    context: context
                                )
                            )
                        )
                    }
                }
            }
        }
    }
    
    private func deletarReceita(at offsets: IndexSet) {
        // Cria a variável repo que recebe o ReceitasRepo e o contexto em questão - que é o do Persistence
        // ReceitasRepo cuida de operações da entidade Receita no CoreData
        let repo = ReceitasRepo(context: context)
        offsets.map{ receitas[$0] }
            .forEach { receita in
                do {
                    try repo.deletarReceita(receita: receita)
                } catch {
                    print("ERRO AO DELETAR RECEITA: \(error.localizedDescription)")
                }
            }
    }
}

#Preview {
    // recebe o .preview que é uma inicialização em ambiente controlado, ambiente de pre-visualização. Em ambiente de produção/buildado o banco tem outros elementos.
    ContentView()
        .environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext
        )
}
