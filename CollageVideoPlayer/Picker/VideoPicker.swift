//
//  ImagePicker.swift
//  CollageVideoPlayer
//
//  Created by Sheharyar on 25/03/2025.
//

import SwiftUI
import PhotosUI

struct VideoPicker: UIViewControllerRepresentable {
    @Binding var selectedURL: URL?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .videos
        configuration.selectionLimit = 1 // Limit to single selection
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: VideoPicker

        init(_ parent: VideoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }

            // Check if the item is a video
            if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                    if let url = url {
                        // Create a copy of the video to a temporary directory
                        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                        
                        do {
                            // Remove existing file if it exists
                            try? FileManager.default.removeItem(at: tmpURL)
                            
                            // Copy the video to temp directory
                            try FileManager.default.copyItem(at: url, to: tmpURL)
                            
                            DispatchQueue.main.async {
                                self.parent.selectedURL = tmpURL
                            }
                        } catch {
                            print("Error copying video: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}
