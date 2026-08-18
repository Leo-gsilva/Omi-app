//
//  ContentView.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 14/08/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    // Just use @State! The new macro handles everything else.
    @State private var viewModel = IngredientesViewModel(repo: ReceitasRepo(context: PersistenceController.shared.container.viewContext))
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
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
