//
//  DeadlinesViewController.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 26.09.24.
//

import UIKit
import FSCalendar
import Combine

class DeadlinesViewController: UIViewController {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarBgView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoDateLabel: UILabel!
    @IBOutlet weak var infoDescriptionTextView: UITextView!
    @IBOutlet weak var addDescriptionTextView: BaseTextView!
    @IBOutlet weak var calendarAddButton: UIButton!
    @IBOutlet var bottomButtons: [UIButton]!
    @IBOutlet weak var addInfoDateLabel: UILabel!
    @IBOutlet weak var addInfoView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var addInfoButton: UIButton!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    private var cancellables: Set<AnyCancellable> = []
    private let viewModel = DeadlineViewModel.shared
    private let menuButton = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
        viewModel.fetchDeadlines()
    }
    
    func setupUI() {
        menuButton.setImage(UIImage(named: "Menu"), for: .normal)
        menuButton.addTarget(self, action: #selector(clickedMenu), for: .touchUpInside)
        self.setNavigationBar(leftButton: UIButton(), rightButton: menuButton)
        calendar.layer.backgroundColor = UIColor.white.cgColor
        calendar.layer.cornerRadius = 16
        calendar.delegate = self
        calendar.dataSource = self
        calendar.appearance.titleTodayColor = .white
        calendar.appearance.todayColor = .systemGreen
        tapGesture.delegate = self
        addDescriptionTextView.baseDelegate = self
        addDescriptionTextView.font = .italicMulish(size: 16)
        addDescriptionTextView.placeholder = "Enter the information"
        bottomButtons.forEach { button in
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.1
            button.layer.shadowOffset = CGSize(width: 0, height: 4)
            button.layer.shadowRadius = 4
            button.layer.masksToBounds = false
            button.layer.cornerRadius = 10
        }
    }
    
    func subscribe() {
        viewModel.$deadlines
            .receive(on: DispatchQueue.main)
            .sink { [weak self] deadlines in
                guard let self = self else { return }
                calendar.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$selectedDeadline
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedDeadline in
                guard let self = self else { return }
                if let selectedDeadline = selectedDeadline {
                    self.infoDateLabel.text = selectedDeadline.date.dateFormat()
                    self.infoDescriptionTextView.text = selectedDeadline.info
                    self.infoView.isHidden = false
                } else {
                    self.infoView.isHidden = true
                }
            }
            .store(in: &cancellables)
        
        viewModel.$selectedDate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedDate in
                guard let self = self else { return }
                self.calendarAddButton.isHidden = (selectedDate == nil)
            }
            .store(in: &cancellables)
    }
    
    @objc func clickedMenu() {
        if let menuVC = navigationController?.viewControllers.first(where: { $0 is MenuViewController }) {
            self.navigationController?.popToViewController(menuVC, animated: true)
        }
    }
    
    @IBAction func handleTapGesture(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func clickedCalendarAddButton(_ sender: Any) {
        calendarBgView.isHidden = true
        addInfoView.isHidden = false
        addInfoDateLabel.text = viewModel.selectedDate?.dateFormat()
        self.addDescriptionTextView.text = viewModel.selectedDeadline?.info
    }
    
    
    @IBAction func clickedInfoAddButton(_ sender: UIButton) {
        self.view.endEditing(true)
        viewModel.save(info: addDescriptionTextView.text)
        addDescriptionTextView.text = nil
        addInfoView.isHidden = true
        calendarBgView.isHidden = false
    }
    
    @IBAction func clickedCancel(_ sender: UIButton) {
        self.view.endEditing(true)
        addDescriptionTextView.text = nil
        addInfoView.isHidden = true
        calendarBgView.isHidden = false
    }
    
    @IBAction func clickedSave(_ sender: UIButton) {
        self.view.endEditing(true)
        viewModel.save(info: addDescriptionTextView.text)
        addDescriptionTextView.text = nil
        addInfoView.isHidden = true
        calendarBgView.isHidden = false
    }
    
    deinit {
        viewModel.clear()
    }
}

protocol BaseTextViewDelegate: AnyObject {
    func didChancheSelection(_ textView: UITextView)
}

extension DeadlinesViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        if viewModel.deadlines.contains(where: { $0.date == date }) {
            return #colorLiteral(red: 0.7921568627, green: 0, blue: 0, alpha: 1)
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if viewModel.deadlines.contains(where: { $0.date == date }) {
            return .white
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        viewModel.chooseDate(date: date)
    }
}

extension DeadlinesViewController: BaseTextViewDelegate {
    func didChancheSelection(_ textView: UITextView) {
        if let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines), text.isEmpty {
            saveButton.isEnabled = false
            addInfoButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
            addInfoButton.isEnabled = true
        }
    }
}

extension DeadlinesViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(view.hitTest(touch.location(in: view), with: nil)?.isDescendant(of: calendar) == true)
    }
}
