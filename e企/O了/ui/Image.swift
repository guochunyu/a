//
//  Image.swift
//  e企
//
//  Created by a on 15/5/15.
//  Copyright (c) 2015年 QYB. All rights reserved.
//



import UIKit
let screenWidth=UIScreen.mainScreen().bounds.size.width;
let screenHight=UIScreen.mainScreen().bounds.size.height;
protocol MyimageviewBotton{
    func MyimageviewBottonClink(myimageview:Myimageview)
}
class Myimageview: UIView,MyimageviewBotton {
    var button:UIButton!
    var imageView:UIImageView!
    var label:UILabel!
    var type:String?
    weak var delegate:AnyObject?
   class func getbotton(view: UIView)->CGFloat {
    return view.frame.origin.y+view.frame.size.height;
    
    }
    func MyimageviewBottonClink(myimageview: Myimageview) {
        if(delegate != nil&&delegate!.respondsToSelector("MyimageviewBottonClink:")){
            delegate!.MyimageviewBottonClink(self)
        }
    }
    init(frame: CGRect, buttonwidth:CGFloat,buttonImageName:String) {
        super.init(frame: frame)
        imageView=UIImageView(frame: CGRectMake(0, 0, frame.size.width, frame.size.height));
        imageView.layer.masksToBounds=true;
        imageView.layer.cornerRadius=frame.size.width*0.5;
        //imageView.backgroundColor=UIColor.blueColor();
        self.addSubview(imageView);
        button=UIButton(frame: CGRectMake(frame.size.width-buttonwidth, 0, buttonwidth, buttonwidth));
        button.setImage(UIImage(named:buttonImageName), forState: UIControlState.Normal)
        button .addTarget(self, action: "MyimageviewBottonClink:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(button);
        label=UILabel(frame: CGRectMake(0, frame.size.height, frame.size.width,20))
        //label.backgroundColor=UIColor.blueColor()
        self .addSubview(label)
        label.adjustsFontSizeToFitWidth=true;
        label.textAlignment=NSTextAlignment.Center;
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIView {
    var x:CGFloat{
        get{
            return self.frame.origin.x;
        }
        set(x){
        self.frame=CGRectMake(x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        }
    }
    var y:CGFloat{
        get{
            return self.frame.origin.y;
        }
        set(y){
            var rect=self.frame
            rect.origin.y=y;
            self.frame=rect;
        }
    }
    var width:CGFloat{
        get{
            return self.frame.size.width;
        }
        set(width){
            var rect=self.frame
            rect.size.width=width;
            self.frame=rect;
        }
    }
    var height:CGFloat{
        get{
            return self.frame.size.height;
        }
        set(height){
            var rect=self.frame
            rect.size.height=height;
            self.frame=rect;
        }
    }
    var bottomY:CGFloat{
        return self.frame.size.height + self.frame.origin.y;
    }
}

