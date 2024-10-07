//
//  ViewReactor.swift
//  ReactorKitPractice
//
//  Created by 신승재 on 10/7/24.
//

import ReactorKit
import RxSwift

class ViewReactor: Reactor {
    enum Action { // -> User의 액션을 나타낸다.
        case decrease
    }
    
    enum Mutation { // Mutation: 변화 -> 상태 변화를 나타낸다.
        case decreaseValue
    }
    
    struct State { // 현재 뷰의 상태를 나타낸다.
        var value: Int = 0
    }
    
    let initialState: State = State()
    
    // View로부터 Action을 받고, Observable<Mutation>을 생성한다.
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .decrease:
            // <Observable>
            // 데이터 스냅샷을 전달할 수 잇는 이벤트 시퀀스를 비동기적으로 생성하는 기능을 담당한다.
            
            // Mutation.decreaseValue를 내보내고 완료됨
            return Observable.just(Mutation.decreaseValue)
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
        }
        
        return newState
    }
}
