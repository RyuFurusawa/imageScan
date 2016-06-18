//
//  ViewController.swift
//  image-scan
//
//  Created by Ryu Furusawa on 2016/06/02.
//  Copyright © 2016年 Ryu Furusawa. All rights reserved.
//

import CoreMotion
import UIKit
import AVFoundation


extension UIImage {
  func tint(color: UIColor) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    color.setFill()
    let drawRect = CGRectMake(0, 0, size.width, size.height)
    UIRectFill(drawRect)
    drawInRect(drawRect, blendMode:.DestinationIn, alpha: 1)
    let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return tintedImage
  }
}
extension  UILabel {
  func countLabelformat(){
    self.textColor = UIColor.whiteColor()
    self.backgroundColor = UIColor.darkGrayColor()
    self.layer.masksToBounds = true
    self.layer.cornerRadius = self.frame.width / 2
    //self.layer.borderColor = UIColor.whiteColor().CGColor
   // self.layer.borderWidth = self.frame.width / 20
    self.textAlignment = NSTextAlignment.Center
  }
  func infoLabelformat(){
    self.textColor = UIColor.whiteColor()
    self.backgroundColor = UIColor.clearColor()
    self.layer.masksToBounds = true
    self.layer.cornerRadius = self.frame.width / 2
    self.layer.borderColor = UIColor.whiteColor().CGColor
    self.layer.borderWidth = self.frame.width / 15
    self.alpha = 0.7
    self.textAlignment = NSTextAlignment.Center
    self.userInteractionEnabled = true
    self.numberOfLines = 0

  }

}


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIPickerViewDelegate, UIPickerViewDataSource{
 // @IBOutlet weak var cameraView: UIImageView!

  var screenWidth : CGFloat!
  var screenHeight : CGFloat!
  
  //var scale: CGFloat!
  //var aspectScale: CGFloat! = 1.0
  var step: CGFloat! = 10
  
  //var speed: CGFloat! = 10.0
  var Iwidth: CGFloat!
  var Iheight: CGFloat!
  var intervaltime: NSTimeInterval! = 1.0
  var buttonMainCenter:CGPoint!
  var buttonMainSize:CGPoint!
  var notificationtRedyCenter:CGPoint!
  //var lightBarWidth:CGFloat! = 10
  var scanPlayAtoB:[CGFloat]!
  var isFirstSet:Bool = true
  var barSizeChangeAnimationCompleted:Bool = true
  var stampTime:Double = 0.1 //stamp mode1の時に使う
  
  
  
  //多次元配列にパラメーターを保存していく。
var viewerStyleMode :[Int8]!
/*
viewer style:
   0 left scan
   1 right scan
   2 stamp 

Play Mode:
   0 (single scan)
   1 (loop scan)
   2 (taping scan)
   3 (single stamp)
   4 (tap stamp)
   5 (stamp while device stay stoping)
*/
  
  
  var viewerSettingData=(Int(1),Int(1),CGFloat(100.0))
   var viewerDataBuffer=(Int(1),Int(1),CGFloat(100.0))

  /*Tuple型
   0  Scan speed
   1  Stamp speed
  */
  var directionLeft:Bool = true
  var phaize:Int8! = 0
  /*
   0 = menu,
   1 = pre-prePlay,
   2 = play
   3 = done
   4 = firing(tap Mode)
   5 = notification PopUp
   6 = loopScanPlaying
   7 = StampPlaying
   8 = Edit Parametors
   9 = tap Stamp mode
  */
  var noActionTimer:Int! = 0

  
  
  //カウント：0-3
 
  //Width:double
  //Height:double
  //Speed:double
  //窓のサイズ:CGFloat
  
  //UIView関連
  var cameraView: UIImageView!//実際に再生に使うビュ
  var viewerOpeView: UIView! //メインのオペレーションビュー
  var opeImage:UIImageView! //サブビュー
  var frameViewR: UIImageView!
  var frameViewL: UIImageView!
  var viewerInfoButton:UIButton!//サブビュー　パラメーターセットボタン
  //var addImageButton: UIButton!
  var addImageButton:UIBarButtonItem!
  var editButton:UIBarButtonItem!
  var myToolBar: UIToolbar!
  var myUIPicker:UIPickerView!
  
  
  var scanintervalLabel: UILabel!
  var stampIntervalLabel:UILabel!
  var lightBarSizeLabel:UILabel!
  var scanSpeedSetCircle:UILabel!
  var stampSpeedSetCircle:UILabel!
  var lightBarSizeSetCircle:UILabel!
  var scanSpeedInfoTxt:UILabel!
  var stampSpeedInfoTxt:UILabel!
  var lightBarSizeInfoTxt:UILabel!
  
  var count3Label: UILabel!
  var count2Label: UILabel!
  var count1Label: UILabel!
  var notificationLabel: UILabel!
  
  //ジェスチャー
  var viewTap:UITapGestureRecognizer!
  //var stopTap:UITapGestureRecognizer!
  var stampTap:UITapGestureRecognizer!
  var replayTap:UITapGestureRecognizer!
  var myPan:UIPanGestureRecognizer!
  var swipeLeft:UISwipeGestureRecognizer!
  var swipeRight:UISwipeGestureRecognizer!
  var swipeDown:UISwipeGestureRecognizer!
  var swipeUp:UISwipeGestureRecognizer!
  var doubleTap:UITapGestureRecognizer!
  
  var stampSpeedTable:[Double]!
  var stampSpStringTable:[String]!
  var scanSpeedTable:[Double]!
  var scanSpStringTable:[String]!
  
  
  
  

  
  //加速度センサの表示
  //Motion
  var myMotionManager: CMMotionManager!
//  @IBOutlet weak var accelX: UILabel!
//  @IBOutlet weak var accelY: UILabel!
//  @IBOutlet weak var accelZ: UILabel!
//  
//  //Gyroセンサの表示
//  @IBOutlet weak var rotaionX: UILabel!
//  @IBOutlet weak var rotaionY: UILabel!
//  @IBOutlet weak var rotaionZ: UILabel!

  

  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    
    stampSpeedTable = [0.5,0.25,0.05,0.033,0.017,0.011,0.0083,0.0066,0.005]
    stampSpStringTable = ["1/2","1/4","1/10","1/30","1/60","1/90","1/120","1/150","1/200"]
    scanSpeedTable = [0.25,0.5,1.0,1.5,2.0,3.0]
    scanSpStringTable = ["1/4","1/2","1","1.5","2","3"]
    
    
    
    //viewerStyleMode set 
    viewerStyleMode = [0,0] //scan direction Left , single play

    print(UIDevice.currentDevice().localizedModel)
    
    // Screen Size の取得
    screenWidth = self.view.bounds.width
    screenHeight = self.view.bounds.height
    if(screenWidth < screenHeight){
      step  = screenWidth / 20

      buttonMainCenter = CGPointMake(screenWidth/2,screenHeight * 2 / 5)
      buttonMainSize = CGPointMake(screenWidth * 0.8, screenWidth * 0.8)
    }else{
      step  = screenHeight / 20

      buttonMainCenter = CGPointMake(screenWidth/2,screenHeight * 2 / 5)
      buttonMainSize = CGPointMake(screenHeight * 0.6, screenHeight * 0.6)
    }

    (viewerSettingData.2) = step
    print("tuple:",viewerSettingData)
    viewerDataBuffer = viewerSettingData
    //viewの設定
    self.view.backgroundColor=UIColor.blackColor()
    
   
    // パン認識.スワイプ左、右
    viewTap = UITapGestureRecognizer(target: self, action: "viewTapped:")
    //stopTap = UITapGestureRecognizer(target: self, action: "stopPlayTapped:")
    stampTap = UITapGestureRecognizer(target:self, action:"prePreStampPlay:")
    stampTap.numberOfTouchesRequired = 1
    myPan = UIPanGestureRecognizer(target: self, action: "panGesture:")
    swipeLeft = UISwipeGestureRecognizer(target: self, action: "didSwipe:")
    swipeRight = UISwipeGestureRecognizer(target: self, action: "didSwipe:")
    swipeDown = UISwipeGestureRecognizer(target: self,action:"didSwipe:")
    swipeUp = UISwipeGestureRecognizer(target: self,action:"didSwipe:")
    swipeLeft.direction = .Left
    swipeRight.direction = .Right
    swipeDown.direction = .Down
    swipeUp.direction = .Up
    // ダブルタップ
   doubleTap = UITapGestureRecognizer(target:self, action: "prePreStampPlay:")
    doubleTap.numberOfTouchesRequired = 2
    
    self.view.addGestureRecognizer(viewTap)
    //他のジェスチャーは、最初にイメージを取得してから
    
    

    cameraView = UIImageView(frame: CGRectMake(0,0,screenWidth,screenHeight))
    //cameraView.contentMode =
    cameraView.image = UIImage(named:"IMG_1485low200pxMetaDataOFF.jpg")
    cameraView.alpha = 0
    
    notificationtRedyCenter = CGPointMake(screenWidth/2,screenHeight + buttonMainSize.x/2)
    
    let countRect:CGRect=CGRectMake(screenWidth, screenHeight * 2 / 5 - buttonMainSize.x/2, buttonMainSize.x, buttonMainSize.y)
    
    count3Label =  UILabel(frame:  countRect)
    count2Label =  UILabel(frame:  countRect)
    count1Label =  UILabel(frame:  countRect)
    
    count3Label.text="3"
    count3Label.countLabelformat()
    count2Label.text="2"
    count2Label.countLabelformat()
    count1Label.text="1"
    count1Label.countLabelformat()
    
    notificationLabel = UILabel(frame: countRect)
    notificationLabel.countLabelformat()
    notificationLabel.layer.borderColor = UIColor.darkGrayColor().CGColor
    notificationLabel.layer.borderWidth = step / 3
    notificationLabel.backgroundColor = UIColor.clearColor()
    notificationLabel.textColor = UIColor.lightGrayColor()
    notificationLabel.numberOfLines = 0
    notificationLabel.center = buttonMainCenter
    let bundleIdentifier = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String
    let version: AnyObject! = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString")

    notificationLabel.text = "\(bundleIdentifier) -v\(version)\n How to use \n\n [SwipeLR Image -> SlidePlay]\n (1 finger) -> onetime \n (2 finger) -> Loop \n (3 finger) -> Tap and Fire!\n\n[Tap Image -> Stamp]\n (1 finger) -> onetime \n (2 finger) -> Tap and Fire!"

    //Playボタンのカスタマイズ
    viewerOpeView = UIView(frame: countRect)
    viewerOpeView.center=buttonMainCenter
    viewerOpeView.layer.masksToBounds = true
//    viewerOpeView.layer.borderColor = UIColor.darkGrayColor().CGColor
//    viewerOpeView.layer.borderWidth = step / 3
    viewerOpeView.layer.cornerRadius = viewerOpeView.frame.width / 2
    viewerOpeView.backgroundColor = UIColor.clearColor()
    
    myToolBar = UIToolbar(frame:  CGRectMake(0, screenHeight - step * 3, screenWidth, step * 3))
    myToolBar.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height-step * 1.5)
    myToolBar.barStyle = UIBarStyle.BlackTranslucent
    
    myToolBar.tintColor = UIColor.blueColor()
    myToolBar.backgroundColor = UIColor.blackColor()
    
    
    
    
    //create a new button
    let abutton: UIButton = UIButton(type:UIButtonType.Custom)
    //set image for button
    abutton.setImage(UIImage(named: "album-1-100px-alpha.png"), forState: UIControlState.Normal)
    //add function for button
    abutton.addTarget(self, action: "showAlbum:", forControlEvents: UIControlEvents.TouchUpInside)
    //set frame
    abutton.frame = CGRectMake(0, 0, step * 3 - 3,step * 3 - 3)
  
    
    //create a new button
    let bbutton: UIButton = UIButton(type:UIButtonType.Custom)
    bbutton.setImage(UIImage(named: "photo-camera-2-100px-alpha.png"), forState: UIControlState.Normal)
    bbutton.addTarget(self, action: "CameraStart:", forControlEvents: UIControlEvents.TouchUpInside)
    bbutton.frame = CGRectMake(0, 0, step * 3 - 3,step * 3 - 3)
    
    //create a new button
    let cbutton: UIButton = UIButton(type:UIButtonType.Custom)
    cbutton.setImage(UIImage(named: "info-2-100px-alpha.png"), forState: UIControlState.Normal)
    cbutton.addTarget(self, action: "editTapped:", forControlEvents: UIControlEvents.TouchUpInside)
    cbutton.frame = CGRectMake(0, 0, step * 3 - 3,step * 3 - 3)
    
    
    
    //Toolbarに追加するボタンの作成
    //addImageButton = UIBarButtonItem(title: "photo", style:UIBarButtonItemStyle.P, target: self, action: "showAlbum:")
    addImageButton = UIBarButtonItem(customView:bbutton)
    addImageButton.tag = 1
    //addImageButton = UIBarButtonItem(image:UIImage(named: "photo-camera-2-44px.png"), style:UIBarButtonItemStyle.Plain, target: self, action: "showAlbum:")
    
    //addImageButton.image?.size =  CGSizeMake( step * 3, step * 3)
    
    //addImageButton.setBackgroundImage(UIImage(named: "photo-camera.png"), forState: UIControlState.Normal, style: UIBarButtonItemStyle.Plain, barMetrics: UIBarMetrics.Default)
   
    
    let cameraButton = UIBarButtonItem(customView:abutton)
    cameraButton.tag = 2
    editButton = UIBarButtonItem(customView:cbutton)
    editButton.tag = 3
    editButton.enabled = false
    
    let buttonGap: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)


    myToolBar.items = [addImageButton ,buttonGap,cameraButton,buttonGap,editButton]
    
    
    

    /*
    
    //addImageButton = UIButton(type: UIButtonType.ContactAdd)
    addImageButton = UIButton(frame:CGRectMake(0,screenHeight - step * 3,screenWidth,step * 3))
    addImageButton.setTitle("select Image", forState:  UIControlState.Normal)
    addImageButton.backgroundColor = UIColor.grayColor()
    //addImageButton.center = CGPointMake(screenWidth / 2, screenHeight - step)
    // イベントを追加する.
    addImageButton.addTarget(self, action: "showAlbum:",forControlEvents: UIControlEvents.TouchUpInside)
    */
    
    
    myUIPicker = UIPickerView()
    myUIPicker.frame = CGRectMake(0,0,self.view.bounds.width, 250.0)
    myUIPicker.delegate = self
    myUIPicker.dataSource = self
    
    
    frameViewR = UIImageView(frame: CGRectMake(step * 10.5,0,step * 10,screenHeight))
    frameViewR.image = UIImage(named: "IMG_1485low200pxMetaDataOFF.jpg")?.tint( UIColor.blackColor())
    
    frameViewL = UIImageView(frame: CGRectMake(-1*step*0.5,0,step * 10,screenHeight))
    frameViewL.image = UIImage(named: "IMG_1485low200pxMetaDataOFF.jpg")?.tint( UIColor.blackColor())
    
    
    
    // UIImageViewをViewに追加する.
    self.view.addSubview(cameraView)
    
    //窓をviewに追加
    self.view.addSubview(frameViewR)
    self.view.addSubview(frameViewL)
    
    //UILabelをViewへ
    self.view.addSubview(count3Label)
    self.view.addSubview(count2Label)
    self.view.addSubview(count1Label)
    self.view.addSubview(notificationLabel)
    //UIButtonを追加
    //self.view.addSubview(addImageButton)
    self.view.addSubview(myToolBar)
    
    self.view.addSubview(viewerOpeView)
    
    /*
    //self.view.addSubview(myUIPicker)
    let setBarARect = CGRectMake(screenWidth * 1 / 7, screenHeight * 2 / 3,screenWidth * 5 / 7,screenHeight * 1 / 15 )
    let setBarBRect = CGRectMake(screenWidth * 1 / 7, screenHeight * 2 / 3+screenHeight * 1 / 14,screenWidth * 5 / 7,screenHeight * 1 / 15 )

    let scanSpeedBarBase = UIView(frame:setBarARect)
    scanSpeedBarBase.backgroundColor = UIColor.grayColor()
    let scanSpeedBartop = UIView(frame:setBarARect)
    scanSpeedBartop.backgroundColor = UIColor.lightGrayColor()
    scanSpeedBarBase.tag = 20
    //scanSpeedBartop.frame.size.width = scanSpeedBartop.frame.size.width/3
    scanSpeedBarBase.addSubview(scanSpeedBartop)
    scanSpeedBarBase.addGestureRecognizer(myPan)
    
    let stampSpeedBarBase = UIView(frame:setBarBRect)
    stampSpeedBarBase.backgroundColor = UIColor.darkGrayColor()
    let stampSpeedBarTop = UIView(frame:setBarBRect)
    stampSpeedBarTop.backgroundColor = UIColor.lightGrayColor()
    
    stampSpeedBarBase.addSubview(stampSpeedBarTop)
    stampSpeedBarBase.tag = 21
    
    self.view.addSubview(scanSpeedBartop)
    self.view.addSubview(stampSpeedBarTop)
    */
    let setCircleRect = CGRectMake(0,0,buttonMainSize.x/3.3,buttonMainSize.x/3.3)
    
    scanSpeedSetCircle = UILabel(frame:setCircleRect)
    stampSpeedSetCircle = UILabel(frame:setCircleRect)
    lightBarSizeSetCircle = UILabel(frame:setCircleRect)
    
    scanSpeedInfoTxt = UILabel(frame:setCircleRect)
    stampSpeedInfoTxt = UILabel(frame:setCircleRect)
    lightBarSizeInfoTxt = UILabel(frame:setCircleRect)
    scanSpeedSetCircle.text = "1sec"
    stampSpeedSetCircle.text = "1/60"
    lightBarSizeSetCircle.text = "20px"
    scanSpeedInfoTxt.text = "Slide\nSpeed"
    stampSpeedInfoTxt.text = "Stamp\nSpeed"
    lightBarSizeInfoTxt.text = "Bar\nSize"
    scanSpeedSetCircle.infoLabelformat()
    stampSpeedSetCircle.infoLabelformat()
    lightBarSizeSetCircle.infoLabelformat()
    scanSpeedInfoTxt.infoLabelformat()
    stampSpeedInfoTxt.infoLabelformat()
    lightBarSizeInfoTxt.infoLabelformat()
    scanSpeedInfoTxt.layer.borderWidth = 0
    stampSpeedInfoTxt.layer.borderWidth = 0
    lightBarSizeInfoTxt.layer.borderWidth = 0
    
    let sukimaSetX:CGFloat = step / 2
    let setYCenter:CGFloat = screenHeight + buttonMainSize.x / 6.6
    let setXBaseIndent:CGFloat = (screenWidth - (setCircleRect.size.width*3 + sukimaSetX*2))/2
    let textInfoSukima:CGFloat = scanSpeedSetCircle.frame.size.height
    
    scanSpeedSetCircle.center = CGPointMake(setXBaseIndent+setCircleRect.size.width/2,setYCenter)
    stampSpeedSetCircle.center = CGPointMake(setXBaseIndent + setCircleRect.size.width*1.5+sukimaSetX,setYCenter)
    lightBarSizeSetCircle.center = CGPointMake(setXBaseIndent + setCircleRect.size.width*2.5+sukimaSetX*2,setYCenter)
    
    scanSpeedInfoTxt.center = CGPointMake(setXBaseIndent+setCircleRect.size.width/2,setYCenter + textInfoSukima)
    stampSpeedInfoTxt.center = CGPointMake(setXBaseIndent + setCircleRect.size.width*1.5+sukimaSetX,setYCenter+textInfoSukima)
    lightBarSizeInfoTxt.center = CGPointMake(setXBaseIndent + setCircleRect.size.width*2.5+sukimaSetX*2,setYCenter+textInfoSukima)
    
    let settingPanA = UIPanGestureRecognizer(target: self, action: "setPanGesture:")
    let settingPanB = UIPanGestureRecognizer(target: self, action: "setPanGesture:")
    let settingPanC = UIPanGestureRecognizer(target: self, action: "setPanGesture:")
    scanSpeedSetCircle.addGestureRecognizer(settingPanC)
    stampSpeedSetCircle.addGestureRecognizer(settingPanB)
    lightBarSizeSetCircle.addGestureRecognizer(settingPanA)
    scanSpeedSetCircle.tag = 11
    stampSpeedSetCircle.tag = 12
    lightBarSizeSetCircle.tag = 13
    
    scanSpeedSetCircle.alpha = 0.5
    stampSpeedSetCircle.alpha = 0.5
    lightBarSizeSetCircle.alpha = 0.5
    
    scanSpeedInfoTxt.alpha = 0.8
    stampSpeedInfoTxt.alpha = 0.8
    lightBarSizeInfoTxt.alpha = 0.8
    
    scanSpeedSetCircle.userInteractionEnabled = true
    
    cameraView.frame = CGRectMake(0, 0, screenWidth, screenHeight)
    
    //加速度センサ系の設定
    //motionProcess()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  // カメラの撮影開始
