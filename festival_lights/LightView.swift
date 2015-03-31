
import UIKit

class LightView: UIViewController
{
    
    var pageIndex : Int = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    func changeColor(bgColor : UIColor){
        self.view.backgroundColor = bgColor
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
}
