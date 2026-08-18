    //
    //  ContentView.swift
    //  Omi
    //
    //  Created by Leonardo Gonçalves da Silva on 14/08/26.
    //

import SwiftUI
import CoreData

struct ContentView: View {
    // Just declare the State here. The init will handle assigning it!
    @State private var viewModel: IngredientesViewModel
    @State private var novoNomeIngrediente: String = ""

    // Inject the ViewModel
    init(viewModel: IngredientesViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Nome do ingrediente", text: $novoNomeIngrediente)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        viewModel.adicionar(nome: novoNomeIngrediente)
                        novoNomeIngrediente = ""
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                    .disabled(novoNomeIngrediente.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()
                
                List {
                    ForEach(viewModel.itens) { item in
                        Text(item.nome ?? "Sem nome")
                            .font(.system(.body, design: .rounded))
                    }
                    .onDelete(perform: viewModel.deletar)
                }
            }
            .navigationTitle("Ingredientes")
            .toolbar {
                // 1. Moved the EditButton to the left side
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                
                // 2. Added the NavigationLink to the right side
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        // We instantiate the new Repo and ViewModel for the next screen right here
                        let repoParaNovaTela = ReceitasRepo(context: PersistenceController.shared.container.viewContext)
                        let criarReceitaVM = CriarReceitaViewModel(repo: repoParaNovaTela)
                        
                        CriarReceitaView(viewModel: criarReceitaVM)
                    } label: {
                        // Using a cooking icon for the "Create Recipe" button!
                        Image(systemName: "frying.pan.fill")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
    }
}

#Preview {
    let previewContext = PersistenceController.preview.container.viewContext
        
    // 2. Create a repo using that preview context
    let previewRepo = ReceitasRepo(context: previewContext)
        
    // 3. Create the ViewModel using the preview repo
    let previewViewModel = IngredientesViewModel(repo: previewRepo)
        
    // 4. Inject it into the View!
    return ContentView(viewModel: previewViewModel)
}