func CameraStart(sender: AnyObject) {
    
    let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.Camera
    // カメラが利用可能かチェック
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
      // インスタンスの作成
      let cameraPicker = UIImagePickerController()
      cameraPicker.sourceType = sourceType
      cameraPicker.delegate = self
      self.presentViewController(cameraPicker, animated: true, completion: nil)
      
    }
    else{
    }
}

  func scanSizeSet(imgView:UIImageView) -> CGRect{
    let imgWidth  = imgView.image!.size.width
    let imgHeight = imgView.image!.size.height
    let imgFrame =  CGRectMake((viewerSettingData.2) * 9.5, 0, (viewerSettingData.2) *  imgWidth / imgHeight * screenHeight, screenHeight)
    return imgFrame
}
  
  
  
  func intervalTimeSet(imgView:UIImageView, speed:Double) -> Double{
    let imgWidth  = imgView.image!.size.width
    let imgHeight = imgView.image!.size.height
    let time =  Double(imgWidth / imgHeight) * speed
    return time
  }

  
  
  //　撮影が完了時した時に呼ばれる
  func imagePickerController(imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      print("撮影が完了時した時に呼ばれる")
      
      // 画像の幅・高さの取得
      Iwidth = pickedImage.size.width
      Iheight = pickedImage.size.height
      
      if (isFirstSet == true ) {
        print("isFirstSet")
        
        let infoframe:CGRect = CGRectMake(buttonMainSize.x/2-screenWidth * 2 / 10,buttonMainSize.y/2,screenWidth * 4 / 10,screenWidth * 4 / 10)
        let infoSize = CGSizeMake(buttonMainSize.x / 4.2, buttonMainSize.x / 4.2)
        
        scanintervalLabel = UILabel(frame:infoframe)
        scanintervalLabel.frame.size = infoSize
        scanintervalLabel.center.y = buttonMainSize.y * 6.5 / 10
        scanintervalLabel.center.x = buttonMainSize.x / 4
        scanintervalLabel.infoLabelformat()
        scanintervalLabel.text = ""
        viewerOpeView.addSubview(scanintervalLabel)
        
        
        stampIntervalLabel = UILabel(frame:infoframe)
        stampIntervalLabel.frame.size = infoSize
        stampIntervalLabel.center.y = buttonMainSize.y * 6.5 / 10
        stampIntervalLabel.center.x = buttonMainSize.x * 2 / 4
        stampIntervalLabel.infoLabelformat()
        stampIntervalLabel.text = ""
        viewerOpeView.addSubview(stampIntervalLabel)
        
        
        lightBarSizeLabel = UILabel(frame:infoframe)
        lightBarSizeLabel.frame.size = infoSize
        lightBarSizeLabel.center.y = buttonMainSize.y * 6.5 / 10
        lightBarSizeLabel.center.x = buttonMainSize.x * 3 / 4
        lightBarSizeLabel.infoLabelformat()
        lightBarSizeLabel.text = ""
        viewerOpeView.addSubview(lightBarSizeLabel)
        
        
        

        //設定ボタン
        /*
        viewerInfoButton = UIButton(frame: CGRectMake(buttonMainSize.x/2,buttonMainSize.y/2, screenWidth * 2 / 10,screenWidth * 2 / 10  ))
        viewerInfoButton.layer.cornerRadius = viewerInfoButton.frame.width / 2
        viewerInfoButton.center =  CGPointMake(buttonMainSize.x * 0.75,buttonMainSize.y * 0.25)
        viewerInfoButton.backgroundColor = UIColor.whiteColor()
        viewerInfoButton.setTitle("Info", forState: UIControlState.Normal)
        viewerOpeView.addSubview(viewerInfoButton)
        */
        
        
       editButton.enabled = true
        
        // ピンチ
        let myPinchGesture = UIPinchGestureRecognizer(target: self, action: "pinchGesture:")
        self.view.addGestureRecognizer(myPinchGesture)
        //ジェスチャーの追加
        viewerOpeView.addGestureRecognizer(myPan)
        viewerOpeView.addGestureRecognizer(swipeLeft)
        viewerOpeView.addGestureRecognizer(swipeRight)
        viewerOpeView.addGestureRecognizer(stampTap)
         viewerOpeView.addGestureRecognizer(doubleTap)
        
        
        self.view.addGestureRecognizer(swipeUp)
        self.view.addGestureRecognizer(swipeDown)
        //addImageButton.setTitle( "change Image", forState: UIControlState.Normal)
        notificationLabel.center = notificationtRedyCenter
        
        
        
        self.view.addSubview(scanSpeedSetCircle)
        self.view.addSubview(stampSpeedSetCircle)
        self.view.addSubview(lightBarSizeSetCircle)
        self.view.addSubview(scanSpeedInfoTxt)
        self.view.addSubview(stampSpeedInfoTxt)
        self.view.addSubview(lightBarSizeInfoTxt)
        
        isFirstSet = false
      }

      cameraView.image = pickedImage
      cameraView.alpha = 0.3
      opeImage = UIImageView(frame:viewerOpeView.frame)
      opeImage.tag = 1
      opeImage.userInteractionEnabled = true
      opeImage.image = pickedImage
      opeImage.frame.origin=CGPointMake(0,0)
      print(viewerOpeView.subviews.count)
      
      viewerOpeView.addSubview(opeImage)
      //viewerOpeView.sendSubviewToBack(opeImage)
      //viewerOpeView.bringSubviewToFront(viewerInfoButton)
      
      viewerOpeView.bringSubviewToFront(scanintervalLabel)
      viewerOpeView.bringSubviewToFront(stampIntervalLabel)
      viewerOpeView.bringSubviewToFront(lightBarSizeLabel)
      
      intervaltime = intervalTimeSet(cameraView, speed:1.5)
      print("intervaltime:",intervaltime)

      
      scanintervalLabel.text = String(format: "%.1fsec",intervaltime)
      stampIntervalLabel.text = "1/60"
      lightBarSizeLabel.text = String(format: "%.0fpx",(viewerSettingData.2))

      scanSpeedSetCircle.text = scanintervalLabel.text
      stampSpeedSetCircle.text = stampIntervalLabel.text
      lightBarSizeSetCircle.text = lightBarSizeLabel.text
      
      cameraView.frame = scanSizeSet(cameraView)
      
      print("frame:x=",cameraView.frame.origin.x,"frame:y=",cameraView.frame.origin.y,"frame:heigth=",cameraView.frame.size.height,"frame:width=",cameraView.frame.size.width)
      
      self.view.bringSubviewToFront(viewerOpeView)
      self.view.bringSubviewToFront(scanintervalLabel)
      
    }
    
    //閉じる処理
    imagePicker.dismissViewControllerAnimated(true, completion: nil)
    //Label.text = "Tap the [Save] to save a picture"
    
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    let touch = touches.first
     print("タッチした画像のタグ:",touch?.view?.tag)
    // タップした座標を取得する
    let tapLocation = touch!.locationInView(self.view)
    print("タッチした座標:",tapLocation)
  }
  
  /*
  @IBAction func savePic(sender: AnyObject) {
    
    let image:UIImage! = cameraView.image
    
    if image != nil {
      UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    else{
      Label.text = "image Failed !"
    }
    
  }
  */
  
  
  
  // 書き込み完了結果の受け取り
  func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
    print("1")
    
    if error != nil {
      print(error.code)
     
    }
    else{
     
    }
  }


  func showAlbum(sender:UIButton){
    let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.PhotoLibrary
    
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
      // インスタンスの作成
      let cameraPicker = UIImagePickerController()
      cameraPicker.sourceType = sourceType
      cameraPicker.delegate = self
      self.presentViewController(cameraPicker, animated: true, completion: nil)
      
          }
    else{
      
    }
    
  }
  
  func motionProcess(){
    
    // MotionManagerを生成.
    myMotionManager = CMMotionManager()
    
    // 更新周期を設定.
    //加速度
    myMotionManager.accelerometerUpdateInterval = 0.1
    //ジャイロ
    myMotionManager.gyroUpdateInterval = 0.1;
    
    
    // 加速度の取得を開始.
    /*    myMotionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler:{(accelerometerData:CMAccelerometerData?, error:NSError?) -> Void in
     self.myXLabel.text = "x=\(accelerometerData!.acceleration.x)"
     self.myYLabel.text = "y=\(accelerometerData!.acceleration.y)"
     self.myZLabel.text = "z=\(accelerometerData!.acceleration.z)"
     })
     */
    //ハンドラの設定
    let accelerometerHandler:CMAccelerometerHandler = {
      (data:CMAccelerometerData?, error:NSError?) -> Void in
      
      //ログにx,y,zの加速度を表示
//      self.accelX.text = "x=".stringByAppendingFormat("%.2f", data!.acceleration.x)
//      self.accelY.text = "y=".stringByAppendingFormat("%.2f", data!.acceleration.y)
//      self.accelZ.text = "z=".stringByAppendingFormat("%.2f", data!.acceleration.z)
      
      //print("x:\(data!.acceleration.x) y:\(data!.acceleration.y) z:\(data!.acceleration.z)")
//      print("\(data!.acceleration.x)\t\(data!.acceleration.y)\t\(data!.acceleration.z)")
      
      }
    
    
    //取得開始して、上記で設定したハンドラを呼び出し、ログを表示する
    myMotionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!,withHandler:accelerometerHandler)
    
    
    let gyroHandler:CMGyroHandler = {(data:CMGyroData?,error:NSError?)-> Void in
      
      //print("GYRO_x:\(data!.rotationRate.x) y:\(data!.rotationRate.y) z:\(data!.rotationRate.z)")
      //print("\(data!.rotationRate.x)\t\(data!.rotationRate.y)\t\(data!.rotationRate.z)")
//      if (data!.rotationRate.z > 0) {
//self.slideViewStart()
//        print("+")
//      }else{
//      self.slideViewBack()
//        print("-")
//      }
//      

        //self.slideViewValue(CGFloat(data!.rotationRate.z))
      
        
        //
//      self.rotaionX.text = "x=".stringByAppendingFormat("%.2f", data!.rotationRate.x)
//      self.rotaionY.text = "y=".stringByAppendingFormat("%.2f", data!.rotationRate.y)
//      self.rotaionZ.text = "z=".stringByAppendingFormat("%.2f", data!.rotationRate.z)
      
    }
    myMotionManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()!,withHandler:gyroHandler)
    
  }
  
 /*
  func slideViewStart(){
    if(cameraView.frame.origin.x > step * 9.5  - cameraView.frame.size.width){
    cameraView.frame.origin = CGPointMake(cameraView.frame.origin.x - step ,0)
      print("frame:x=",cameraView.frame.origin.x)
      
    }
}
  func slideViewBack(){
    if(cameraView.frame.origin.x < step  * 9.5){
    cameraView.frame.origin = CGPointMake(cameraView.frame.origin.x + step ,0)
    print("frame:x=",cameraView.frame.origin.x)
    }
  }
  func slideViewValue(value:CGFloat){
    if((cameraView.frame.origin.x < step  * 9.5 && value > 0 ) || (cameraView.frame.origin.x > step * 9.5  - cameraView.frame.size.width && value < 0 )){
    cameraView.frame.origin = CGPointMake(cameraView.frame.origin.x + step * value * speed ,0)
    print("frame:x=",-1 * cameraView.frame.origin.x / cameraView.frame.width)
      scanXdataLabel.text = String(format: "%.2f", -1 * cameraView.frame.origin.x / cameraView.frame.width)
    }
    
  }
 */
  
  func prePlay(style:Int8,mode:Int8,speed:Int){
    phaize = 1
    print("phaze:",self.phaize)
    
    
    
    // アニメーション処理
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.7 * Double(NSEC_PER_SEC)))
    print("prePlay")
    
    addImageButton.enabled = false
    myToolBar.alpha = 0
  
    
    var forValue:CGFloat!
    var fromValue:CGFloat!
    
    switch style {
    case 1:
      forValue = 1.5
      fromValue = -0.5
      
      count1Label.alpha = 1
      count2Label.alpha = 1
      count3Label.alpha = 1
    case 2:
      print("stamp")
      fromValue = 0.5
      forValue = 0.5
      count1Label.alpha = 0
      count2Label.alpha = 0
      count3Label.alpha = 0
    default:
      count1Label.alpha = 1
      count2Label.alpha = 1
      count3Label.alpha = 1
      forValue = -0.5
      fromValue = 1.5
      break
    }
    
  
    //toFront
    self.view.bringSubviewToFront(count1Label)
    self.view.bringSubviewToFront(count2Label)
    self.view.bringSubviewToFront(count3Label)
    self.view.bringSubviewToFront(viewerOpeView)
    
    
    count1Label.center.x = fromValue * screenWidth
    count2Label.center.x = fromValue * screenWidth
    count3Label.center.x = fromValue * screenWidth
    
  if(style != 2){
    UIView.animateWithDuration(0.3,
                               animations: {() -> Void in
                                self.viewerOpeView.center.x = forValue * self.screenWidth
                                self.count3Label.center.x = self.screenWidth/2
                                //一度、真っ黒に扉が閉じる
                                self.frameViewR.frame.origin.x = self.step * 10
                                self.frameViewL.frame.origin.x = 0
      },completion: { finished in
        
        // 遅延処理
            dispatch_after(delayTime, dispatch_get_main_queue()) {
              print("２秒前")
            UIView.animateWithDuration(0.3,animations: {() -> Void in
              self.count3Label.center.x = forValue * self.screenWidth
              self.count2Label.center.x = self.screenWidth/2
              },completion: { finished in
                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.7 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                  print("１秒前")
                    UIView.animateWithDuration(0.3,animations: {() -> Void in
                      self.count2Label.center.x = forValue * self.screenWidth
                      self.count1Label.center.x = self.screenWidth/2
                      },completion: { finished in
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.7 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                          print("0秒前")
                          UIView.animateWithDuration(0.3,animations: {() -> Void in
                            self.count1Label.center.x = forValue * self.screenWidth
                            },completion: { finished in
                              /*self.count3Label.frame.origin.x =  self.screenWidth
                               self.count2Label.frame.origin.x =  self.screenWidth
                               self.count1Label.frame.origin.x =  self.screenWidth
                               */
                              self.viewerOpeView.center.x = fromValue * self.screenWidth
                              self.playimage(style,mode: mode,speed: speed)
                          })
                        }//遅延
                    })
                }//遅延
            })
        }//遅延
      })
  }else{
    UIView.animateWithDuration(0.3,
                               animations: {() -> Void in
                          
                                /*self.viewerOpeView.frame.size.width = self.screenHeight
                                self.viewerOpeView.frame.size.height = self.screenHeight
                                self.viewerOpeView.center = self.buttonMainCenter
                                self.viewerOpeView.layer.cornerRadius = self.screenHeight/2
                                 */
                                self.viewerOpeView.alpha = 0
                                
                        
                                
                                //一度、真っ黒に扉が閉じる
                                self.frameViewR.frame.origin.x = self.step * 10
                                self.frameViewL.frame.origin.x = 0
                                
      },completion: { finished in
        // 遅延処理
        self.count3Label.alpha = 1
        dispatch_after(delayTime, dispatch_get_main_queue()) {
          print("２秒前")
          UIView.animateWithDuration(0.3,animations: {() -> Void in
            self.count3Label.alpha = 0
            
            },completion: { finished in
              self.count2Label.alpha = 1
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.7 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                print("１秒前")
                UIView.animateWithDuration(0.3,animations: {() -> Void in
                  self.count2Label.alpha = 0
                  },completion: { finished in
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                      print("0秒前")
                          self.viewerOpeView.center.x = fromValue * self.screenWidth
                          self.playimage(style,mode: mode,speed: speed)
                    }//遅延
                })
              }//遅延
          })
        }//遅延
    })
  }//ifelse-end
}
  
  
  func playimage(style:Int8,mode:Int8,speed:Int){

    // アニメーション処理
  print("animation")
  cameraView.frame = scanSizeSet(cameraView)
    cameraView.alpha = 1
  let rightImagePoint :CGFloat! = self.step  * 9.5 - self.cameraView.frame.width - (self.viewerSettingData.2)
  let leftImagePoint : CGFloat! = self.step  * 10 + (self.viewerSettingData.2)
  
  
  switch style {
    case 0:
    scanPlay(leftImagePoint, endX: rightImagePoint,mode:mode,speed:speed)
    case 1:
    scanPlay(rightImagePoint, endX: leftImagePoint,mode:mode,speed:speed)
    default:
    stampPlay(mode,speed:speed)
    break
  }
}
  
  
  func scanPlay(startX:CGFloat,endX:CGFloat,mode:Int8,speed:Int){
    cameraView.contentMode = .ScaleToFill
    cameraView.frame.origin.x = startX
    scanPlayAtoB = [startX,endX]
    intervaltime = intervalTimeSet(cameraView,speed:scanSpeedTable[speed])
    
      UIView.animateWithDuration(0.1,
                               animations: {() -> Void in
                                //扉オープん
                                self.frameViewR.frame.origin.x = self.step * 10 + (self.viewerSettingData.2)
                                self.frameViewL.frame.origin.x = -1 * (self.viewerSettingData.2)
      },completion: { finished in
        if(mode == 0){
          self.phaize = 2
          print("phaze:",self.phaize)
          //single mode
        UIView.animateWithDuration(self.intervaltime,
          animations: {() -> Void in
            self.cameraView.frame.origin.x = endX
          },completion: { finished in
                self.closingPlayImage()
        })
        }else if(mode == 1 ){
          self.phaize = 6
           print("phaze:",self.phaize)
          //self.view.addGestureRecognizer(self.viewTap)
          
          //loop mode
          UIView.animateWithDuration(self.intervaltime, delay: 0.0,
            options: UIViewAnimationOptions.Repeat, animations: { () -> Void in
              self.cameraView.frame.origin.x = endX
            }, completion: nil)
        }else{
          //tapping restart mode
          self.phaize = 2
          print("phaze:",self.phaize)
          print("tapping restart mode")
         // self.view.addGestureRecognizer(self.viewTap)
          self.oneSecondTimer()
          //self.view.addGestureRecognizer(self.swipeDown)
        }//ifelse
    })
    
  }
  func oneSecondTimer(){
    if(phaize == 2){
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
        self.noActionTimer = self.noActionTimer + 1
        print("timer:",self.noActionTimer)
        if(self.noActionTimer > 5){self.notificationOpe(0)}
        self.oneSecondTimer()
      }
    }else if(phaize == 4 || phaize == 5){
    noActionTimer = 0
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
        print("timer_is_Stanby")
        self.oneSecondTimer()
      }
    }else if (phaize == 9){
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
        self.noActionTimer = self.noActionTimer + 1
        print("timer:",self.noActionTimer)
        if(self.noActionTimer > 5){self.notificationOpe(0)}
        self.oneSecondTimer()
      }
    }else if(phaize == 5){
      noActionTimer = 0
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
        print("timer_is_Stanby")
        self.oneSecondTimer()
      }
 
    
    
    }else{
      noActionTimer = 0
      print("timer Ended")
    }
  }
  
  func tenCentiSecondTimer(){
    if(phaize==0){
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
        self.noActionTimer = self.noActionTimer + 1
        print("tenCStimer:",self.noActionTimer)
        if(self.noActionTimer > 3){
          UIView.animateWithDuration(0.5,
                                     animations: {() -> Void in
                                      self.cameraView.alpha = 0.5
                                      self.viewerOpeView.alpha = 1.0
                                      self.myToolBar.alpha = 1
            },completion: { finished in
              self.barSizeChangeAnimationCompleted = true
              self.noActionTimer = 0
              
          })
        }else{
        self.tenCentiSecondTimer()
        }
    }//遅延
    }else if (phaize == 8){
      
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
        self.noActionTimer = self.noActionTimer + 1
        print("tenCStimer:",self.noActionTimer)
       
   if(self.noActionTimer > 20){
          UIView.animateWithDuration(0.5,
                                     animations: {() -> Void in
                                      self.cameraView.alpha = 0.5
                                      self.viewerOpeView.center.y =  self.buttonMainCenter.y
                                      self.myToolBar.alpha = 1
                                      self.editParametorViewChange(1)
            },completion: { finished in
              self.barSizeChangeAnimationCompleted = true
              self.noActionTimer = 0
              self.phaize = 0
              print("phaze:",self.phaize)
          })
        }else{
          self.tenCentiSecondTimer()
        }
      }//遅延

      
    }//if phaize ==8
  }

  func notificationOpe(textNum:Int){
    let text:String
    switch textNum{
    case 0:
      text="Tap screen -> Fire!\n\nor\n\n Swipe Down! -> quit"
      print(text)
      notificationLabel.text = text
    default:
      break
    }
  self.notificationPopUp()
    
  }
  func notificationPopUp(){
    phaize = 5
    print("phaze:",self.phaize)
    print("notificationPopUp()")
    UIView.animateWithDuration(0.3,
                               animations: {() -> Void in
                                self.notificationLabel.center = self.buttonMainCenter
    })
  }
  func notificationClose(){
    
    print("notificationClose()")
    UIView.animateWithDuration(0.3,
                               animations: {() -> Void in
                                self.notificationLabel.center = self.notificationtRedyCenter
    })
  }
  
  func replayTapped(gestureRecognizer: UITapGestureRecognizer){
    if(phaize != 4){
      if(phaize == 5){self.notificationClose()}
      
      phaize = 4
      print("phaze:",self.phaize)
    }
    noActionTimer = 0
    cameraView.layer.removeAllAnimations()
    cameraView.frame.origin.x = scanPlayAtoB[0]
        UIView.animateWithDuration(self.intervaltime,
          animations: {() -> Void in
            self.cameraView.frame.origin.x = self.scanPlayAtoB[1]
          },completion: { finished in
            self.phaize = 2
            print("phaze:",self.phaize)
            self.noActionTimer = 0
        })
}
  
  func backMenu(){
    self.cameraView.frame.origin.x = self.step * 10 - (self.viewerSettingData.2)
    UIView.animateWithDuration(0.3, animations: { () -> Void in
      self.viewerOpeView.alpha = 1.0
      self.myToolBar.alpha = 1
      
      self.viewerOpeView.center = self.buttonMainCenter
      //扉オープん
      self.frameViewR.frame.origin.x = self.step * 10 + (self.viewerSettingData.2)
      self.frameViewL.frame.origin.x = -1 * (self.viewerSettingData.2)
      
      self.cameraView.alpha = 0.5

      },completion: { finished in
     
          self.addImageButton.enabled = true
        
        self.phaize = 0
        print("phaze:",self.phaize)
    })
}
  func closingPlayImage() {
    print("closingPlayImage()")
    cameraView.layer.removeAllAnimations()
    UIView.animateWithDuration(0.3, animations: { () -> Void in
      //一度、真っ黒に扉が閉じる
      self.frameViewR.frame.origin.x = self.step * 10
      self.frameViewL.frame.origin.x = 0
      },completion: { finished in
        self.phaize = 3
        print("phaze:",self.phaize)
        self.cameraView.frame.origin.x = self.step * 10 - (self.viewerSettingData.2)
        
    })
  }
  func closingTapScanMode() {
    print("closingTapScanMode()")
    UIView.animateWithDuration(0.3, animations: { () -> Void in
      //一度、真っ黒に扉が閉じる
      self.frameViewR.frame.origin.x = self.step * 10
      self.frameViewL.frame.origin.x = 0
      },completion: { finished in
        self.backMenu()
    })
  }
  
  func stopPlayTapped(gestureRecognizer: UITapGestureRecognizer){
    print("stopPlayTapped")
    cameraView.layer.removeAllAnimations()
    self.closingPlayImage()
  }
  
  func stampPlay(mode:Int8,speed:Int){
    switch mode {
    case 0:
      self.phaize = 7
      print("phaze:",self.phaize)
      
      //扉を消して画像を表示
      frameViewR.alpha=0
      frameViewL.alpha=0
      //イメージをフルスクリーン
      cameraView.contentMode = .ScaleAspectFit
      cameraView.frame = CGRectMake(0,0,screenWidth,screenHeight)
      
      
      //画像表示
      let time:Double = stampSpeedTable[speed] * Double(NSEC_PER_SEC)
      print("speed:",stampSpeedTable[Int(speed)])
      
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(time)), dispatch_get_main_queue()) {
        //self.cameraView.alpha = 0
        //self.view.addGestureRecognizer(self.viewTap)
        self.frameViewR.alpha=1
        self.frameViewL.alpha=1
        self.cameraView.contentMode = .ScaleToFill
        self.phaize = 3
        print("phaze:",self.phaize)
      }
    default:
      self.phaize = 9
      print("phaze:",self.phaize)
      //helpを出すタイマースタート
      self.oneSecondTimer()
      //イメージをフルスクリーン
      cameraView.contentMode = .ScaleAspectFit
      cameraView.frame = CGRectMake(0,0,screenWidth,screenHeight)
      stampTime = stampSpeedTable[speed] * Double(NSEC_PER_SEC)
      
    }
    
  }
  
  func  stampFire(){
    //扉を消して画像を表示
    frameViewR.alpha=0
    frameViewL.alpha=0
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(stampTime)), dispatch_get_main_queue()) {
      
      self.frameViewR.alpha=1
      self.frameViewL.alpha=1
  }

    
  }
  /*
   ピンチイベントの実装.
   */
  internal func pinchGesture(sender: UIPinchGestureRecognizer){
    if(phaize == 9 || phaize == 5 || phaize == 7 || phaize == 1 || phaize == 3 || phaize == 4 ){
      print("pinchを無視")
    return
    }
    let firstPoint = sender.scale
    let secondPoint = sender.velocity
    self.barSizeChanged()
  print("pichi:\\t\(firstPoint)\t\(secondPoint)")
      (viewerSettingData.2) = (viewerSettingData.2) + secondPoint / 2   * step
    if((viewerSettingData.2) < 1){
      (viewerSettingData.2) = 1
    }else if((viewerSettingData.2) > (screenWidth / 2 - 1)){
    (viewerSettingData.2) = (screenWidth / 2 - 1)
    }
    
    
    frameViewR.frame.origin.x = step * 10 + (viewerSettingData.2)
    frameViewL.frame.origin.x = -1 * (viewerSettingData.2)
    cameraView.frame.origin.x = step * 10 - (viewerSettingData.2)
    lightBarSizeLabel.text = String(format: "%.0fpx",(viewerSettingData.2))
    lightBarSizeSetCircle.text = String(format: "%.0fpx",(viewerSettingData.2))
    
    

  }
  
  func barSizeChanged(){
     self.noActionTimer = 0
    if (barSizeChangeAnimationCompleted == false){return}
    if (phaize != 0 ){return}
    print("barSizeChanged-Animation Start")
    
    barSizeChangeAnimationCompleted = false
    UIView.animateWithDuration(0.3,
                               animations: {() -> Void in
                                self.cameraView.alpha = 1
                                self.viewerOpeView.alpha = 0
                                self.myToolBar.alpha = 0
      },completion: { finished in
       // self.barSizeChangeAnimationCompleted = true
        self.tenCentiSecondTimer()
    })

  
  
  }
