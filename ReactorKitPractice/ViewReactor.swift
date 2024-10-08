//
//  ViewReactor.swift
//  ReactorKitPractice
//
//  Created by 신승재 on 10/7/24.
//

import ReactorKit
import RxSwift

class ViewReactor: Reactor { // ViewModel이라고 생각하면 되는듯.
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
    
    // View로부터 Action을 받고, Observable<Mutation>을 생성한다.
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .decrease:
            // <Observable>
            // 데이터 스냅샷을 전달할 수 잇는 이벤트 시퀀스를 비동기적으로 생성하는 기능을 담당한다.
            
            // Mutation.decreaseValue를 내보내고 완료됨
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                Observable.just(Mutation.decreaseValue).delay(.seconds(1), scheduler: MainScheduler.instance),
                Observable.just(Mutation.setLoading(false)),
                ])
        case .increase:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                Observable.just(Mutation.increaseValue).delay(.seconds(1), scheduler: MainScheduler.instance),
                Observable.just(Mutation.setLoading(false)),
                ])
        }
    }
    
    // 기존 State와 Mutation으로부터 새로운 State를 생성한다.
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
}
