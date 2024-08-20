import UIKit

enum Dimension {
    case width, height
}

struct ScalableLayoutHelper {
    
    static func scaled(dimensionSize: CGFloat, to dimension: Dimension) -> CGFloat {
        let screenWidth  = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        let ratio: CGFloat
        let resultDimensionSize: CGFloat
        
        switch dimension {
        case .width:
            ratio = dimensionSize / Device.baseDevice.screenSize.width
            resultDimensionSize = screenWidth * ratio
        case .height:
            ratio = dimensionSize / Device.baseDevice.screenSize.height
            resultDimensionSize = screenHeight * ratio
        }
        
        return resultDimensionSize
    }
}
