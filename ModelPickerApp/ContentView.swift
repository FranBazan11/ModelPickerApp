//
//  ContentView.swift
//  ModelPickerApp
//
//  Created by Juan Bazan Carrizo on 27/01/2023.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    //    var models: [String] = ["sneaker_pegasustrail", "sneaker_airforce" ]
    
    @State var isPlacementEnabled = false
    @State var selectedModel: Model?
    @State var modelConfirmedForPlacement: Model?
    
    var models: [Model] = {
        let filemanager = FileManager.default
        
        guard let path = Bundle.main.resourcePath,
              let files = try? filemanager.contentsOfDirectory(atPath: path) else { return [] }
        
        var availableModels: [Model] = []
        
        for filename in files where filename.hasSuffix("usdz") {
            let modelName = filename.replacingOccurrences(of: ".usdz", with: "")
            let model = Model(modelName: modelName)
            availableModels.append(model)
        }
        
        return availableModels
    }()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(modelConfirmedForPlacement: $modelConfirmedForPlacement)
            if isPlacementEnabled {
                PlacementButtonsView(isPlacementEnabled: $isPlacementEnabled, selectedModel: $selectedModel, modelConfirmedForPlacement: $modelConfirmedForPlacement)
            } else {
                ModelPickerView(isPlacementEnabled: $isPlacementEnabled, selectedModel: $selectedModel, models: models)
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedForPlacement: Model?
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        arView.session.run(config)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let model = modelConfirmedForPlacement {
            
            if let modelEntity = model.modelEntity {
                let anchorEntity = AnchorEntity(plane: .any)
                anchorEntity.addChild(modelEntity.clone(recursive: true))
                uiView.scene.addAnchor(anchorEntity)
            }
            
            DispatchQueue.main.async {
                modelConfirmedForPlacement = nil
            }
        }
    }
}
// MARK: - ModelPickerView
struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    var models: [Model]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(0 ..< models.count) { index in
                    Button {
                        print("My model is \(models[index])")
                        selectedModel = models[index]
                        isPlacementEnabled = true
                    } label: {
                        Image(models[index].modelName)
                            .resizable()
                            .scaledToFit()
                            .frame(height:150)
                            .background(.white)
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .background(.gray.opacity(0.7))
        
    }
}

struct PlacementButtonsView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    @Binding var modelConfirmedForPlacement: Model?
    
    var body: some View {
        HStack {
            Button {
                print("CANCEL")
                isPlacementEnabled = false
                selectedModel = nil
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60, alignment: .center)
                    .font(.title)
                    .background(.white.opacity(0.75))
                    .padding()
                    .cornerRadius(30)
            }
            
            Button {
                print("CONFIRM")
                modelConfirmedForPlacement = selectedModel
                
                isPlacementEnabled = false
                selectedModel = nil
            } label: {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60, alignment: .center)
                    .font(.title)
                    .background(.white.opacity(0.75))
                    .padding()
                    .cornerRadius(30)
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
