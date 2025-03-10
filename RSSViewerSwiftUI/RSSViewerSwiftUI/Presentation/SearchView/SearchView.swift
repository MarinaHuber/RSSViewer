//
//  SearchView.swift
//  RSSViewerSwiftUI
//
//  Created by Marina Huber on 18.02.2025..
//

import SwiftUI
import SceneKit

// Custom styled TextField with blurred background
struct SearchView: View {
    @Binding var rssURL: String

    var body: some View {
        VisualEffectBlur(blurStyle: .systemChromeMaterialDark) // Blurred background
            .frame(width: UIScreen.main.bounds.width * 0.8, height: 54)
            .cornerRadius(100)
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )

        TextField("Insert RSS URL...", text: $rssURL)
            .textInputAutocapitalization(.never)
            .foregroundColor(.white)
            .font(.system(size: 14))
            .padding(.leading, 10)
            .frame(width: UIScreen.main.bounds.width * 0.8, height: 54)
    }
}

 // actor model automatically handles synchronization and ensures that methods are executed serially.
actor TextureGenerator {
    static let shared = TextureGenerator()

    func generateTexture() async -> UIImage {
        return createTextTexture()
    }

    private func createTextTexture() -> UIImage {
            // Reduced size texture for better performance
        let size = CGSize(width: 512, height: 256)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { ctx in
                // Fill background with black
            let rectangle = CGRect(origin: .zero, size: size)
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fill)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left

                // Draw random characters
            for _ in 0..<700 {
                let randomString = String((0..<1).map{ _ in "rssRSS".randomElement()! })
                let randomX = CGFloat.random(in: 0..<size.width)
                let randomY = CGFloat.random(in: 0..<size.height)
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .paragraphStyle: paragraphStyle,
                    .foregroundColor: UIColor.white.withAlphaComponent(Bool.random() ? 0.1 : 1.0)
                ]
                randomString.draw(with: CGRect(x: randomX, y: randomY, width: 15, height: 15), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
            }
        }
    }
}

struct GlobeView: UIViewRepresentable {
    @MainActor
    class Coordinator: NSObject {
        var animationTask: Task<Void, Never>?
        var isGeneratingTexture = false
        weak var sceneView: SCNView?

        deinit {
            animationTask?.cancel()
        }

        func startTextureUpdates() {
            animationTask?.cancel()

            animationTask = Task { [weak self] in
                while !Task.isCancelled {
                    await self?.updateTexture()

                    try? await Task.sleep(nanoseconds: 250_000_000) // 0.25 seconds
                }
            }
        }

        func updateTexture() async {
            guard let sceneView = sceneView, !isGeneratingTexture else { return }

            isGeneratingTexture = true

            let newTexture = await TextureGenerator.shared.generateTexture()

            await MainActor.run {
                sceneView.scene?.rootNode.childNodes.first?.geometry?.firstMaterial?.diffuse.contents = newTexture
                isGeneratingTexture = false
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = createGlobeScene()
        scnView.backgroundColor = UIColor.black
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true
        scnView.frame = UIScreen.main.bounds

        context.coordinator.sceneView = scnView

        context.coordinator.startTextureUpdates()

        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
            // Update logic if needed
    }

    private func createGlobeScene() -> SCNScene {
        let scene = SCNScene()
        let globeNode = SCNNode(geometry: SCNSphere(radius: 1.0))
        globeNode.position = SCNVector3(x: 0, y: 0, z: 0)

        let material = SCNMaterial()
        globeNode.geometry?.materials = [material]

            // Use Task to load the initial texture
        Task { @MainActor in
            let initialTexture = await TextureGenerator.shared.generateTexture()
            material.diffuse.contents = initialTexture
        }

        scene.rootNode.addChildNode(globeNode)
        return scene
    }
}


// VisualEffectBlur
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

