//
//  WorksViewController.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 24.09.24.
//

import UIKit
import CoreData
import Combine

class WorksViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var worksTableView: UITableView!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var tableViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var nameTextField: BaseTextField!
    @IBOutlet weak var typeTextField: BaseTextField!
    @IBOutlet weak var dateTextField: BaseTextField!
    @IBOutlet weak var costTextField: BaseTextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    let menuButton = UIButton(type: .custom)
    private let viewModel = WorksViewModel.shared
    private var cancellables: Set<AnyCancellable> = []
    private var datePicker = UIDatePicker()
    private var isAdded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        worksTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        setupUI()
        subscribe()
        viewModel.fetchWorks()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if let newSize = change?[.newKey] as? CGSize {
                updateTableViewHeight(newSize: newSize)
            }
        }
    }
    
    private func updateTableViewHeight(newSize: CGSize) {
        tableViewHeightConst.constant = newSize.height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        if isAdded {
            scrollToBottom()
            isAdded = false
        }
    }
    
    func setupUI() {
        menuButton.setImage(UIImage(named: "Menu"), for: .normal)
        menuButton.addTarget(self, action: #selector(clickedMenu), for: .touchUpInside)
        self.setNavigationBar(leftButton: UIButton(), rightButton: menuButton)
        nameTextField.delegate = self
        typeTextField.delegate = self
        costTextField.delegate = self
        dateTextField.delegate = self
        dateTextField.inputView = datePicker
        datePicker.locale = NSLocale.current
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.addTarget(self, action: #selector(hourPickerValueChanged(sender:)), for: .valueChanged)
        worksTableView.delegate = self
        worksTableView.dataSource = self
        cancelButton.titleLabel?.font = .boldSFPro(size: 20)
        addButton.titleLabel?.font = .boldSFPro(size: 20)
        setShadow(buttons: [cancelButton, addButton])
        worksTableView.register(UINib(nibName: "WorkTableViewCell", bundle: nil), forCellReuseIdentifier: "WorkTableViewCell")
    }
    
    func setShadow(buttons: [UIButton]) {
        buttons.forEach { button in
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.1
            button.layer.shadowOffset = CGSize(width: 0, height: 4)
            button.layer.shadowRadius = 4
            button.layer.masksToBounds = false
            button.layer.cornerRadius = 10
        }
    }
    
    func subscribe() {
        viewModel.$works
            .receive(on: DispatchQueue.main)
            .sink { [weak self] works in
                guard let self = self else { return }
                self.worksTableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$workModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] workModel in
                guard let self = self else { return }
                self.addButton.isEnabled = !(workModel.name.isEmpty) && workModel.deadline != nil && !(workModel.type.isEmpty) && !(workModel.cost.isEmpty)
            }
            .store(in: &cancellables)
    }
    
    func scrollToBottom() {
        view.layoutIfNeeded()
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    @objc func hourPickerValueChanged(sender: UIDatePicker) {
        let date = sender.date
        let dateFormmater = DateFormatter()
        dateFormmater.locale = Locale.current
        dateFormmater.dateFormat = "MM/dd/yyyy"
        let formatedDate = dateFormmater.string(from: date)
        dateTextField.text = formatedDate
        viewModel.workModel.deadline = date
        datePicker.endEditing(true)
    }
    
    @objc func clickedMenu() {
        if let menuVC = navigationController?.viewControllers.first(where: { $0 is MenuViewController }) {
            self.navigationController?.popToViewController(menuVC, animated: true)
        }
    }
    
    @IBAction func clickedCancel(_ sender: UIButton) {
        self.addView.isHidden = true
        self.cancelButton.isHidden = true
        self.addButton.isHidden = true
    }
    
    @IBAction func clickedAdd(_ sender: UIButton) {
        viewModel.addWork()
        self.addView.isHidden = true
        self.cancelButton.isHidden = true
        self.addButton.isHidden = true
        isAdded = true
    }
    
    @IBAction func clickedAddWork(_ sender: UIButton) {
        self.addView.isHidden = false
        self.cancelButton.isHidden = false
        self.addButton.isHidden = false
        scrollToBottom()
    }
    
    deinit {
        worksTableView.removeObserver(self, forKeyPath: "contentSize")
    }
}

extension WorksViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.works.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkTableViewCell", for: indexPath) as! WorkTableViewCell
        cell.setupData(work: viewModel.works[indexPath.section])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
//        if viewModel.works.count - 1 == section {
//            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
//            let button = UIButton(type: .custom)
//            button.setTitle("Add", for: .normal)
//            button.frame = CGRect(x: (footerView.frame.width - 86) / 2, y: (footerView.frame.height - 42) / 2, width: 86, height: 42)
//            button.backgroundColor = .clear
//            button.setTitleColor(#colorLiteral(red: 0.5803921569, green: 0.6705882353, blue: 0.631372549, alpha: 1), for: .normal)
//            button.titleLabel?.font = .boldSFPro(size: 20)
//            button.setImage(UIImage(named: "Add"), for: .normal)
//            button.addTarget(self, action: #selector(createWork), for: .touchUpInside)
//            footerView.addSubview(button)
//            return footerView
//        } else {
//            return UIView()
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        16
//        return viewModel.works.count - 1 == section ? 50 : 16
    }
}

extension WorksViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        switch textField {
        case nameTextField:
            viewModel.workModel.name = textField.text ?? ""
        case typeTextField:
            viewModel.workModel.type = textField.text ?? ""
        case costTextField:
            viewModel.workModel.cost = textField.text ?? ""
        default:
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField == dateTextField ? false : true
    }
}
