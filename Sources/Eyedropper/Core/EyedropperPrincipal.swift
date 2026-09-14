import AppKit
import DroppyKit

@objc(EyedropperPrincipal)
public final class EyedropperPrincipal: NSObject, DropletPrincipal {
    public override init() { super.init() }

    @MainActor public func makeDroplet() -> AnyObject { EyedropperDroplet() }
}
