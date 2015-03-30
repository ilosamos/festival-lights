
import UIKit

class LightView: UIViewController
{
    
    var pageIndex : Int = 0
    var startLabel : UILabel = UILabel()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        startLabel.text = "HEYO"
        startLabel.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        self.view.addSubview(startLabel)
    }
    
    func changeColor(bgColor : UIColor){
        self.view.backgroundColor = bgColor
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
}
