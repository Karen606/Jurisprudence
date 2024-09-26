//
//  MaterialViewController.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 26.09.24.
//

import UIKit
import Combine

class MaterialViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: BaseTextView!
    @IBOutlet weak var saveButton: UIButton!
    private let menuButton = UIButton(type: .custom)
    private let backButton = UIButton(type: .custom)
    private var cancellables: Set<AnyCancellable> = []
    private let viewModel = MaterialViewModel.shared
    var completion: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
        descriptionTextView.placeholder = "Description"
    }
    
    func setupUI() {
        menuButton.setImage(UIImage(named: "Menu"), for: .normal)
        menuButton.addTarget(self, action: #selector(clickedMenu), for: .touchUpInside)
        backButton.setImage(UIImage(named: "Back"), for: .normal)
        backButton.addTarget(self, action: #selector(clickedBack), for: .touchUpInside)

        self.setNavigationBar(leftButton: backButton, rightButton: menuButton)
        titleTextField.font = .regularMulish(size: 28)
        descriptionTextView.baseDelegate = self
        titleTextField.delegate = self
        self.titleTextField.text = viewModel.material?.title
        self.descriptionTextView.text = viewModel.material?.info
    }
    
    @objc func clickedMenu() {
        if let menuVC = navigationController?.viewControllers.first(where: { $0 is MenuViewController }) {
            self.navigationController?.popToViewController(menuVC, animated: true)
        }
    }
    
    @objc func clickedBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleTapGesture(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
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
    
    func subscribe() {
        viewModel.$material
            .receive(on: DispatchQueue.main)
            .sink { [weak self] material in
                guard let self = self else { return }
                let titleText = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                let infoText = descriptionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                saveButton.isEnabled = (!(titleText?.isEmpty ?? false) && !(infoText?.isEmpty ?? false))
            }
            .store(in: &cancellables)
    }
}

extension MaterialViewController: UITextFieldDelegate, BaseTextViewDelegate {
    func didChancheSelection(_ textView: UITextView) {
        viewModel.material?.info = textView.text
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        viewModel.material?.title = textField.text ?? ""
    }
}
