//
//  DocumentViewController.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 26.09.24.
//

import UIKit
import Combine
import PhotosUI

class DocumentViewController: UIViewController {

    @IBOutlet weak var nameLabel: PaddingLabel!
    @IBOutlet var bottomButton: [UIButton]!
    @IBOutlet weak var folderButton: UIButton!
    @IBOutlet weak var documentImageView: UIImageView!
    private let viewModel = DocumentViewModel.shared
    private var cancellables: Set<AnyCancellable> = []
    private let menuButton = UIButton(type: .custom)
    private let backButton = UIButton(type: .custom)
    var completion: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
    }
    
    func setupUI() {
        menuButton.setImage(UIImage(named: "Menu"), for: .normal)
        menuButton.addTarget(self, action: #selector(clickedMenu), for: .touchUpInside)
        backButton.setImage(UIImage(named: "Back"), for: .normal)
        backButton.addTarget(self, action: #selector(clickedBack), for: .touchUpInside)

        self.setNavigationBar(leftButton: backButton, rightButton: menuButton)

        bottomButton.forEach { button in
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.1
            button.layer.shadowOffset = CGSize(width: 0, height: 4)
            button.layer.shadowRadius = 4
            button.layer.masksToBounds = false
            button.layer.cornerRadius = 10
        }
    }
    
    func subscribe() {
        viewModel.$document
            .receive(on: DispatchQueue.main)
            .sink { [weak self] document in
                guard let self = self else { return }
                self.nameLabel.text = document?.name
                if let data = document?.content, let image = UIImage(data: data) {
                    folderButton.isHidden = true
                    self.documentImageView.image = image
                } else {
                    folderButton.isHidden = false
                    self.documentImageView.image = nil
                }
            }
            .store(in: &cancellables)
    }
    
    private func choosePhoto() {
        let actionSheet = UIAlertController(title: "Select Image", message: "Choose a source", preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.requestCameraAccess()
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.requestPhotoLibraryAccess()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func clickedMenu() {
        if let menuVC = navigationController?.viewControllers.first(where: { $0 is MenuViewController }) {
            self.navigationController?.popToViewController(menuVC, animated: true)
        }
    }
    
    @objc func clickedBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleTapGestureDocument(_ sender: UITapGestureRecognizer) {
        choosePhoto()
    }
    
    @IBAction func clickedFolderButton(_ sender: UIButton) {
        choosePhoto()
    }
    
    @IBAction func clickedCancel(_ sender: UIButton) {
        viewModel.document = nil
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickedSave(_ sender: UIButton) {
        viewModel.save { [weak self] success in
            guard let self = self else { return }
            if success {
                self.completion?()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    deinit {
        viewModel.document = nil
    }
}

extension DocumentViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func requestCameraAccess() {
            let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
            switch cameraStatus {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.openCamera()
                    }
                }
            case .authorized:
                openCamera()
            case .denied, .restricted:
                showSettingsAlert()
            @unknown default:
                break
            }
        }
        
        private func requestPhotoLibraryAccess() {
            let photoStatus = PHPhotoLibrary.authorizationStatus()
            switch photoStatus {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { status in
                    if status == .authorized {
                        self.openPhotoLibrary()
                    }
                }
            case .authorized:
                openPhotoLibrary()
            case .denied, .restricted:
                showSettingsAlert()
            case .limited:
                break
            @unknown default:
                break
            }
        }
        
        private func openCamera() {
            DispatchQueue.main.async {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .camera
                    imagePicker.allowsEditing = true
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
        }
        
        private func openPhotoLibrary() {
            DispatchQueue.main.async {
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.allowsEditing = true
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
        }
        
        private func showSettingsAlert() {
            let alert = UIAlertController(title: "Access Needed", message: "Please allow access in Settings", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }))
            present(alert, animated: true, completion: nil)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                folderButton.setImage(editedImage, for: .normal)
            } else if let originalImage = info[.originalImage] as? UIImage {
                folderButton.setImage(originalImage, for: .normal)
            }
            folderButton.isHidden = true
            if let imageData = folderButton.imageView?.image?.jpegData(compressionQuality: 1.0) {
                let data = imageData as Data
                viewModel.document?.content = data
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
}
