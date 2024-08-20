import Foundation

extension CGFloat {
    
    func scaled(to dimension: Dimension = .width) -> CGFloat {
        ScalableLayoutHelper.scaled(dimensionSize: self, to: dimension)
    }
    
    var hScaled: CGFloat {
        self.scaled(to: .width)
    }
    
    var vScaled: CGFloat {
        self.scaled(to: .height)
    }
}
