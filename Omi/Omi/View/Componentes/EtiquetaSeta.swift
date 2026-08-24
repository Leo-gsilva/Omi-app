//
//  EtiquetaSeta.swift
//  Omi
//
//  Created by Leonardo Gonçalves da Silva on 23/08/26.
//
import SwiftUI

struct EtiquetaSeta: Shape {
    func path(in rect: CGRect) -> Path {
        let ponta = rect.height / 2
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width - ponta, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height / 2))
        path.addLine(to: CGPoint(x: rect.width - ponta, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