func viewTapped(gestureRecognizer: UITapGestureRecognizer){
  print("viewtapped! phaize:",phaize)
  if(phaize == 3){
    self.backMenu()
  }else if(phaize == 4){
    noActionTimer = 0
    cameraView.layer.removeAllAnimations()
    cameraView.frame.origin.x = scanPlayAtoB[0]
    UIView.animateWithDuration(self.intervaltime,
                               animations: {() -> Void in
                                self.cameraView.frame.origin.x = self.scanPlayAtoB[1]
      },completion: { finished in
        self.phaize = 2
        print("phaze:",self.phaize)
        self.noActionTimer = 0
    })
  }else if(phaize == 2){
    noActionTimer = 0
    phaize = 4
     print("phaze:",self.phaize)
    cameraView.layer.removeAllAnimations()
    cameraView.frame.origin.x = scanPlayAtoB[0]
    UIView.animateWithDuration(self.intervaltime,
                               animations: {() -> Void in
                                self.cameraView.frame.origin.x = self.scanPlayAtoB[1]
      },completion: { finished in
        self.phaize = 2
        print("phaze:",self.phaize)
        self.noActionTimer = 0
    })
  }else if(phaize == 5){
    //notification表示ちゅう
    self.notificationClose()
    if(viewerStyleMode[0] != 2){
      phaize = 2
      print("phaze:",self.phaize)
    }else{
      phaize = 9
      print("phaze:",self.phaize)
    }
    print("phaze:",self.phaize)
  }else if(phaize == 6){
    cameraView.layer.removeAllAnimations()
    self.closingPlayImage()
  }else if(phaize == 0){
  print("phase 0 tap")
  }else if(phaize == 9){
    // 9 = tap Stamp mode 
    noActionTimer = 0
    stampFire()
  }else if(phaize == 8){
    UIView.animateWithDuration(0.5,
                               animations: {() -> Void in
                                self.cameraView.alpha = 0.5
                                self.viewerOpeView.center.y =  self.buttonMainCenter.y
                                self.myToolBar.alpha = 1
                                self.editParametorViewChange(1)
                                
      },completion: { finished in
        self.barSizeChangeAnimationCompleted = true
        self.noActionTimer = 0
        self.phaize = 0
        print("phaze:",self.phaize)
    })

  }
  
}
  /*
   パン.
   */
  internal func panGesture(sender: UIPanGestureRecognizer){
    if(phaize > 0){
     print("Pan return")
      return
    }
    
    
    
    
    let movesize = sender.translationInView(self.view)
    print(movesize.x,sender.numberOfTouches())
    //let maxsize:CGFloat!
    //パンした指についてくる。離すと戻る。
    let modeNum:Int8
    if(sender.numberOfTouches() > 0){
      
        viewerOpeView.center = CGPointMake(screenWidth/2 + movesize.x ,screenHeight / 10 * 2.5 + screenWidth * 0.4 + movesize.y )
        modeNum = Int8(sender.numberOfTouches()-1)
      
      
        if( viewerOpeView.center.x < screenWidth/8){
          print("phaze:",self.phaize)
          
          self.prePlay(0, mode: modeNum,speed:(viewerSettingData.0))
          
          viewerStyleMode = [0,modeNum]
        }else if(viewerOpeView.center.x > screenWidth * 0.8){
            print("start direction Right, mode =" ,modeNum)
          self.prePlay(1, mode: modeNum,speed:(viewerSettingData.0))
          viewerStyleMode = [1,modeNum]
          }
    }else{
      if(phaize == 0){
        print("ボタンバック")
        UIView.animateWithDuration(0.3, animations: { () -> Void in
        self.viewerOpeView.center = self.buttonMainCenter
        })
      }
    }//else
 
  
    /* 
     //ズームアップするUI
    if(sender.numberOfTouches() > 0){
      if (movesize.x > movesize.y){maxsize = movesize.x}else{maxsize = movesize.y}
       viewerOpeView.frame.size = CGSizeMake(buttonMainSize.x + maxsize , buttonMainSize.y + maxsize)
    }else{
      UIView.animateWithDuration(0.3, animations: { () -> Void in
        self.viewerOpeView.frame.size = CGSizeMake(self.buttonMainSize.x,self.buttonMainSize.y)
        
        }
      )
    }//else
    */
}
  
  
  /*
   パン.
   */
  internal func setPanGesture(sender: UIPanGestureRecognizer){
    let movesizeY = Int(sender.translationInView(self.view).y/20 )
    let ui_label: UILabel = sender.view as! UILabel
 
    noActionTimer = 0

    switch sender.view?.tag{
    case 11?:
      print("tag11")
      var diffPoint:Int = (viewerDataBuffer.0) + movesizeY
      print("tag11-0",diffPoint)
      
      if(diffPoint < 0){
        diffPoint = 0
      }else if(diffPoint > 5){
        diffPoint = 5
      }
      print("tag11-1",diffPoint)
      if(sender.numberOfTouches() > 0){
        ui_label.text = String(format: "%.2fsec",intervalTimeSet(cameraView,speed:scanSpeedTable[diffPoint]))
        
      }else{
        ui_label.text = String(format: "%.2fsec",intervalTimeSet(cameraView,speed:scanSpeedTable[diffPoint]))
        (viewerSettingData.0) = diffPoint
         (viewerDataBuffer.0) = (viewerSettingData.0)
        scanintervalLabel.text = String(format: "%.2fsec",intervalTimeSet(cameraView,speed:scanSpeedTable[diffPoint]))

      }

      
    case 12?:
      print("tag12")
      var diffPoint:Int = (viewerDataBuffer.1) + movesizeY
      print("tag12-0",diffPoint)
      
      if(diffPoint < 0){
        diffPoint = 0
      }else if(diffPoint > 7){
        diffPoint = 7
      }
      print("tag12-1",diffPoint)
      
      if(sender.numberOfTouches() > 0){
        ui_label.text = stampSpStringTable[diffPoint]
      }else{
        ui_label.text = stampSpStringTable[diffPoint]
        (viewerSettingData.1) = diffPoint
        (viewerDataBuffer.1) = (viewerSettingData.1)
        stampIntervalLabel.text = stampSpStringTable[diffPoint]
      }
    default:
      print("tag13")
      var addedPoint:CGFloat = (viewerDataBuffer.2) + sender.translationInView(self.view).y
      
      if(addedPoint < 1){
          addedPoint = 1
        }else if(addedPoint > (screenWidth / 2 - 1)){
          addedPoint = (screenWidth / 2 - 1)
        }
      print("tag13-(-1)",addedPoint)
      
      if(sender.numberOfTouches() > 0){
       ui_label.text = String(format: "%.0fpx",addedPoint)
        frameViewR.frame.origin.x = step * 10 + addedPoint
        frameViewL.frame.origin.x = -1 * addedPoint
        cameraView.frame.origin.x = step * 10 - addedPoint
      }else{
        print("tag13-0",addedPoint)
        ui_label.text = String(format: "%.0fpx",addedPoint)
        print("tag13-1",addedPoint)
        (viewerSettingData.2) = addedPoint
        
        (viewerDataBuffer.2) = (viewerSettingData.2)
        print("tag13-2",(viewerDataBuffer.2))
        lightBarSizeLabel.text = String(format: "%.0fpx",(viewerDataBuffer.2))
        print("tag13-3", (viewerSettingData.2))
        frameViewR.frame.origin.x = step * 10 + (viewerSettingData.2)
        frameViewL.frame.origin.x = -1 * (viewerSettingData.2)
        cameraView.frame.origin.x = step * 10 - (viewerSettingData.2)
        lightBarSizeLabel.text = String(format: "%.0fpx",(viewerSettingData.2))
        print("buffer:",(viewerDataBuffer.2),"addpoint:",addedPoint)

      }

      
      break
    }
    
    if(sender.numberOfTouches() > 0){
      sender.view?.alpha = 1.0
      sender.view?.backgroundColor = UIColor.blackColor()
      
      print("panning:",movesizeY)
    }else{
      sender.view?.alpha = 0.5
      sender.view?.backgroundColor = UIColor.clearColor()
      print("end:",movesizeY)
      
    }
    
    
  }
  
  func editParametorViewChange(direction:Int){
     let setYCenter:CGFloat!
    if(direction == 0){
     setYCenter = buttonMainCenter.y}
    else{
      setYCenter = self.screenHeight+self.buttonMainSize.x/6
    }
    let textInfoSukima:CGFloat = scanSpeedSetCircle.frame.size.height
  scanSpeedSetCircle.center.y = setYCenter
  stampSpeedSetCircle.center.y = setYCenter
  lightBarSizeSetCircle.center.y = setYCenter
    scanSpeedInfoTxt.center.y = setYCenter  + textInfoSukima
   stampSpeedInfoTxt.center.y = setYCenter + textInfoSukima
    lightBarSizeInfoTxt.center.y = setYCenter + textInfoSukima
  }
  
  internal func  editTapped(sender:UIButton){
    if (barSizeChangeAnimationCompleted == false){return}
    print(" editTapped")
    phaize = 8
     print("phaze:",self.phaize)
    self.noActionTimer = 0
    viewerDataBuffer = viewerSettingData
  barSizeChangeAnimationCompleted = false
    UIView.animateWithDuration(0.3,
                               animations: {() -> Void in
                                self.viewerOpeView.center.y = -1 * self.buttonMainSize.x
                                self.editParametorViewChange(0)
                                self.cameraView.alpha = 1
                                self.myToolBar.alpha = 0
      },completion: { finished in
         self.tenCentiSecondTimer()
    })

  }
  
  /*
   swipe.
   */
