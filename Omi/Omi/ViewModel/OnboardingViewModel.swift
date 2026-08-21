//
//  OnboardingViewModel.swift
//  Omi
//
//  Created by Guilherme Alves de Souza on 16/08/26.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class OnboardingViewModel {
    var postitAtivo: Int? = nil
    var paginaAtual: Int = 0
    var finalizado: Bool = false
    
    let totalDePaginas = 5
    
    let paginas: [OnboardingModel] = [
        OnboardingModel(
            titulo: "O que o app faz?",
            descricao: "Esse é o seu ",
            palavraDestaque: "álbum \nde receitas.",
            palavraDestaque2: nil,
            imagem: "AlbumOnboarding"
            
        ),
        
        OnboardingModel(
            titulo: "Crie categorias",
            descricao: "Organize suas receitas,\n por ",
            palavraDestaque: "categorias ",
            palavraDestaque2: "etiquetas.",
            imagem: "Albumcortadoonboarding"
        ),
        
        OnboardingModel(
            titulo: "Adicione Receitas",
            descricao: "Você pode ",
            palavraDestaque: "adicionar novas receitas",
            palavraDestaque2: " para seu álbum.",
            imagem: "ImageAdicionarpag3"
        ),
        
        OnboardingModel(
            titulo: "Edite suas receitas",
            descricao: "No botão Editar, você pode  no álbum.   ",
            palavraDestaque: "mudar suas receitas",
            palavraDestaque2: nil,
            imagem: "Editarpag4",
        ),
        
        OnboardingModel(
            titulo: "Veja sua receitas ",
            descricao:"na sua\n receita, você pode\n",
            palavraDestaque: "tocar ",
            palavraDestaque2: "vê-la com\n mais detalhes.",
            imagem: "livropag5"
        )
    ]
    
//    var totalDePaginas: Int {
//        paginas.count
//    }
    
    var paginaAtualModel: OnboardingModel {
        paginas[paginaAtual]
    }
    
    func continuar() {
        if paginaAtual < totalDePaginas - 1 {
            paginaAtual += 1
        } else {
            finalizado = true
        }
    }
    
    func voltar() {
        guard paginaAtual > 0 else { return }
        
        paginaAtual -= 1
    }
    
    func iniciarAnimacaoPostIts() async {
        
        while !Task.isCancelled {
            
            for index in 0..<5 {
                
                withAnimation(.easeInOut(duration: 0.35)) {
                    postitAtivo = index
                }
                
                try? await Task.sleep(for: .milliseconds(500))
                
                withAnimation(.easeInOut(duration: 0.35)) {
                    postitAtivo = nil
                }
                
                try? await Task.sleep(for: .milliseconds(150))
            }
        }
    }
    
    private func finalizarOnboarding() {
        finalizado = true
        print("Onboarding finalizado")
    }
}
