import ComposableArchitecture
import XCTest
@testable import ConciseForms

class ConciseFormsTests: XCTestCase {
  func testBasics() {
    let store = TestStore(
      initialState: SettingsState(),
      reducer: conciseSettingsReducer,
      environment: SettingsEnvironment(
        mainQueue: DispatchQueue.immediateScheduler.eraseToAnyScheduler(),
        userNotifications: UserNotificationsClient(
          getNotificationSettings: { fatalError() },
          registerForRemoteNotifications: { fatalError() },
          requestAuthorization: { _ in fatalError() }
        )
      )
    )
    store.assert(
      .send(.form(.init(\.displayName, "Blob"))) {
        $0.displayName = "Blob"
      },
      .send(.form(.init(\.displayName, "Blob McBlob, Esq."))) {
        $0.displayName = "Blob McBlob, Esq"
      },
      .send(.form(.init(\.protectMyPosts, true))) {
        $0.protectMyPosts = true
      },
      .send(.form(.init(\.digest, .weekly))) {
        $0.digest = .weekly
      }
    )
  }

  func testNotifications_HappyPath() {
    var didRegisterForRemoteNotifications = false

    let store = TestStore(
      initialState: SettingsState(),
      reducer: conciseSettingsReducer,
      environment: SettingsEnvironment(
        mainQueue: DispatchQueue.immediateScheduler.eraseToAnyScheduler(),
        userNotifications: UserNotificationsClient(
          getNotificationSettings: {
            .init(value: .init(authorizationStatus: .notDetermined))
          },
          registerForRemoteNotifications: {
            .fireAndForget {
              didRegisterForRemoteNotifications = true
            }
          },
          requestAuthorization: { _ in
            .init(value: true)
          }
        )
      )
    )

    store.assert(
      .send(.form(.init(\.sendNotifications, true))),
      .receive(.notificationSettingsResponse(.init(authorizationStatus: .notDetermined))) {
        $0.sendNotifications = true
      },
      .receive(.authorizationResponse(.success(true)))
    )

    XCTAssertEqual(didRegisterForRemoteNotifications, true)
  }
}