internal func didSwipe(sender: UISwipeGestureRecognizer){
    let point = sender.locationInView(self.view)
    print(point)
  
  
    switch phaize {
    case 0:
    if sender.direction == .Right {
      print("Right")
      self.prePlay(1,mode:0,speed:(viewerSettingData.0))
      viewerStyleMode = [1,0]
    }
    else if sender.direction == .Left {
      print("Left")
      prePlay(0, mode: 0,speed:(viewerSettingData.0))
      viewerStyleMode = [0,0]
    } else if sender.direction == .Up {
      print("Up")
      if (barSizeChangeAnimationCompleted == false){return}
      print(" editTapped")
      phaize = 8
      print("phaze:",self.phaize)
      self.noActionTimer = 0
      viewerDataBuffer = viewerSettingData
      barSizeChangeAnimationCompleted = false
      UIView.animateWithDuration(0.3,
                                 animations: {() -> Void in
                                  self.viewerOpeView.center.y = -1 * self.buttonMainSize.x
                                  self.editParametorViewChange(0)
                                  self.cameraView.alpha = 1
                                  self.myToolBar.alpha = 0
        },completion: { finished in
          self.tenCentiSecondTimer()
      })

    }


    case 2 :
    if(sender.direction == .Down){
      print("did SWipe case2 :swipeDpwn")
      self.closingTapScanMode()
      }
    case 4 :
      if(sender.direction == .Down){
        print("did SWipe case4 :swipeDpwn")
        self.closingTapScanMode()

      }
    case 5 :
      if(sender.direction == .Down){
      print("did SWipe case5 :swipeDpwn")
        self.notificationClose()
        //self.closingTapScanMode()
      }
    case 8 :
      if(sender.direction == .Down){
        print("did SWipe case8 :swipeDpwn")
        UIView.animateWithDuration(0.5,
                                   animations: {() -> Void in
                                    self.cameraView.alpha = 0.5
                                    self.viewerOpeView.center.y =  self.buttonMainCenter.y
                                    self.myToolBar.alpha = 1
                                    self.editParametorViewChange(1)
                                    
          },completion: { finished in
            self.barSizeChangeAnimationCompleted = true
            self.noActionTimer = 0
            self.phaize = 0
            print("phaze:",self.phaize)
        })

      }
    case 9 :
      if(sender.direction == .Down){
        self.cameraView.contentMode = .ScaleToFill
        self.backMenu()
      }

    
    default:
      break
  }
  
}
  
  /*
   stamp tap
 */
  internal func prePreStampPlay(sender:UITapGestureRecognizer){
    print(sender.numberOfTouches())
    if(sender.numberOfTouches() == 1 ){
    prePlay(2, mode: 0, speed:(viewerSettingData.1))
      viewerStyleMode = [2,3]
    }else if(sender.numberOfTouches() == 2){
      print("ダブルタップ！")
      prePlay(2, mode: 1, speed:(viewerSettingData.1))
    viewerStyleMode = [2,4]
    }
  }
  
  internal func tappdDouble(sender:UITapGestureRecognizer){
    print("ダブルタップ！")
    prePlay(2, mode: 1, speed:(viewerSettingData.1))
  }

  
  /*ボリュームボタンが押された時の処理*/
 /* 
 func listenVolumeButton(){
    let audioSession = AVAudioSession.sharedInstance()
    audioSession.setActive(true)
    
    
    
    //audioSession.setActive(true, error: nil)
  
    audioSession.addObserver(self, forKeyPath: "outputVolume",
                                   options: NSKeyValueObservingOptions.New, context: nil)
  }
  override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject,
                change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
    if keyPath == "outputVolume"{
      print("got in here")
    }
  }
*/
  
  //表示列
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 2
  }
  
  //表示個数
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    
    if (component == 0){
      return stampSpStringTable.count
    }else if (component == 1){
      return stampSpStringTable.count
    }
    return 0;
  }
  
  //表示内容
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
      if (component == 0){
            return stampSpStringTable[row] as String
        }else if (component == 1){
            return stampSpStringTable[row] as String
        }
    return "";
  }
  
  //選択時
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
    if (component == 0){
      print("列: \(row)")
      print("値: \(stampSpStringTable[row])")
    }else if (component == 1){
      print("列: \(row)")
      print("値: \(stampSpStringTable[row])")
    }
    
  }
  
  
}