//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    var label: UILabel?

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Hello World!"
        label.textColor = .black

        self.label = label
        view.addSubview(label)
        self.view = view
    }
}
// Present the view controller in the Live View window
let currentViewController = MyViewController()
PlaygroundPage.current.liveView = currentViewController
currentViewController.label = nil
