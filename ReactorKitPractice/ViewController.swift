//
//  ViewController.swift
//  ReactorKitPractice
//
//  Created by 신승재 on 10/7/24.
//

import UIKit
import ReactorKit
import RxCocoa
import RxSwift

class ViewController: UIViewController, View {

    var disposeBag: DisposeBag = DisposeBag()
    typealias Reactor = ViewReactor
    
    init(reactor: Reactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
    }
    
    // 뷰와 리액터 사이의 action과 state를 바인드 하기 위한 메서드
    func bind(reactor: ViewReactor) {
        // action
        decreaseButton.rx.tap
            .map{ Reactor.Action.decrease }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State
        reactor.state.map{ $0.value }
            .distinctUntilChanged()
            .map{ String($0) }
            .bind(to: valueLabel.rx.text)
            .disposed(by: disposeBag)
        
        //reactor.state.map{ $0.isLoading }
    }
    
    // MARK: - Property
    let decreaseButton: UIButton = {
        let decreaseButton = UIButton()
        decreaseButton.setImage(UIImage(systemName: "minus"), for: .normal)
        decreaseButton.tintColor = .black
        decreaseButton.translatesAutoresizingMaskIntoConstraints = false
        return decreaseButton
    }()
    
    let increaseButton: UIButton = {
        let increaseButton = UIButton()
        increaseButton.setImage(UIImage(systemName: "plus"), for: .normal)
        increaseButton.tintColor = .black
        increaseButton.translatesAutoresizingMaskIntoConstraints = false
        return increaseButton
    }()
    
    let valueLabel: UILabel = {
        let valueLabel = UILabel()
        valueLabel.text = "0"
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        return valueLabel
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let statusIndicator = UIActivityIndicatorView()
        statusIndicator.translatesAutoresizingMaskIntoConstraints  = false
        return statusIndicator
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initConstraint()
    }

    override func loadView() {
        let view = UIView()
        self.view = view
        view.backgroundColor = .systemBackground
        
        [decreaseButton, increaseButton, valueLabel, activityIndicator].forEach { self.view.addSubview($0) }
    }
    
    // MARK: - AutoLayout
    func initConstraint() {
        NSLayoutConstraint.activate([
            decreaseButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            decreaseButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            decreaseButton.heightAnchor.constraint(equalTo: decreaseButton.widthAnchor),
            
            valueLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            valueLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            increaseButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            increaseButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            increaseButton.heightAnchor.constraint(equalTo: increaseButton.widthAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: valueLabel.safeAreaLayoutGuide.bottomAnchor, constant: 10),
        ])
    }
}

