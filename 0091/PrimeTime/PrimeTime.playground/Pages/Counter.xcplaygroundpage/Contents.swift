import ComposableArchitecture
@testable import Counter
import PlaygroundSupport
import SwiftUI

var environment: CounterEnvironment = { _ in .sync { 7236893748932 }}

PlaygroundPage.current.liveView = UIHostingController(
  rootView: CounterView(
    store: Store<CounterViewState, CounterViewAction>(
      initialValue: CounterViewState(
        alertNthPrime: nil,
        count: 0,
        favoritePrimes: [],
        isNthPrimeButtonDisabled: false
      ),
      reducer: counterViewReducer,
      environment: environment
    )
  )
)

1