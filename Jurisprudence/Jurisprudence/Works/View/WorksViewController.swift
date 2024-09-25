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
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var worksTableView: UITableView!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var tableViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var nameTextField: BaseTextField!
    @IBOutlet weak var typeTextField: BaseTextField!
    @IBOutlet weak var dateTextField: BaseTextField!
    @IBOutlet weak var costTextField: PriceTextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet var textFields: [UITextField]!
    
    let menuButton = UIButton(type: .custom)
    private let viewModel = WorksViewModel.shared
    private var cancellables: Set<AnyCancellable> = []
    private var datePicker = UIDatePicker()
    private var isAdded = false
    private let dropDownView = UIView()
    private let stackView = UIStackView()
    private let tapGesture = UITapGestureRecognizer()
    private var completion: ((String?) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        worksTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        registerKeyboardNotifications()
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
        stackView.axis = .vertical
        stackView.frame.size = CGSize(width: 101, height: 60)
        stackView.distribution = .fillEqually
        stackView.backgroundColor = #colorLiteral(red: 0.5411764706, green: 0.1490196078, blue: 0.1490196078, alpha: 1)
        stackView.layer.cornerRadius = 4
        stackView.layer.shadowColor = UIColor.black.cgColor
        stackView.layer.shadowOpacity = 0.1
        stackView.layer.shadowOffset = CGSize(width: 0, height: 4)
        stackView.layer.shadowRadius = 4
        stackView.layer.masksToBounds = false
        
        let inProcessButton = UIButton(frame: CGRect(x: 0, y: 0, width: 101, height: 18))
        let completed = UIButton(frame: CGRect(x: 0, y: 0, width: 101, height: 18))
        let delay = UIButton(frame: CGRect(x: 0, y: 0, width: 101, height: 18))
        inProcessButton.setTitle("in process", for: .normal)
        inProcessButton.titleLabel?.font = .lightMulish(size: 14)
        inProcessButton.tag = 1
        inProcessButton.addTarget(self, action: #selector(chooseStatus(sender: )), for: .touchUpInside)
        completed.setTitle("completed", for: .normal)
        completed.titleLabel?.font = .lightMulish(size: 14)
        completed.tag = 2
        completed.addTarget(self, action: #selector(chooseStatus(sender: )), for: .touchUpInside)
        delay.setTitle("delay", for: .normal)
        delay.titleLabel?.font = .lightMulish(size: 14)
        delay.tag = 3
        delay.addTarget(self, action: #selector(chooseStatus(sender: )), for: .touchUpInside)
        stackView.addArrangedSubview(inProcessButton)
        stackView.addArrangedSubview(completed)
        stackView.addArrangedSubview(delay)
        dropDownView.addSubview(stackView)
        dropDownView.backgroundColor = .clear
        dropDownView.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(handeDropDown))
    }
    
    @objc func handeDropDown() {
        dropDownView.removeFromSuperview()
        completion?(nil)
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
        let buttonFrameInScrollView = addView.convert(addView.bounds, to: scrollView)
        if scrollView.bounds.contains(buttonFrameInScrollView) { return }
        view.layoutIfNeeded()
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    func hideAddView(isHide: Bool) {
        self.addView.isHidden = isHide
        self.cancelButton.isHidden = isHide
        self.addButton.isHidden = isHide
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
    
    @objc func chooseStatus(sender: UIButton) {
        switch sender.tag {
        case 1:
            self.completion?(Status.inProcess.id)
        case 2:
            self.completion?(Status.completed.id)
        case 3:
            self.completion?(Status.delay.id)
        default:
            self.completion?(Status.inProcess.id)
        }
        dropDownView.removeFromSuperview()
    }
    
    @IBAction func handleTapGesture(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func clickedCancel(_ sender: UIButton) {
        hideAddView(isHide: true)
        viewModel.clear()
    }
    
    @IBAction func clickedAdd(_ sender: UIButton) {
        viewModel.addWork()
        hideAddView(isHide: true)
        isAdded = true
    }
    
    @IBAction func clickedAddWork(_ sender: UIButton) {
        textFields.forEach({ $0.text = nil })
        hideAddView(isHide: false)
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
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return viewModel.works.count - 1 == section ? 0 : 16
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == costTextField, let value = textField.text, !value.isEmpty {
            costTextField.text! += "$"
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == costTextField, let value = textField.text, !value.isEmpty && value.last == "$" {
            costTextField.text?.removeLast()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == dateTextField {
            return false
        } else if textField == costTextField {
            return costTextField.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
        } else {
            return true
        }
    }
}

extension WorksViewController: WorkTableViewCellDelegate {
    func clickedSatus(button: UIButton, id: UUID) {
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            dropDownView.frame = window.frame
            window.addSubview(dropDownView)
        }
        stackView.isHidden = false
        let convertedFrame = button.convert(button.bounds, to: nil)
        stackView.frame.origin = CGPoint(x: convertedFrame.origin.x, y: convertedFrame.maxY + 2)
        self.completion = { [weak self] status in
            guard let self = self, let status = status else { return }
            button.setTitle(status, for: .normal)
            self.viewModel.changeStatus(id: id, status: status)
        }
    }
}

extension WorksViewController {
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(WorksViewController.keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                scrollView.contentInset = .zero
            } else {
                let height: CGFloat = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)!.size.height
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
            }
            
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
}

