import Foundation
import SnapKit

extension ConstraintMakerEditable {
    
    @discardableResult
    public func scaledOffset(_ amount: CGFloat) -> ConstraintMakerEditable {
        offset(amount.scaled())
        return self
    }
    
    @discardableResult
    public func horizontalScaledOffset(_ amount: CGFloat) -> ConstraintMakerEditable {
        offset(amount.hScaled)
        return self
    }
    
    @discardableResult
    public func verticalScaledOffset(_ amount: CGFloat) -> ConstraintMakerEditable {
        offset(amount.vScaled)
        return self
    }
}

extension ConstraintMakerRelatable {
    
    @discardableResult
    public func equalToScaledValue(_ amount: CGFloat) -> ConstraintMakerEditable {
        return self.equalTo(amount.hScaled)
    }
    
    @discardableResult
    public func equalToHorizontalScaledValue(_ amount: CGFloat) -> ConstraintMakerEditable {
        return self.equalTo(amount.hScaled)
    }
    
    @discardableResult
    public func equalToVerticalScaledValue(_ amount: CGFloat) -> ConstraintMakerEditable {
        return self.equalTo(amount.vScaled)
    }
}

