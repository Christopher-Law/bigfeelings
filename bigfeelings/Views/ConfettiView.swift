//
//  ConfettiView.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import SwiftUI

struct ConfettiView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Only create emitter if one doesn't already exist
        guard uiView.layer.sublayers?.first(where: { $0 is CAEmitterLayer }) == nil else {
            return
        }
        
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: uiView.bounds.width / 2, y: -10)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: uiView.bounds.width, height: 1)
        
        let colors: [UIColor] = [
            UIColor(red: 0.06, green: 0.73, blue: 0.51, alpha: 1.0), // #10B981
            UIColor(red: 0.20, green: 0.83, blue: 0.60, alpha: 1.0), // #34D399
            UIColor(red: 0.43, green: 0.91, blue: 0.72, alpha: 1.0), // #6EE7B7
            UIColor(red: 0.65, green: 0.95, blue: 0.82, alpha: 1.0)  // #A7F3D0
        ]
        
        var cells: [CAEmitterCell] = []
        
        for color in colors {
            let cell = CAEmitterCell()
            cell.birthRate = 3
            cell.lifetime = 3.0
            cell.velocity = 100
            cell.velocityRange = 50
            cell.emissionRange = .pi / 4
            cell.spin = 3.5
            cell.spinRange = 1.0
            cell.scaleRange = 0.25
            cell.scale = 0.1
            cell.contents = createConfettiImage(color: color).cgImage
            cells.append(cell)
        }
        
        emitter.emitterCells = cells
        uiView.layer.addSublayer(emitter)
        
        // Remove after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            emitter.removeFromSuperlayer()
        }
    }
    
    private func createConfettiImage(color: UIColor) -> UIImage {
        let size = CGSize(width: 10, height: 10)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
    }
}

