//
//  MaterialsViewController.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 26.09.24.
//

import UIKit
import Combine

class MaterialsViewController: UIViewController {

    @IBOutlet weak var materialsTableView: UITableView!
    private let viewModel = MaterialsViewModel.shared
    private var cancellables: Set<AnyCancellable> = []
    private let menuButton = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
        viewModel.fetchMaterials()
    }
    
    func setupUI() {
        menuButton.setImage(UIImage(named: "Menu"), for: .normal)
        menuButton.addTarget(self, action: #selector(clickedMenu), for: .touchUpInside)
        self.setNavigationBar(leftButton: UIButton(), rightButton: menuButton)
        materialsTableView.delegate = self
        materialsTableView.dataSource = self
        materialsTableView.register(UINib(nibName: "DocumentTableViewCell", bundle: nil), forCellReuseIdentifier: "DocumentTableViewCell")
        materialsTableView.register(UINib(nibName: "MaterialTableViewCell", bundle: nil), forCellReuseIdentifier: "MaterialTableViewCell")

    }
    
    func subscribe() {
        viewModel.$materials
            .receive(on: DispatchQueue.main)
            .sink { [weak self] materials in
                guard let self = self else { return }
                self.materialsTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc func clickedMenu() {
        if let menuVC = navigationController?.viewControllers.first(where: { $0 is MenuViewController }) {
            self.navigationController?.popToViewController(menuVC, animated: true)
        }
    }
    
    @objc func addMaterial() {
        let materialVC = MaterialViewController(nibName: "MaterialViewController", bundle: nil)
        MaterialViewModel.shared.material = MaterialModel(id: UUID(), title: "", info: "")
        materialVC.completion = { [weak self] in
            guard let self = self else { return }
            self.viewModel.fetchMaterials()
        }
        self.navigationController?.pushViewController(materialVC, animated: true)
    }


}

extension MaterialsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.materials.count == 0 ? 1 : viewModel.materials.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.materials.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MaterialTableViewCell", for: indexPath) as! MaterialTableViewCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTableViewCell", for: indexPath) as! DocumentTableViewCell
        cell.setFont()
        cell.setupData(name: viewModel.materials[indexPath.section].title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewModel.materials.isEmpty {
            return 0
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if viewModel.materials.count - 1 == section || viewModel.materials.isEmpty {
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 60)) // Adjust height as needed
            let button = UIButton(type: .custom)
            button.setTitleColor(#colorLiteral(red: 0.5803921569, green: 0.6705882353, blue: 0.631372549, alpha: 1), for: .normal)
            button.titleLabel?.font = .boldSFPro(size: 20)
            button.setTitle("Add", for: .normal)
            button.setImage(UIImage(named: "Add"), for: .normal)
            button.addTarget(self, action: #selector(addMaterial), for: .touchUpInside)
            button.frame = CGRect(x: (footerView.frame.width - 86) / 2, y: (footerView.frame.height - 42) / 2, width: 86, height: 42)
            footerView.addSubview(button)
            return footerView
        } else {
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if viewModel.materials.isEmpty {
            return 60
        }
        return viewModel.materials.count - 1 == section ? 60 : 4
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let materialVC = MaterialViewController(nibName: "MaterialViewController", bundle: nil)
        MaterialViewModel.shared.material = viewModel.materials[indexPath.section]
        materialVC.completion = { [weak self] in
            guard let self = self else { return }
            self.viewModel.fetchMaterials()
        }
        self.navigationController?.pushViewController(materialVC, animated: true)
    }
}
