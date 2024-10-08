## ReactorKit이란?
ReactorKit은 RxSwift와 함께 사용하는 반응형 아키텍처 패턴(Reactive Architecture Pattern)을 기반으로 한 프레임워크이다. MVVM과 유사하지만, ReactorKit은 Reactor라는 개념을 도입하여 상태 관리와 비즈니스 로직을 명확하게 분리한다.

반응형, 단방향 Swift 아키텍쳐이며, Flux + Reactive Programming이라고 정의되어 있음!
<p align="center">
<img width="546" alt="스크린샷 2024-10-08 오전 9 53 29" src="https://github.com/user-attachments/assets/9ac8264f-ccf2-4ce9-898a-770985cf3bcd">
</p>

<br>

### 구성요소
- View → 뷰!
- Action → 사용자와 상호작용과 뷰의 상태를 정의한 State를 소유함. Mutation은 Action, State를 브릿징
- Reactor → UI와 분리된 영역으로 State를 관리함. View에게서 제어권을 완전히 가져옴
- State → View가 표시하거나 표시되는 데 사용해야 할 현재 상태를 저장하고 있는 타입

<br>

## 구현

### UI 작성
1. `+/- 버튼`, `activityIndicator`, `숫자표시 label`
```swift
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
```

<br>

2. `Constraint` 설정 및 `addSubview`
```swift
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

//MARK: - AutoLayout
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
```

<br>

- Result
<img width="330" alt="스크린샷 2024-10-08 오전 9 53 29" src="https://github.com/user-attachments/assets/597fda79-290f-47f0-8217-d76c8eb58066">

<br>

### Reactor(ViewModel)작성
- `Action`, `Mutation`, `State`
```swift
class ViewReactor: Reactor {
	enum Action { // -> User의 액션을 나타낸다.
        case decrease
        case increase
    }
    
    enum Mutation { // Mutation: 변화 -> 상태 변화를 나타낸다.
        case decreaseValue
        case increaseValue
        case setLoading(Bool)
    }
    
    struct State { // 현재 뷰의 상태를 나타낸다.
        var value: Int = 0
        var isLoading: Bool = false
    }
    
    let initialState: State = State()
}
```

<br>

- `func mutate()` → View로부터 Action을 받고 `Observable<Mutation>`을 생성한다.
```swift
// 이 메서드는 순수함수 이므로 동기적으로 새로운 State를 return 해야한다.
// 함수 안에서 어떤 side effect들을 수행하면 안됨
func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .decreaseValue:
            newState.value -= 1
        case .increaseValue:
            newState.value += 1
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
        }
        
        return newState
    }
```

<br>

### View에서 Reactor 채택
- ViewController.swift
```swift
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

	...
}
```

<br>

- SceneDelegate.swift
```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    
    let reactor = ViewReactor()
    window?.rootViewController = ViewController(reactor: reactor)
    
    guard let _ = (scene as? UIWindowScene) else { return }
}
```

<br>

- `func bind()` → 뷰와 리액터 사이의 action과 state를 바인드 하기 위한 메서드
```swift
func bind(reactor: ViewReactor) {
    // action
    decreaseButton.rx.tap
        .map{ Reactor.Action.decrease }
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
    
    increaseButton.rx.tap
        .map{ Reactor.Action.increase }
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
    
    // State
    reactor.state.map{ $0.value } // 첫번째 map -> value를 추출하는 역할
        .distinctUntilChanged()
        .map{ String($0) } // Int값을 String으로 바꾸는 역할
        .bind(to: valueLabel.rx.text)
        .disposed(by: disposeBag)
    
    reactor.state.map{ $0.isLoading }
        .distinctUntilChanged()
        .bind(to: activityIndicator.rx.isAnimating)
        .disposed(by: disposeBag)
}
```

<br>

## 참고
- [iOS ReactorKit과 TCA(Unidirectional pattern)](https://velog.io/@sanghwi_back/iOS-ReactorKit-%EA%B3%BC-TCA-Unidirectional-pattern)
- [[튜토리얼]ReactorKit 차근차근 사용해보기](https://apple-apeach.tistory.com/19)
