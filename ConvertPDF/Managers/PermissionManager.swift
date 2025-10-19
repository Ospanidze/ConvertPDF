//
//  PermissionManager.swift
//  ConvertPDF
//
//  Created by Айдар Оспанов on 17.10.2025.
//

import Photos
import UIKit

enum PermissionType {
    case photoLibrary
}

enum PermissionStatus {
    case authorized
    case denied
    case notDetermined
}

final class PermissionManager {
    static let shared = PermissionManager()
    private init() {}
    func checkStatus(for type: PermissionType) -> PermissionStatus {
        switch type {
        case .photoLibrary:
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            switch status {
            case .authorized, .limited:
                return .authorized
            case .denied, .restricted:
                return .denied
            case .notDetermined:
                return .notDetermined
            @unknown default:
                return .denied
            }
        }
    }

    func requestPermission(for type: PermissionType, completion: @escaping (PermissionStatus) -> Void) {
        switch type {
        case .photoLibrary:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized, .limited:
                        completion(.authorized)
                    case .denied, .restricted:
                        completion(.denied)
                    case .notDetermined:
                        completion(.notDetermined)
                    @unknown default:
                        completion(.denied)
                    }
                }
            }
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
