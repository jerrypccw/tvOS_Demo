
import Foundation

protocol PositionController: class {
    var isEnabled: Bool { get set }

    func click(_ sender: LongPressGestureRecogniser)
    func playOrPause(_ sender: Any)
}
