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
    self.textColor = UIColor(red:0, green:0.6627,blue:0.6157, alpha:1.0)
    self.backgroundColor = UIColor.blackColor()
    self.layer.masksToBounds = true
    self.layer.cornerRadius = self.frame.width / 2
    self.layer.borderColor = UIColor(red:0, green:0.6627,blue:0.6157, alpha:1.0)
.CGColor
   self.layer.borderWidth = self.frame.width / 30
    self.textAlignment = NSTextAlignment.Center
  }
  func infoLabelformat(){
    self.textColor = UIColor(red:0, green:0.6627,blue:0.6157, alpha:1.0)
    self.backgroundColor = UIColor.clearColor()
    self.layer.masksToBounds = true
    self.layer.cornerRadius = self.frame.width / 2
    self.layer.borderColor = UIColor(red:0, green:0.6627,blue:0.6157, alpha:1.0)
.CGColor
    self.layer.borderWidth = self.frame.width / 15
    self.alpha = 1.0
    self.textAlignment = NSTextAlignment.Center
    self.userInteractionEnabled = true
    self.numberOfLines = 0
    self.adjustsFontSizeToFitWidth=true
  }
}


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIScrollViewDelegate{
 // @IBOutlet weak var cameraView: UIImageView!

  var screenWidth : CGFloat!
  var screenHeight : CGFloat!
  var screenShortSize :CGFloat!
  var screenLargeSize :CGFloat!
  //var scale: CGFloat!
  //var aspectScale: CGFloat! = 1.0
  var step: CGFloat! = 10
  
  //var speed: CGFloat! = 10.0
  var Iwidth: CGFloat!
  var Iheight: CGFloat!
  var intervaltime: NSTimeInterval! = 1.0
  var buttonMainCenter:CGPoint!
  var buttonMainSize:CGPoint!
  var preferenceCircleRect:CGRect!
  var notificationtRedyCenter:CGPoint!
  //var lightBarWidth:CGFloat! = 10
  var scanPlayAtoB:[CGFloat]!
  var isFirstSet:Bool = true
  var barSizeChangeAnimationCompleted:Bool = true
  var stampTime:Double = 0.1 //stamp mode1の時に使う
  var defaultScanStep:Double = 60 //stepNum per Second
  var themeColor:UIColor = UIColor(red:0, green:0.6627,blue:0.6157, alpha:1.0)
  var deviceMoving:Bool = false
  
  
  
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
  
  
   var viewerSettingData=(Int(4),Int(4),CGFloat(5.0),Int(5),Int(100))
   var viewerDataBuffer=(Int(4),Int(4),CGFloat(5.0),Int(5),Int(100))
   var viewerDefaultSettingData=(Int(4),Int(4),CGFloat(5.0),Int(5),Int(100))

  /*Tuple型
   0  Slide speed
   1  Slide Flash Rate
   2  Light Bar Size Data
   3  Stamp speed
   4  Stamp Size
   */
  var AsignData:[Int]=[0,1,2,0,2,3]
   var AsignBuffer:[Int]=[0,1,2,0,2,3]
  
  /*
   0  Single
   1  Loop
   2  Tap & Fire
   3  Fleeze &T Fire
   */
  var stampSpeedTable:[Double]=[0.5,0.25,0.05,0.033,0.017,0.011,0.0083,0.0066,0.005,0.004,0.00333,0.002]
  var stampSpStringTable:[String]=["1/2","1/4","1/10","1/30","1/60","1/90","1/120","1/150","1/200","1/250","1/300","1/500"]
  var scanSpeedTable:[Double]=[0.125,0.25,0.5,1.0,1.5,2.0,2.5,3.0,3.5,4.0,5.0]
  var scanSpStringTable:[String]=["1/8","1/4","1/2","1","1.5","2","2.5","3","3.5","4","5"]
  var AsignStringTable:[String]=["Single","Loop","Tap\n&\nFIre","Fleeze\n&\nFIre"]

  var directionLeft:Bool = true
  var isPortrait:Bool! //画面の向き
  var phaize:Int8! = 0{
    willSet {
      print("phaize willSet:\(phaize) -> \(newValue)")
    }
    didSet {
      print("phaize　didSet :\(oldValue) -> \(phaize)")
//      if(phaize > 0 ){
//        self.viewerOpeView.alpha=0
//      }else{
//        self.viewerOpeView.alpha=1
//      }
      if(phaize == 1 ){
        self.count3Label.alpha=1
        self.count2Label.alpha=1
        self.count1Label.alpha=1
      }else{
        self.count3Label.alpha=0
        self.count2Label.alpha=0
        self.count1Label.alpha=0
      }
      if phaize == 5 {
      self.notificationLabel.alpha = 1
      }else{
      self.notificationLabel.alpha = 0
      }
      if phaize == 8{
        self.preferenceView.alpha = 1
      }else{
        self.preferenceView.alpha = 0
      }

    }
  }
  /*:
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
   10 = Fleeze & Stamp Fire mode
  :*/
  var noActionTimer:Int! = 0

  
  
  //カウント：0-3
 
  //Width:double
  //Height:double
  //Speed:double
  //窓のサイズ:CGFloat
  
  //UIView関連
  var cameraView: UIImageView!//実際に再生に使うビュ
  var viewerOpeView: UIView!//メインのオペレーションビュー
  var preferenceView: UIView! //設定画面
  var mainLabelView: UIView! //メインのラベル系
  var preferenceScrollView:UIScrollView!//スクロールビュー
  var pageControl:UIPageControl!
  var opeImage:UIImageView! //サブビュー
  
  var  stmpIconView:UIImageView!
  var  scanIconView:UIImageView!
  var frameViewR: UIView!
  var frameViewL: UIView!
  var viewerInfoButton:UIButton!//サブビュー　パラメーターセットボタン
  //var addImageButton: UIButton!
  var addImageButton:UIBarButtonItem!
  var editButton:UIBarButtonItem!
  var myToolBar: UIToolbar!
  
  
  var scanintervalLabel: UILabel!
  var stampIntervalLabel:UILabel!
  var lightBarSizeLabel:UILabel!
  
  var scanPrefImg:UIImageView!
  var stmpPrefSetImg:UIImageView!
  var scanAsignSetImg:UIImageView!
  var stmpAsignSetImg:UIImageView!
  
  var reSetPlayParaCircle:UILabel!
  
  var asignScan1FinLabel:UILabel!
  var asignScan2FinLabel:UILabel!
  var asignScan3FinLabel:UILabel!
  var asignStmp1FinLabel:UILabel!
  var asignStmp2FinLabel:UILabel!
  var asignStmp3FinLabel:UILabel!
  var preference1stPageLabel:UILabel!
  var preference2stPageLabel:UILabel!
  
  
  var scanSpeedSetCircle:UILabel!
  var scanFlashSetCircle:UILabel!
  var stampSpeedSetCircle:UILabel!
  var stampSizeSetCircle:UILabel!
  var lightBarSizeSetCircle:UILabel!
  
  var scan1fAsignSetCircle:UILabel!
  var scan2fAsignSetCircle:UILabel!
  var scan3fAsignSetCircle:UILabel!
  var stamp1fAsignSetCircle:UILabel!
  var stamp2fAsignSetCircle:UILabel!
  var stamp3fAsignSetCircle:UILabel!
  
  var scanSpeedInfoTxt:UILabel!
  var stampSpeedInfoTxt:UILabel!
  var lightBarSizeInfoTxt:UILabel!
  
  var count3Label: UILabel!
  var count2Label: UILabel!
  var count1Label: UILabel!
  var notificationLabel: UILabel!
  
  var selectedModeLabel: UILabel!
  
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
  var tripleTap:UITapGestureRecognizer!
  
  
  
  

  
  //加速度センサの表示
  //Motion
  var myMotionManager: CMMotionManager!
  var gyroHandler:CMGyroHandler!
//  @IBOutlet weak var accelX: UILabel!
//  @IBOutlet weak var accelY: UILabel!
//  @IBOutlet weak var accelZ: UILabel!
//  
//  //Gyroセンサの表示
//  @IBOutlet weak var rotaionX: UILabel!
//  @IBOutlet weak var rotaionY: UILabel!
//  @IBOutlet weak var rotaionZ: UILabel!

  
// MARK: - 初期設定など
  override func viewDidLoad() {
    super.viewDidLoad()
    
    print("scanSpeedTable.count=",scanSpeedTable.count,"stampSpStringTable.count=",stampSpStringTable.count)
    print("scanSpeedTable.count=",scanSpeedTable.count,"stampSpStringTable.count=",stampSpStringTable.count)
    
    self.view.tintColor = themeColor
    
    UILabel.appearance().tintColor = themeColor
    //UILabel.appearance()
    
    print("tintcolor",self.view.tintColor)
    
    
    //viewerStyleMode set 
    viewerStyleMode = [0,0]
    //scan direction Left , single play

    print(UIDevice.currentDevice().localizedModel)
    
    // Screen Size の取得
    screenWidth = self.view.bounds.width
    screenHeight = self.view.bounds.height
    print("縦:",screenHeight,"横：",screenWidth)
    if(screenWidth < screenHeight){
      print("縦長！画面")
      isPortrait = true
      step  = screenWidth / 20
      screenShortSize = screenWidth
      screenLargeSize = screenHeight
      
        buttonMainCenter = CGPointMake(screenWidth/2,screenHeight * 2 / 5)
        buttonMainSize = CGPointMake((screenWidth+(screenHeight/1.777-screenWidth)) * 0.8, (screenWidth+(screenHeight/1.777-screenWidth)) * 0.8)
      
      
//      //LightBar サイズの設定 縦：横＝1 : 0.01
//      (viewerSettingData.2) = screenWidth * 0.01
//      print("tuple:",viewerSettingData)
//      viewerDataBuffer = viewerSettingData
    }else{
      
      print("横長！画面")
      isPortrait = false
      step  = screenWidth / 30
      screenShortSize = screenHeight
      screenLargeSize = screenWidth

      buttonMainCenter = CGPointMake(screenWidth/2,screenHeight * 2 / 5)
      buttonMainSize = CGPointMake((screenWidth+(screenHeight/1.777-screenWidth)) * 0.8, (screenWidth+(screenHeight/1.777-screenWidth)) * 0.8)
      
      //LightBar サイズの設定 縦：横＝1 : 0.01
//      (viewerSettingData.2) = screenHeight * 0.01
//      print("tuple:",viewerSettingData)
//      viewerDataBuffer = viewerSettingData
    }

    //viewの設定
    self.view.backgroundColor=UIColor.blackColor()
    
   
    // パン認識.スワイプ左、右
    viewTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.viewTapped(_:)))
    //stopTap = UITapGestureRecognizer(target: self, action: "stopPlayTapped:")
    stampTap = UITapGestureRecognizer(target:self, action:#selector(ViewController.prePreStampPlay(_:)))
    stampTap.numberOfTouchesRequired = 1
    myPan = UIPanGestureRecognizer(target: self, action: #selector(ViewController.panGesture(_:)))
    swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.didSwipe(_:)))
    swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.didSwipe(_:)))
    swipeDown = UISwipeGestureRecognizer(target: self,action:#selector(ViewController.didSwipe(_:)))
    swipeUp = UISwipeGestureRecognizer(target: self,action:#selector(ViewController.didSwipe(_:)))
    swipeLeft.direction = .Left
    swipeRight.direction = .Right
    swipeDown.direction = .Down
    swipeUp.direction = .Up
    // ダブルタップ
   doubleTap = UITapGestureRecognizer(target:self, action: #selector(ViewController.prePreStampPlay(_:)))
    doubleTap.numberOfTouchesRequired = 2
    tripleTap = UITapGestureRecognizer(target:self, action: #selector(ViewController.prePreStampPlay(_:)))
   tripleTap.numberOfTouchesRequired = 3

    self.view.addGestureRecognizer(viewTap)
    //他のジェスチャーは、最初にイメージを取得してから
    
    

    cameraView = UIImageView(frame: CGRectMake(0,0,screenWidth,screenHeight))
    
    //cameraView.contentMode =
    cameraView.image = UIImage(named:"IMG_1485low200pxMetaDataOFF.jpg")
    cameraView.alpha = 0
    
  
    
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
    
    count3Label.alpha=0
    count2Label.alpha=0
    count1Label.alpha=0
    
    //Playボタンのカスタマイズ
    viewerOpeView = UIView(frame: countRect)
    viewerOpeView.center=buttonMainCenter
    viewerOpeView.layer.masksToBounds = true
//    viewerOpeView.layer.borderColor = UIColor.darkGrayColor().CGColor
//    viewerOpeView.layer.borderWidth = step / 3
    viewerOpeView.layer.cornerRadius = viewerOpeView.frame.width / 2
    viewerOpeView.backgroundColor = UIColor.clearColor()
    
    opeImage = UIImageView(frame:viewerOpeView.frame)
    opeImage.frame.origin=CGPointMake(0,0)
    viewerOpeView.addSubview(opeImage)
    
    //ToolBarのカスタマイズ
    
    myToolBar = UIToolbar(frame:  CGRectMake(0, screenHeight - step * 3, screenWidth, step * 3))
    myToolBar.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height-step * 1.5)
    myToolBar.barStyle = UIBarStyle.BlackTranslucent
    
    /*myToolBar.tintColor = UIColor.blueColor()
    myToolBar.backgroundColor = UIColor.blackColor()
    */
    
    
    
    //create a new button
    let abutton: UIButton = UIButton(type:UIButtonType.Custom)
    //set image for button
    abutton.setImage(UIImage(named: "album-1--Green-100px-alpha"), forState: UIControlState.Normal)
    //add function for button
    abutton.addTarget(self, action: #selector(ViewController.showAlbum(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    //set frame
    abutton.frame = CGRectMake(0, 0, step * 3 - 3,step * 3 - 3)
    //create a new button
    let bbutton: UIButton = UIButton(type:UIButtonType.Custom)
    bbutton.setImage(UIImage(named: "photo-camera-2-Green-100px-alpha.png"), forState: UIControlState.Normal)
    bbutton.addTarget(self, action: #selector(ViewController.CameraStart(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    bbutton.frame = CGRectMake(0, 0, step * 3 - 3,step * 3 - 3)
    //create a new button
    let cbutton: UIButton = UIButton(type:UIButtonType.Custom)
    cbutton.setImage(UIImage(named: "info-2-Green100px-alpha.png"), forState: UIControlState.Normal)
    cbutton.addTarget(self, action: #selector(ViewController.editInfoTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    cbutton.frame = CGRectMake(0, 0, step * 3 - 3,step * 3 - 3)
    addImageButton = UIBarButtonItem(customView:bbutton)
    addImageButton.tag = 1
    let cameraButton = UIBarButtonItem(customView:abutton)
    cameraButton.tag = 2
    editButton = UIBarButtonItem(customView:cbutton)
    editButton.tag = 3
    editButton.enabled = false
    let buttonGap: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    myToolBar.items = [addImageButton ,buttonGap,cameraButton,buttonGap,editButton]
    
    
    
    notificationtRedyCenter = CGPointMake(screenWidth/2,screenHeight + buttonMainSize.x/2)
    notificationLabel = UILabel(frame: countRect)
    notificationLabel.countLabelformat()
    notificationLabel.layer.borderColor = self.view.tintColor.CGColor
    notificationLabel.layer.borderWidth = step / 3
    notificationLabel.backgroundColor = UIColor.clearColor()
    notificationLabel.textColor = self.view.tintColor
    notificationLabel.numberOfLines = 0
    notificationLabel.center = buttonMainCenter
    let bundleIdentifier = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String
    let version: AnyObject! = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString")
    
    notificationLabel.text = "\(bundleIdentifier) -v\(version)\n How to use \n\n [SwipeLR Image -> SlidePlay]\n (1 finger) -> onetime \n (2 finger) -> Loop \n (3 finger) -> Tap and Fire!\n\n[Tap Image -> Stamp]\n (1 finger) -> onetime \n (2 finger) -> Tap and Fire!"
    
    

    /*
    
    //addImageButton = UIButton(type: UIButtonType.ContactAdd)
    addImageButton = UIButton(frame:CGRectMake(0,screenHeight - step * 3,screenWidth,step * 3))
    addImageButton.setTitle("select Image", forState:  UIControlState.Normal)
    addImageButton.backgroundColor = UIColor.grayColor()
    //addImageButton.center = CGPointMake(screenWidth / 2, screenHeight - step)
    // イベントを追加する.
    addImageButton.addTarget(self, action: "showAlbum:",forControlEvents: UIControlEvents.TouchUpInside)
    */
    
    
    
    
    frameViewR = UIView(frame: CGRectMake(screenWidth/2+(viewerSettingData.2)/2,0,screenWidth/2,screenHeight))
    frameViewR.backgroundColor = UIColor.blackColor()
    frameViewL = UIView(frame: CGRectMake(-1*(viewerSettingData.2)/2,0,screenWidth/2,screenHeight))
    frameViewL.backgroundColor=UIColor.blackColor()
    frameViewL.alpha=0
    frameViewR.alpha=0
    
    
    
    mainLabelView=UIView(frame:countRect)
    mainLabelView.userInteractionEnabled = true
    // UIImageViewをViewに追加する.
    self.view.addSubview(cameraView)
    
    //窓をviewに追加
    self.view.addSubview(frameViewR)
    self.view.addSubview(frameViewL)
    
    
    self.view.addSubview(mainLabelView)
    
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
    
    
    self.preferenceSet()
  
    selectedModeLabel = UILabel(frame: CGRectMake(0,0, screenWidth, 88))
    selectedModeLabel.font=UIFont.systemFontOfSize(CGFloat(26))
    selectedModeLabel.adjustsFontSizeToFitWidth=true
    selectedModeLabel.backgroundColor=UIColor.clearColor()
    selectedModeLabel.textColor = self.view.tintColor
    selectedModeLabel.textAlignment =  NSTextAlignment.Center
    
    mainLabelView.addSubview(selectedModeLabel)
    
    //加速度センサ系の設定
    motionProcess()
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {
    
    // 端末の向きがかわったらNotificationを呼ばす設定.
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onOrientationChange(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onOrientationChange(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)

  }
  override func shouldAutorotate() -> Bool{
    if(phaize != 0 && phaize != 8  ){
    return false
    }else{
      
      print("呼ばれてるshouldAutorotate()phaize=",phaize)
    return true
    }
  }
  // 端末の向きがかわったら呼び出される.
  func onOrientationChange(notification: NSNotification){
    
    if(phaize != 0 && phaize != 8  ){
      return
    }
    
    print("onOrientationChange phaize=",phaize)
    // 現在のデバイスの向きを取得.
    let deviceOrientation: UIDeviceOrientation!  = UIDevice.currentDevice().orientation
    
    // 向きの判定.
    if UIDeviceOrientationIsLandscape(deviceOrientation) {
      
      //横向きの判定.
      //向きに従って位置を調整する.
      if (isPortrait == true ) {
      print( "Landscape")
      isPortrait = false
      rePosittion()
      }else{
      print ("画面の回転をキャンセル")
      }
      
    } else if UIDeviceOrientationIsPortrait(deviceOrientation){
      
      //縦向きの判定.
      //向きに従って位置を調整する.
      if (isPortrait != true ) {
        
        print("Portrait")
        isPortrait = true
        rePosittion()
      }else{
        print ("画面の回転をキャンセル")
      }
    }
  }
  
  func rePosittion(){
    // Screen Size の取得
    screenWidth = self.view.bounds.width
    screenHeight = self.view.bounds.height
    
    print("縦:",screenHeight,"横：",screenWidth)
    if(screenWidth < screenHeight){
      print("縦長！画面")
      step  = screenWidth / 20
      screenShortSize = screenWidth
      screenLargeSize = screenHeight
      
      buttonMainCenter = CGPointMake(screenWidth/2,screenHeight * 2 / 5)
      buttonMainSize = CGPointMake((screenWidth+(screenHeight/1.777-screenWidth)) * 0.8, (screenWidth+(screenHeight/1.777-screenWidth)) * 0.8)
      
    }else{
      
      print("横長！画面")
      step  = screenWidth / 30
      screenShortSize = screenHeight
      screenLargeSize = screenWidth
      
      buttonMainCenter = CGPointMake(screenWidth/2,screenHeight * 2 / 5)
      buttonMainSize = CGPointMake((screenWidth+(screenHeight/1.777-screenWidth)) * 0.8, (screenWidth+(screenHeight/1.777-screenWidth)) * 0.8)
      
    }
    
    if(phaize != 0 && phaize != 8 || isFirstSet != false ){
      cameraView.frame = CGRectMake(0,0,screenWidth,screenHeight)
    }else{
        scanSizeFit(cameraView)
      
    }
    let countRect:CGRect=CGRectMake(screenWidth, screenHeight * 2 / 5 - buttonMainSize.x/2, buttonMainSize.x, buttonMainSize.y)
    let countRectRadius =  countRect.width / 2
    
    count3Label.frame = countRect
    count3Label.layer.cornerRadius = countRectRadius
    count2Label.frame = countRect
    count2Label.layer.cornerRadius = countRectRadius
    count1Label.frame = countRect
    count1Label.layer.cornerRadius = countRectRadius
    
    selectedModeLabel.frame=CGRectMake(0,0, screenWidth, 88)
    
    mainLabelView.frame = self.view.frame
    
     print("viewerOpeView変更")
    UIView.animateWithDuration(0.3,
                               animations: {() -> Void in
                                self.viewerOpeView.frame = countRect
                                self.viewerOpeView.center=self.buttonMainCenter
                                self.viewerOpeView.layer.cornerRadius = countRectRadius
                                self.opeImage.frame.size = self.viewerOpeView.frame.size
      })
      
      if(phaize == 8){
        viewerOpeView.center.y=buttonMainCenter.y-screenHeight
        mainLabelView.center.y=mainLabelView.center.y-screenHeight
      }

    
    notificationLabel.frame = countRect
    notificationLabel.layer.cornerRadius = notificationLabel.frame.width / 2

    
    myToolBar.frame = CGRectMake(0, screenHeight - step * 3, screenWidth, step * 3)
    if( phaize < 9 && ( phaize != 8 || phaize != 2 || phaize != 6 || phaize != 5 )){
        print("frameViewのサイズ変更")
        frameViewR.frame = CGRectMake(screenWidth/2+(viewerSettingData.2)/2,0,screenWidth/2,screenHeight)
        frameViewL.frame = CGRectMake(-1*(viewerSettingData.2)/2,0,screenWidth/2,screenHeight)
    }
    
    preferenceReSet()
    
    if isFirstSet == false{
      notificationtRedyCenter = CGPointMake(screenWidth/2,screenHeight + buttonMainSize.x/2)
      notificationLabel.center = notificationtRedyCenter
       mainInfoLabelformat(scanintervalLabel,imgView:scanIconView,num:0)
       mainInfoLabelformat( stampIntervalLabel,imgView:stmpIconView,num:1)
      //設定ボタン
      viewerInfoButton.frame = CGRectMake(screenWidth-55,11,44,44)

      
    }else{
      
    notificationLabel.center = buttonMainCenter
    }
    
  }
  
  
  func preferenceLabelformat(label:UILabel,tagnum:Int){
    label.textColor = UIColor(red:0, green:0.6627,blue:0.6157, alpha:1.0)
    label.backgroundColor = UIColor.clearColor()
    label.layer.masksToBounds = true
    label.layer.cornerRadius = label.frame.width / 2
    label.layer.borderColor = UIColor(red:0, green:0.6627,blue:0.6157, alpha:1.0)
      .CGColor
    label.layer.borderWidth = label.frame.width / 15
    label.alpha = 1.0
    label.textAlignment = NSTextAlignment.Center
    label.userInteractionEnabled = true
    label.numberOfLines = 0
    label.adjustsFontSizeToFitWidth=true
    label.tag = tagnum
    label.addGestureRecognizer( UIPanGestureRecognizer(target:self, action: #selector(ViewController.setPanGesture(_:))))
     label.addGestureRecognizer( UITapGestureRecognizer(target:self, action: #selector(ViewController.setTapGesture(_:))))
    preferenceScrollView.addSubview(label)
  }
  
  func mainInfoLabelformat(label:UILabel,imgView:UIImageView,num:Int){
    print("infoLabelformat 0")
    mainInfoLabelFrameSet(label,imgView:imgView,num:num)
    label.textColor = UIColor(red:0, green:0.6627,blue:0.6157, alpha:1.0)
    label.backgroundColor = UIColor.clearColor()
    label.alpha = 0.5
    label.font=UIFont.boldSystemFontOfSize(16)
    label.textAlignment = NSTextAlignment.Center
    label.userInteractionEnabled = true
    label.numberOfLines = 0
    label.adjustsFontSizeToFitWidth=true
    mainLabelView.addSubview(label)
    
}
  func mainInfoLabelFrameSet(label:UILabel,imgView:UIImageView,num:Int) {
    let minWidth = screenWidth*6/10
    let padding = (screenWidth-minWidth)/2

    label.frame = CGRectMake(padding+CGFloat(num)*minWidth/2 ,screenHeight*0.75,minWidth/2,buttonMainSize.x / 3)
    
    let labelSize = buttonMainSize.x / 4.5
    let imgCenter = CGPointMake(label.center.x, label.center.y - label.frame.height * 3 / 10)
    imgView.frame=CGRectMake(0,0,labelSize,labelSize)
    imgView.center=imgCenter
  }
  

  func preferenceSet(){
    
    preferenceView = UIView(frame:CGRectMake(0,screenHeight,screenWidth,screenHeight))
    // ScrollViewを取得する.
    preferenceScrollView = UIScrollView(frame: self.view.frame)
    // ページ数を定義する.
    let pageSize = 2
    
    // 縦方向と、横方向のインディケータを非表示にする.
    preferenceScrollView.showsHorizontalScrollIndicator = false;
    preferenceScrollView.showsVerticalScrollIndicator = false
    // ページングを許可する.
    preferenceScrollView.pagingEnabled = true
    //preferenceScrollViewのデリゲートを設定する.
    preferenceScrollView.delegate = self
    // スクロールの画面サイズを指定する.
    preferenceScrollView.contentSize = CGSizeMake(CGFloat(pageSize) * screenWidth, 0)
    // ScrollViewをViewに追加する.
    preferenceView.addSubview(preferenceScrollView)
    
    // PageControlを作成する.
    pageControl = UIPageControl(frame: CGRectMake(0, self.view.frame.maxY - 100, screenWidth, 50))
    pageControl.backgroundColor = UIColor.clearColor()
    pageControl.currentPageIndicatorTintColor = themeColor
    pageControl.numberOfPages = pageSize
    pageControl.currentPage = 0
    pageControl.userInteractionEnabled = false
    preferenceView.addSubview(pageControl)
    
    preferenceCircleRect = CGRectMake(0,0,screenShortSize/4,screenShortSize/4)
    //BUttonSizeの1/3サイズ
    
    print("preferenceCircleの７つ分のサイズが縦サイズに収まるか？",screenHeight-preferenceCircleRect.height*7)
    if(screenHeight-preferenceCircleRect.height*7 < 0){
      preferenceCircleRect = CGRectMake(0,0,screenLargeSize/8,screenLargeSize/8)
      print("preferenceCircle調整後、",preferenceCircleRect.height)
    }
    
    scanPrefImg = UIImageView(frame:preferenceCircleRect)
    scanPrefImg.center =  preferenceGridCenterSet(0,ynum:0)
    scanPrefImg.image = UIImage(named: "slide-150px.png")
    scanPrefImg.alpha = 1.0
    preferenceScrollView.addSubview(scanPrefImg)
    
     stmpPrefSetImg = UIImageView(frame:preferenceCircleRect)
    stmpPrefSetImg.center =  preferenceGridCenterSet(0,ynum:1)
    stmpPrefSetImg.image = UIImage(named: "stmp-150px.png")
    stmpPrefSetImg.alpha = 1.0
    preferenceScrollView.addSubview(stmpPrefSetImg)
    
    /*
    let scanPrefLabel = UILabel(frame:preferenceCircleRect)
    // scanPrefLabel.text = "S\nL\nI\nD\nE"
    scanPrefLabel.text = "Slide Play"
    scanPrefLabel.adjustsFontSizeToFitWidth=true
    scanPrefLabel.infoLabelformat()
    scanPrefLabel.layer.borderWidth = 0
    scanPrefLabel.center = preferenceGridCenterSet(0,ynum:0)
    scanPrefLabel.center.y = (scanPrefLabel.center.y)+(preferenceCircleRect.size.height*0.4)
    preferenceScrollView.addSubview( scanPrefLabel)
    
    let   stampPrefLabel = UILabel(frame:preferenceCircleRect)
    // stampPrefLabel.text = "S\nL\nI\nD\nE"
    stampPrefLabel.text = "Stamp Play"
    stampPrefLabel.adjustsFontSizeToFitWidth=true
    stampPrefLabel.infoLabelformat()
    stampPrefLabel.layer.borderWidth = 0
    stampPrefLabel.center = preferenceGridCenterSet(0,ynum:1)
    stampPrefLabel.center.y = (stampPrefLabel.center.y)+(preferenceCircleRect.size.height*0.4)
    preferenceScrollView.addSubview( stampPrefLabel)
    */
    
    
    scanSpeedSetCircle = UILabel(frame:preferenceCircleRect)
    scanSpeedSetCircle.text = "Speed"
    preferenceLabelformat(scanSpeedSetCircle,tagnum: 11)
    scanSpeedSetCircle.center = preferenceGridCenterSet(1,ynum:0)
    
    /*
     scanFlashSetCircle = UILabel(frame:preferenceCircleRect)
     scanFlashSetCircle.text = "Flash Rate"
     scanFlashSetCircle.infoLabelformat()
     scanFlashSetCircle.center = preferenceGridCenterSet(1,ynum:0)
     scanFlashSetCircle.tag = 12
     scanFlashSetCircle.addGestureRecognizer( UIPanGestureRecognizer(target: self, action: #selector(ViewController.setPanGesture(_:))))
     scanFlashSetCircle.alpha = 0.5
     preferenceScrollView.addSubview(scanFlashSetCircle)
     */
    lightBarSizeSetCircle = UILabel(frame:preferenceCircleRect)
    lightBarSizeSetCircle.text = "BarSize"
    preferenceLabelformat(lightBarSizeSetCircle,tagnum: 13)
    lightBarSizeSetCircle.center =  preferenceGridCenterSet(2,ynum:0)
    
    
    stampSpeedSetCircle = UILabel(frame:preferenceCircleRect)
    stampSpeedSetCircle.text = "Speed"
    preferenceLabelformat(stampSpeedSetCircle,tagnum: 14)
    stampSpeedSetCircle.center = preferenceGridCenterSet(1,ynum:1)
    
    stampSizeSetCircle = UILabel(frame:preferenceCircleRect)
    stampSizeSetCircle.text = "Scale Size "
    preferenceLabelformat(stampSizeSetCircle,tagnum: 15)
    stampSizeSetCircle.center = preferenceGridCenterSet(2,ynum:1)
    
    
    reSetPlayParaCircle  = UILabel(frame:preferenceCircleRect)
    reSetPlayParaCircle.text = "reset"
    preferenceLabelformat(reSetPlayParaCircle,tagnum: 23)
    reSetPlayParaCircle.frame.size = CGSizeMake(reSetPlayParaCircle .frame.width*0.75, reSetPlayParaCircle.frame.height*0.75)
    reSetPlayParaCircle.layer.borderWidth=reSetPlayParaCircle.layer.borderWidth * 0.75
    reSetPlayParaCircle.layer.cornerRadius = reSetPlayParaCircle .frame.width / 2
    reSetPlayParaCircle.center = preferenceGridCenterSet(1,ynum:2)
    
    
   scanAsignSetImg = UIImageView(frame:preferenceCircleRect)
    scanAsignSetImg.image = UIImage(named: "slide-150px.png")
    scanAsignSetImg.frame.size = CGSizeMake(scanAsignSetImg.frame.width * 0.7, scanAsignSetImg.frame.height*0.7)
    scanAsignSetImg.center = asignGridSet(4,ynum:1)
    scanAsignSetImg.alpha = 1.0
    preferenceScrollView.addSubview(scanAsignSetImg)
    
    stmpAsignSetImg = UIImageView(frame:preferenceCircleRect)
    stmpAsignSetImg.frame.size = CGSizeMake(stmpAsignSetImg.frame.width * 0.7, stmpAsignSetImg.frame.height*0.7)
    stmpAsignSetImg.center = asignGridSet(4,ynum:3)
    stmpAsignSetImg.image = UIImage(named: "stmp-150px.png")
    stmpAsignSetImg.alpha = 1.0
    preferenceScrollView.addSubview(stmpAsignSetImg)
    
    /*
    let scanAsignLabel = UILabel(frame:preferenceCircleRect)
    // scanAsignLabel.text = "S\nL\nI\nD\nE"
    scanAsignLabel.text = "Slide"
    scanAsignLabel.adjustsFontSizeToFitWidth=true
    scanAsignLabel.infoLabelformat()
    scanAsignLabel.font = UIFont.systemFontOfSize(CGFloat(12))
    scanAsignLabel.layer.borderWidth = 0
    scanAsignLabel.center = asignGridSet(4,ynum:1)
    scanAsignLabel.center.y = (scanAsignLabel.center.y)+(preferenceCircleRect.size.height*0.3)
    preferenceScrollView.addSubview( scanAsignLabel)
    
    let   stampAsignLabel = UILabel(frame:preferenceCircleRect)
    // stampAsignLabel.text = "S\nL\nI\nD\nE"
    stampAsignLabel.text = "Stamp"
    stampAsignLabel.adjustsFontSizeToFitWidth=true
    stampAsignLabel.infoLabelformat()
    stampAsignLabel.font = UIFont.systemFontOfSize(CGFloat(12))
    stampAsignLabel.layer.borderWidth = 0
    stampAsignLabel.center = asignGridSet(4,ynum:3)
    stampAsignLabel.center.y = (stampAsignLabel.center.y)+(preferenceCircleRect.size.height*0.3)
    preferenceScrollView.addSubview( stampAsignLabel)
    */
    
    
    asignScan1FinLabel = UILabel(frame:preferenceCircleRect)
    //  asignScan1FinLabel.text = "S\nL\nI\nD\nE"
    asignScan1FinLabel.text = "1 Fing Swipe"
    asignScan1FinLabel.adjustsFontSizeToFitWidth=true
    asignScan1FinLabel.infoLabelformat()
    asignScan1FinLabel.font = UIFont.systemFontOfSize(CGFloat(12))
    asignScan1FinLabel.layer.borderWidth = 0
    asignScan1FinLabel.center = asignGridSet(3,ynum:2)
    asignScan1FinLabel.center.y = (asignScan1FinLabel.center.y)-(preferenceCircleRect.size.height*0.6)
    preferenceScrollView.addSubview(asignScan1FinLabel)
    
    asignScan2FinLabel = UILabel(frame:preferenceCircleRect)
    //  asignScan2FinLabel.text = "S\nL\nI\nD\nE"
    asignScan2FinLabel.text = "2 Fing Swipe"
    asignScan2FinLabel.adjustsFontSizeToFitWidth=true
    asignScan2FinLabel.infoLabelformat()
    asignScan2FinLabel.font = UIFont.systemFontOfSize(CGFloat(12))
    asignScan2FinLabel.layer.borderWidth = 0
    asignScan2FinLabel.center = asignGridSet(4,ynum:2)
    asignScan2FinLabel.center.y = (asignScan2FinLabel.center.y)-(preferenceCircleRect.size.height*0.6)
    preferenceScrollView.addSubview(asignScan2FinLabel)
   
    asignScan3FinLabel = UILabel(frame:preferenceCircleRect)
    //  asignScan3FinLabel.text = "S\nL\nI\nD\nE"
    asignScan3FinLabel.text = "3 Fing Swipe"
    asignScan3FinLabel.adjustsFontSizeToFitWidth=true
    asignScan3FinLabel.infoLabelformat()
    asignScan3FinLabel.font = UIFont.systemFontOfSize(CGFloat(12))
    asignScan3FinLabel.layer.borderWidth = 0
    asignScan3FinLabel.center = asignGridSet(5,ynum:2)
    asignScan3FinLabel.center.y = (asignScan3FinLabel.center.y)-(preferenceCircleRect.size.height*0.6)
    preferenceScrollView.addSubview(asignScan3FinLabel)
    
    
    scan1fAsignSetCircle = UILabel(frame:preferenceCircleRect)
    scan1fAsignSetCircle.text = AsignStringTable[AsignData[0]]
    preferenceLabelformat(scan1fAsignSetCircle,tagnum: 17)
    scan1fAsignSetCircle.center = asignGridSet(3,ynum:2)
    
    scan2fAsignSetCircle = UILabel(frame:preferenceCircleRect)
    scan2fAsignSetCircle.text = AsignStringTable[AsignData[1]]
    preferenceLabelformat(scan2fAsignSetCircle,tagnum: 18)
    scan2fAsignSetCircle.center = asignGridSet(4,ynum:2)
    
    scan3fAsignSetCircle = UILabel(frame:preferenceCircleRect)
    scan3fAsignSetCircle.text = AsignStringTable[AsignData[2]]
    preferenceLabelformat(scan3fAsignSetCircle,tagnum: 19)
    scan3fAsignSetCircle.center = asignGridSet(5,ynum:2)
    
    stamp1fAsignSetCircle = UILabel(frame:preferenceCircleRect)
    stamp1fAsignSetCircle.text = AsignStringTable[AsignData[3]]
    preferenceLabelformat(stamp1fAsignSetCircle,tagnum: 20)
    stamp1fAsignSetCircle.center =  asignGridSet(3,ynum:4)
    
    stamp2fAsignSetCircle = UILabel(frame:preferenceCircleRect)
    stamp2fAsignSetCircle.text = AsignStringTable[AsignData[4]]
    preferenceLabelformat(stamp2fAsignSetCircle,tagnum: 21)
    stamp2fAsignSetCircle.center = asignGridSet(4,ynum:4)
    
    stamp3fAsignSetCircle = UILabel(frame:preferenceCircleRect)
    stamp3fAsignSetCircle.text = AsignStringTable[AsignData[5]]
    preferenceLabelformat(stamp3fAsignSetCircle,tagnum: 22)
    stamp3fAsignSetCircle.center = asignGridSet(5,ynum:4)
    
   asignStmp1FinLabel = UILabel(frame:preferenceCircleRect)
    //  asignStmp1FinLabel.text = "S\nL\nI\nD\nE"
    asignStmp1FinLabel.text = "1 Fing Tap"
    asignStmp1FinLabel.adjustsFontSizeToFitWidth=true
    asignStmp1FinLabel.infoLabelformat()
    asignStmp1FinLabel.font = UIFont.systemFontOfSize(CGFloat(12))
    asignStmp1FinLabel.layer.borderWidth = 0
    asignStmp1FinLabel.center = asignGridSet(3,ynum:4)
    asignStmp1FinLabel.center.y = (asignStmp1FinLabel.center.y)-(preferenceCircleRect.size.height*0.6)
    preferenceScrollView.addSubview(asignStmp1FinLabel)
    
    asignStmp2FinLabel = UILabel(frame:preferenceCircleRect)
    //  asignStmp2FinLabel.text = "S\nL\nI\nD\nE"
    asignStmp2FinLabel.text = "2 Fing Tap"
    asignStmp2FinLabel.adjustsFontSizeToFitWidth=true
    asignStmp2FinLabel.infoLabelformat()
    asignStmp2FinLabel.font = UIFont.systemFontOfSize(CGFloat(12))
    asignStmp2FinLabel.layer.borderWidth = 0
    asignStmp2FinLabel.center = asignGridSet(4,ynum:4)
    asignStmp2FinLabel.center.y = (asignStmp2FinLabel.center.y)-(preferenceCircleRect.size.height*0.6)
    preferenceScrollView.addSubview(asignStmp2FinLabel)
    
     asignStmp3FinLabel = UILabel(frame:preferenceCircleRect)
    //  asignStmp3FinLabel.text = "S\nL\nI\nD\nE"
    asignStmp3FinLabel.text = "3 Fing Tap"
    asignStmp3FinLabel.adjustsFontSizeToFitWidth=true
    asignStmp3FinLabel.infoLabelformat()
    asignStmp3FinLabel.font = UIFont.systemFontOfSize(CGFloat(12))
    asignStmp3FinLabel.layer.borderWidth = 0
    asignStmp3FinLabel.center = asignGridSet(5,ynum:4)
    asignStmp3FinLabel.center.y = (asignStmp3FinLabel.center.y)-(preferenceCircleRect.size.height*0.6)
    preferenceScrollView.addSubview(asignStmp3FinLabel)
    
    /*let reSetAsignCircle  = UILabel(frame:preferenceCircleRect)
     reSetAsignCircle .text = "reset"
     reSetAsignCircle .infoLabelformat()
     reSetAsignCircle .frame.size = CGSizeMake(reSetAsignCircle .frame.width*0.7, reSetAsignCircle .frame.height*0.7)
     reSetAsignCircle .layer.cornerRadius = reSetAsignCircle.frame.width / 2
     reSetAsignCircle .center = asignGridSet(5,ynum:5)
     reSetAsignCircle .tag = 23
     reSetAsignCircle .addGestureRecognizer( UIPanGestureRecognizer(target: self, action: #selector(ViewController.setPanGesture(_:))))
     //reSetAsignCircle .alpha = 0.5
     preferenceScrollView.addSubview(reSetAsignCircle )
     */
    
    
    
    
      preference1stPageLabel = UILabel(frame:preferenceCircleRect)
    preference1stPageLabel.frame.size.width = screenWidth/2
    preference1stPageLabel.text = "Player\nPreference"
    preference1stPageLabel.font = UIFont.systemFontOfSize(CGFloat(30))
    //preference1stPageLabel.font = UIFont.boldSystemFontOfSize(UIFont.labelFontSize())
    preference1stPageLabel.infoLabelformat()
    preference1stPageLabel.layer.cornerRadius = 0
    preference1stPageLabel.layer.borderWidth = 0
    preference1stPageLabel.center = asignGridSet(1,ynum:0)
    //preference1stPageLabel.center.y = (preference1stPageLabel.center.y)-(preferenceCircleRect.size.height*1.5)
    preferenceScrollView.addSubview(preference1stPageLabel)
    
     preference2stPageLabel = UILabel(frame:CGRectMake(screenWidth,screenHeight/4,screenWidth,preferenceCircleRect.height))
    preference2stPageLabel.frame.size.width = screenWidth/2
    preference2stPageLabel.text = "Asign\nPreference"
    preference2stPageLabel.font = UIFont.systemFontOfSize(CGFloat(30))
    preference2stPageLabel.infoLabelformat()
    preference2stPageLabel.layer.cornerRadius = 0
    preference2stPageLabel.layer.borderWidth = 0
    preference2stPageLabel.center = asignGridSet(4,ynum:0)
    //    preference2stPageLabel.center.y = (preference2stPageLabel.center.y)-(preferenceCircleRect.size.height*1.5)
    preferenceScrollView.addSubview(preference2stPageLabel)
  }
  
  func preferenceReSet(){
    if(phaize != 8){
    preferenceView.frame=CGRectMake(0,screenHeight,screenWidth,screenHeight)
    }else{
      preferenceView.frame=CGRectMake(0,0,screenWidth,screenHeight)
    }
    // ScrollView
    preferenceScrollView.frame = self.view.frame
    // ページ数を定義する.
    let pageSize = 2
    
    preferenceScrollView.contentSize = CGSizeMake(CGFloat(pageSize) * screenWidth, 0)
    pageControl.frame = CGRectMake(0, self.view.frame.maxY - 100, screenWidth, 50)
    preferenceCircleRect = CGRectMake(0,0,screenShortSize/4,screenShortSize/4)
    
    print("preferenceCircleの７つ分のサイズが縦サイズに収まるか？",screenHeight-preferenceCircleRect.height*7)
    if(screenHeight-preferenceCircleRect.height*7 < 0){
      preferenceCircleRect = CGRectMake(0,0,screenLargeSize/8,screenLargeSize/8)
      print("preferenceCircle調整後、",preferenceCircleRect.height)
    }
    
    scanPrefImg.frame=preferenceCircleRect
    scanPrefImg.center =  preferenceGridCenterSet(0,ynum:0)
    
    stmpPrefSetImg.frame=preferenceCircleRect
    stmpPrefSetImg.center =  preferenceGridCenterSet(0,ynum:1)
    
    scanSpeedSetCircle.frame=preferenceCircleRect
    scanSpeedSetCircle.center = preferenceGridCenterSet(1,ynum:0)
    
    lightBarSizeSetCircle.frame=preferenceCircleRect
    lightBarSizeSetCircle.center =  preferenceGridCenterSet(2,ynum:0)
    
    
    stampSpeedSetCircle.frame=preferenceCircleRect
    stampSpeedSetCircle.center = preferenceGridCenterSet(1,ynum:1)
    
    stampSizeSetCircle.frame=preferenceCircleRect
    stampSizeSetCircle.center = preferenceGridCenterSet(2,ynum:1)
    
    reSetPlayParaCircle.frame=preferenceCircleRect
    reSetPlayParaCircle.frame.size = CGSizeMake(reSetPlayParaCircle .frame.width*0.75, reSetPlayParaCircle.frame.height*0.75)
    reSetPlayParaCircle.center = preferenceGridCenterSet(1,ynum:2)
    
    
    scanAsignSetImg.frame=preferenceCircleRect
    scanAsignSetImg.frame.size = CGSizeMake(scanAsignSetImg.frame.width * 0.7, scanAsignSetImg.frame.height*0.7)
    scanAsignSetImg.center = asignGridSet(4,ynum:1)
    
    stmpAsignSetImg.frame=preferenceCircleRect
    stmpAsignSetImg.frame.size = CGSizeMake(stmpAsignSetImg.frame.width * 0.7, stmpAsignSetImg.frame.height*0.7)
    stmpAsignSetImg.center = asignGridSet(4,ynum:3)
    
    asignScan1FinLabel.frame=preferenceCircleRect
    asignScan1FinLabel.center = asignGridSet(3,ynum:2)
    asignScan1FinLabel.center.y = (asignScan1FinLabel.center.y)-(preferenceCircleRect.size.height*0.6)
    asignScan2FinLabel.frame=preferenceCircleRect
    asignScan2FinLabel.center = asignGridSet(4,ynum:2)
    asignScan2FinLabel.center.y = (asignScan2FinLabel.center.y)-(preferenceCircleRect.size.height*0.6)
    
    asignScan3FinLabel.frame=preferenceCircleRect
    asignScan3FinLabel.center = asignGridSet(5,ynum:2)
    asignScan3FinLabel.center.y = (asignScan3FinLabel.center.y)-(preferenceCircleRect.size.height*0.6)
    
    scan1fAsignSetCircle.frame=preferenceCircleRect
    scan1fAsignSetCircle.center = asignGridSet(3,ynum:2)
    
    scan2fAsignSetCircle .frame=preferenceCircleRect
    scan2fAsignSetCircle.center = asignGridSet(4,ynum:2)
    
    scan3fAsignSetCircle.frame=preferenceCircleRect
    scan3fAsignSetCircle.center = asignGridSet(5,ynum:2)
    
    stamp1fAsignSetCircle.frame=preferenceCircleRect
    stamp1fAsignSetCircle.center =  asignGridSet(3,ynum:4)
    
    stamp2fAsignSetCircle.frame=preferenceCircleRect
    stamp2fAsignSetCircle.center = asignGridSet(4,ynum:4)
    
    stamp3fAsignSetCircle.frame=preferenceCircleRect
    stamp3fAsignSetCircle.center = asignGridSet(5,ynum:4)
    
    asignStmp1FinLabel.frame=preferenceCircleRect
    asignStmp1FinLabel.center = asignGridSet(3,ynum:4)
    asignStmp1FinLabel.center.y = (asignStmp1FinLabel.center.y)-(preferenceCircleRect.size.height*0.6)
    
    asignStmp2FinLabel.frame=preferenceCircleRect
    asignStmp2FinLabel.center = asignGridSet(4,ynum:4)
    asignStmp2FinLabel.center.y = (asignStmp2FinLabel.center.y)-(preferenceCircleRect.size.height*0.6)
    
    asignStmp3FinLabel.frame=preferenceCircleRect
    asignStmp3FinLabel.center = asignGridSet(5,ynum:4)
    asignStmp3FinLabel.center.y = (asignStmp3FinLabel.center.y)-(preferenceCircleRect.size.height*0.6)
    
    preference1stPageLabel.frame.size.width = screenWidth/2
    preference1stPageLabel.center = asignGridSet(1,ynum:0)
    
    preference2stPageLabel.frame.size.width = screenWidth/2
    preference2stPageLabel.center = asignGridSet(4,ynum:0)
    
  }

  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    noActionTimer=0
    // スクロール数が1ページ分になったら時.
    if fmod(scrollView.contentOffset.x, scrollView.frame.maxX) == 0 {
      // ページの場所を切り替える.
      pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.maxX)
    }
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
    //    let accelerometerHandler:CMAccelerometerHandler = {
    //      (data:CMAccelerometerData?, error:NSError?) -> Void in
    //
    //ログにx,y,zの加速度を表示
    //      self.accelX.text = "x=".stringByAppendingFormat("%.2f", data!.acceleration.x)
    //      self.accelY.text = "y=".stringByAppendingFormat("%.2f", data!.acceleration.y)
    //      self.accelZ.text = "z=".stringByAppendingFormat("%.2f", data!.acceleration.z)
    
    //print("x:\(data!.acceleration.x) y:\(data!.acceleration.y) z:\(data!.acceleration.z)")
    //      print("\(data!.acceleration.x)\t\(data!.acceleration.y)\t\(data!.acceleration.z)")
    //      }
    
    
    //取得開始して、上記で設定したハンドラを呼び出し、ログを表示する
    //    myMotionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!,withHandler:accelerometerHandler)
    
    
    gyroHandler = {(data:CMGyroData?,error:NSError?)-> Void in
      
      //print("GYRO_x:\(data!.rotationRate.x) y:\(data!.rotationRate.y) z:\(data!.rotationRate.z)")
      //print("\(data!.rotationRate.x)\t\(data!.rotationRate.y)\t\(data!.rotationRate.z)")
      let abeValue = abs(data!.rotationRate.x+data!.rotationRate.y+data!.rotationRate.z )/3
      
      //print("gyro平均：",abeValue )
      
      if(abeValue <  0.25){
        //print("Deviceは静止している。")
        if(self.deviceMoving==true){
          self.deviceMoving=false
          print("Deviceは止まった。")
          self.stampFire()
        }
      }else{
        //print("Deviceが動ている")
        if(self.deviceMoving==false){
          self.deviceMoving=true
          print("Deviceは動き始めた。")
        }
        
      }
      //      if (data!.rotationRate.z > 0) {
      //self.slideViewStart()
      //        print("+")
      //      }else{
      //      self.slideViewBack()
      //        print("-")
      //      }
      
      
      //self.slideViewValue(CGFloat(data!.rotationRate.z))
      
      
      //
      //      self.rotaionX.text = "x=".stringByAppendingFormat("%.2f", data!.rotationRate.x)
      //      self.rotaionY.text = "y=".stringByAppendingFormat("%.2f", data!.rotationRate.y)
      //      self.rotaionZ.text = "z=".stringByAppendingFormat("%.2f", data!.rotationRate.z)
      
    }
    
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
  
  // MARK: - Return系_設定メソッド
  
  func scanSizeSet(imgView:UIImageView) -> CGRect{
    let imgWidth  = imgView.image!.size.width
    let imgHeight = imgView.image!.size.height
    let imgFrame =  CGRectMake((viewerSettingData.2) * 9.5, 0, (viewerSettingData.2) *  imgWidth / imgHeight * screenHeight, screenHeight)
    return imgFrame
  }
  func scanSizeFit(imgView:UIImageView){
    let imgWidth  = imgView.image!.size.width
    let imgHeight = imgView.image!.size.height
    let imgFrame =  CGRectMake(0, 0,imgWidth / imgHeight * screenHeight*imgWidth,screenHeight)
    imgView.frame = imgFrame
    imgView.contentMode = .ScaleToFill

  }

  
  
  func intervalTimeSet(imgView:UIImageView, speed:Double) -> Double{
    let imgWidth  = imgView.image!.size.width
    let imgHeight = imgView.image!.size.height
    let time =  Double(imgWidth / imgHeight) * speed
    return time
  }
  
  
  func preferenceGridCenterSet(xnum:Int,ynum:Int) -> CGPoint{
    var centerPoint:CGPoint!
    let sukimaSetX:CGFloat = step / 2
    let sukimaSetY:CGFloat = preferenceCircleRect.height/2

    let setXBaseIndent:CGFloat = (screenWidth - (preferenceCircleRect.width*3 + sukimaSetX*2))*0.5
    let setYBaseIndent:CGFloat = (screenHeight/2 - (preferenceCircleRect.height*2 + sukimaSetY))*0.5
    //:1ページで完結する場合の設定
    //let setYBaseIndent:CGFloat = (screenHeight/2 - (preferenceCircleRect.height*2 + sukimaSetX))*0.5
    //centerPoint = CGPointMake(setXBaseIndent + preferenceCircleRect.width/2+(preferenceCircleRect.width*CGFloat(xnum)) + sukimaSetX * CGFloat(xnum) ,setYBaseIndent +  preferenceCircleRect.height/2+(preferenceCircleRect.height*CGFloat(ynum % 2)) + sukimaSetX * CGFloat(ynum % 2)+(screenHeight/2) * CGFloat(ynum / 2))
    
    //:2ページで完結する場合の設定
      centerPoint = CGPointMake(setXBaseIndent + preferenceCircleRect.width/2+(preferenceCircleRect.width*CGFloat(xnum % 3 )) + sukimaSetX * CGFloat(xnum % 3)+(screenWidth) * CGFloat(xnum / 3),setYBaseIndent +  preferenceCircleRect.height/2+(preferenceCircleRect.height*CGFloat(ynum)) + sukimaSetY * CGFloat(ynum )+(screenHeight/4))

    //print("center",centerPoint)
    
    return centerPoint
  }
  
  
  func asignGridSet(xnum:Int,ynum:Int) -> CGPoint{
    var centerPoint:CGPoint!
    let sukimaSetX:CGFloat = step / 2
    let sukimaSetY:CGFloat = (screenHeight-preferenceCircleRect.height*7 ) / 8
    
    let setXBaseIndent:CGFloat = (screenWidth - (preferenceCircleRect.width*3 + sukimaSetX*2))*0.5
    //let setYBaseIndent:CGFloat = (screenHeight/2 - (preferenceCircleRect.height*2 + sukimaSetY))*0.5
    //:1ページで完結する場合の設定
    //let setYBaseIndent:CGFloat = (screenHeight/2 - (preferenceCircleRect.height*2 + sukimaSetX))*0.5
    centerPoint = CGPointMake(setXBaseIndent + preferenceCircleRect.width/2+(preferenceCircleRect.width*CGFloat(xnum % 3 )) + sukimaSetX * CGFloat(xnum % 3)+(screenWidth) * CGFloat(xnum / 3) ,
                              preferenceCircleRect.height/2+preferenceCircleRect.height/5*CGFloat(Int(ynum/3))+(preferenceCircleRect.height*CGFloat(ynum)) + sukimaSetY+sukimaSetY*CGFloat(ynum))
    
    //print("center",centerPoint)
    
    return centerPoint
  }


// MARK: - 撮影が完了時した時に呼ばれる
  func imagePickerController(imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      print("撮影が完了時した時に呼ばれる")
      
      // 画像の幅・高さの取得
      Iwidth = pickedImage.size.width
      Iheight = pickedImage.size.height
      
      if (isFirstSet == true ) {
        print("isFirstSet")
        
        scanintervalLabel=UILabel()
        scanIconView=UIImageView()
        mainInfoLabelformat(scanintervalLabel,imgView:scanIconView,num:0)
        scanintervalLabel.text = ""
        
        stampIntervalLabel=UILabel()
        stmpIconView=UIImageView()
        mainInfoLabelformat( stampIntervalLabel,imgView:stmpIconView,num:1)
        stampIntervalLabel.text = ""
       
        scanIconView.image = UIImage(named:"slide-150px.png")
        scanIconView.alpha=scanintervalLabel.alpha
        mainLabelView.addSubview(scanIconView)
        
        stmpIconView.image = UIImage(named:"stmp-150px.png")
        stmpIconView.alpha=scanintervalLabel.alpha
        mainLabelView.addSubview(stmpIconView)
  
        
        
       /*
        lightBarSizeLabel = UILabel(frame:infoframe)
        lightBarSizeLabel.frame.size = infoSize
        lightBarSizeLabel.center.y = buttonMainSize.y * 6.5 / 10
        lightBarSizeLabel.center.x = buttonMainSize.x * 3 / 4
        lightBarSizeLabel.infoLabelformat()
        lightBarSizeLabel.text = ""
         lightBarSizeLabel.tag = 23
         */
        
        
        
        

        //設定ボタン
        viewerInfoButton = UIButton(frame: CGRectMake(screenWidth-55,11,44,44))
        viewerInfoButton.layer.cornerRadius = viewerInfoButton.frame.width / 2
        viewerInfoButton.layer.borderWidth = 3
        viewerInfoButton.layer.borderColor = UIColor(red:0, green:0.6627,blue:0.6157, alpha:0.7).CGColor
        viewerInfoButton.backgroundColor = UIColor.clearColor()
        viewerInfoButton.setImage(UIImage(named:"up-alpha-nega-100px.png"), forState: UIControlState.Normal)
        viewerInfoButton.setTitle("Info", forState: UIControlState.Normal)
        mainLabelView.addSubview(viewerInfoButton)
        //preferenceView.addSubview(viewerInfoButton)
        viewerInfoButton.addTarget(self, action: #selector(ViewController.upButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)

        
        
        
        
       editButton.enabled = true
        
        // ピンチ
        let myPinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.pinchGesture(_:)))
        self.view.addGestureRecognizer(myPinchGesture)
        //ジェスチャーの追加
        viewerOpeView.addGestureRecognizer(myPan)
        viewerOpeView.addGestureRecognizer(swipeLeft)
        viewerOpeView.addGestureRecognizer(swipeRight)
        viewerOpeView.addGestureRecognizer(stampTap)
         viewerOpeView.addGestureRecognizer(doubleTap)
        viewerOpeView.addGestureRecognizer(tripleTap)
        
        
        self.view.addGestureRecognizer(swipeUp)
        self.view.addGestureRecognizer(swipeDown)
        //addImageButton.setTitle( "change Image", forState: UIControlState.Normal)
        notificationLabel.center = notificationtRedyCenter
        
        
        
        self.view.addSubview(preferenceView)
        /*
        self.view.addSubview(scanSpeedInfoTxt)
        self.view.addSubview(stampSpeedInfoTxt)
        self.view.addSubview(lightBarSizeInfoTxt)
        */
       
        notificationLabel.alpha = 0
        preferenceView.alpha = 0

        isFirstSet = false
      }

      cameraView.image = pickedImage
      cameraView.alpha = 0.3
      //opeImage.tag = 1
      //opeImage.userInteractionEnabled = true
      opeImage.image = pickedImage
      
      //viewerOpeView.sendSubviewToBack(opeImage)
      //viewerOpeView.bringSubviewToFront(viewerInfoButton)
      
//      viewerOpeView.bringSubviewToFront(scanintervalLabel)
//      viewerOpeView.bringSubviewToFront(stampIntervalLabel)
//      viewerOpeView.bringSubviewToFront(lightBarSizeLabel)
      
      intervaltime = intervalTimeSet(cameraView, speed:1.5)
      print("intervaltime:",intervaltime)

      
      scanintervalLabel.text = String(format: "%.1fsec",intervaltime)
      stampIntervalLabel.text = "1/60"
//      lightBarSizeLabel.text = String(format: "%.0fpx",(viewerSettingData.2))

      scanSpeedSetCircle.text = scanintervalLabel.text
      stampSpeedSetCircle.text = stampIntervalLabel.text
//      lightBarSizeSetCircle.text = lightBarSizeLabel.text
      
      scanSizeFit(cameraView)
      print("frame:x=",cameraView.frame.origin.x,"frame:y=",cameraView.frame.origin.y,"frame:heigth=",cameraView.frame.size.height,"frame:width=",cameraView.frame.size.width)
      
      //self.view.bringSubviewToFront(mainLabelView)
      self.view.bringSubviewToFront(viewerOpeView)
      
    }
    
    //閉じる処理
    imagePicker.dismissViewControllerAnimated(true, completion: nil)
    //Label.text = "Tap the [Save] to save a picture"
    
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    let touch = touches.first
     print("タッチした画像のタグ:",touch?.view?.tag,"count:",touches.count)
    /*if(touch?.view?.tag > 20 && touch?.view?.tag < 24  ){
    print("infoボタンタッチ")
      viewerOpeView.removeGestureRecognizer(stampTap)
      viewerOpeView.removeGestureRecognizer(doubleTap)
      viewerOpeView.removeGestureRecognizer(tripleTap)
      self.noActionTimer = 0
      viewerDataBuffer = viewerSettingData
      viewerOpeView.removeGestureRecognizer(myPan)
      viewerOpeView.removeGestureRecognizer(swipeLeft)
      viewerOpeView.removeGestureRecognizer(swipeRight)
      barSizeChangeAnimationCompleted = false
      preferenceScrollView.contentOffset.x=0
      self.pageControl.currentPage = 0
      UIView.animateWithDuration(0.3,
                                 animations: {() -> Void in
                                  self.viewerOpeView.center.y = -1 * self.buttonMainSize.x
                                  self.editParametorViewChange(0)
                                  //self.cameraView.alpha = 0.
                                  self.myToolBar.alpha = 0
        },completion: { finished in
          self.phaize = 8
          print("phaze:",self.phaize)
           self.tenCentiSecondTimer()
          self.viewerOpeView.addGestureRecognizer(self.stampTap)
          self.viewerOpeView.addGestureRecognizer(self.doubleTap)
          self.viewerOpeView.addGestureRecognizer(self.tripleTap)
          self.viewerOpeView.addGestureRecognizer(self.myPan)
          self.viewerOpeView.addGestureRecognizer(self.swipeLeft)
          self.viewerOpeView.addGestureRecognizer(self.swipeRight)

      })
      

      
    }*/
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



 
  
  // MARK: - 再生関連
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
      //L slide
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
      //R slide
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
                                self.frameViewR.alpha=1
                                self.frameViewL.alpha=1
                                self.frameViewR.frame.origin.x = self.screenWidth / 2
                                self.frameViewL.frame.origin.x = 0
                                self.mainLabelView.alpha=0
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
                    self.selectedModeLabel.text = ""
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
                                self.frameViewR.alpha=1
                                self.frameViewL.alpha=1
                                self.frameViewR.frame.origin.x = self.screenWidth / 2
                                self.frameViewL.frame.origin.x = 0
                                self.mainLabelView.alpha=0
                                
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
                
                self.selectedModeLabel.text = ""
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
    
    self.selectedModeLabel.text = ""
    cameraView.frame = scanSizeSet(cameraView)
    intervaltime = intervalTimeSet(cameraView,speed:scanSpeedTable[speed])
    print("intervaltime:",intervaltime)
    let stepNum = Int(intervaltime * 1/stampSpeedTable[viewerSettingData.1])
    let stepSize = cameraView.frame.size.width / CGFloat(stepNum)

    
    cameraView.frame = scanSizeSet(cameraView)
    cameraView.alpha = 1
    
    let rightImagePoint :CGFloat! = self.screenWidth * 0.5 - self.cameraView.frame.width - (self.viewerSettingData.2)
  let leftImagePoint : CGFloat! = self.screenWidth * 0.5 + (self.viewerSettingData.2)
    print("stepSize:",stepSize,"num:",stepNum)
    
  switch style {
    case 0:
  //newScanPlay(leftImagePoint, endX: rightImagePoint,mode:mode,stepSize:stepSize,stepNum:stepNum)
  scanPlay(leftImagePoint, endX: rightImagePoint,mode:mode,speed:speed)
    case 1:
      // newScanPlay(rightImagePoint, endX:  leftImagePoint,mode:mode,stepSize:stepSize,stepNum:stepNum)
    scanPlay(rightImagePoint, endX: leftImagePoint,mode:mode,speed:speed)
    default:
    stampPlay(mode,speed:speed)
    break
  }
}
  
  func backMenu(){
     scanSizeFit(cameraView)
    cameraView.alpha=0
    frameViewR.alpha=0
    frameViewL.alpha=0

    UIView.animateWithDuration(0.3, animations: { () -> Void in
      self.viewerOpeView.alpha = 1.0
      self.myToolBar.alpha = 1
      
      
      self.viewerOpeView.center = self.buttonMainCenter
      //扉オープん
      //self.frameViewR.frame.origin.x = self.screenWidth / 2 + (self.viewerSettingData.2)
      //self.frameViewL.frame.origin.x = -1 * (self.viewerSettingData.2)
      self.cameraView.alpha = 0.3
      self.mainLabelView.alpha=1

      },completion: { finished in
        
        self.addImageButton.enabled = true
        self.phaize = 0
        print("backMenu Finished\nphaze:",self.phaize)
    })
  }
  func closingPlayImage() {
    print("closingPlayImage()")
    cameraView.layer.removeAllAnimations()
    UIView.animateWithDuration(0.3, animations: { () -> Void in
      //一度、真っ黒に扉が閉じる
      self.frameViewR.frame.origin.x = self.screenWidth / 2
      self.frameViewL.frame.origin.x = 0
      },completion: { finished in
        self.phaize = 3
        print("phaze:",self.phaize)
        self.cameraView.frame.origin.x = self.screenWidth / 2 - (self.viewerSettingData.2)
        
    })
  }
  

  
  
  // MARK: - SlidePlay関連
  
  func steppigPlay(endX:CGFloat,stepSize:CGFloat){
    //print("x=",self.cameraView.frame.origin.x,"end:",endX,"stepSize:",stepSize)
    let interval = 1 / ((intervaltime * 1/stampSpeedTable[viewerSettingData.1]))
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64( interval * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
      self.cameraView.frame.origin.x = self.cameraView.frame.origin.x - stepSize
      //print("x=",self.cameraView.frame.origin.x)
      if(self.cameraView.frame.origin.x  < endX){
        self.closingPlayImage()
      }else{
        self.steppigPlay(endX,stepSize:stepSize)
      }
      
    }//遅延
    

    /*
     
     //移動の合間に、黒を入れる処理をしたが、うまくいかない。
     print("x=",self.cameraView.frame.origin.x,"end:",endX,"stepSize:",stepSize)
    let interval = 1 / (defaultScanStep * 2)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64( interval * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
      self.cameraView.alpha = 1
      
      print("1/120秒")
        self.cameraView.frame.origin.x = self.cameraView.frame.origin.x - stepSize
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(interval * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
        print("1/120秒_黒")
        print("x=",self.cameraView.frame.origin.x)
        if(self.cameraView.frame.origin.x  < endX){
          self.closingPlayImage()
        }else{
          self.cameraView.alpha = 0.0
          self.steppigPlay(endX,stepSize:stepSize)
        }
        
        
      }//遅延
      
    }//遅延
 
 */
  }
  
  func steppigLoopPlay(startX:CGFloat,endX:CGFloat,stepSize:CGFloat){
    //print("x=",self.cameraView.frame.origin.x,"end:",endX,"stepSize:",stepSize)
    let interval = 1 / ((intervaltime * 1/stampSpeedTable[viewerSettingData.1]))
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64( interval * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
      
      self.cameraView.frame.origin.x = self.cameraView.frame.origin.x - stepSize
      //print("x=",self.cameraView.frame.origin.x)
      if(self.cameraView.frame.origin.x  < endX){
        self.cameraView.frame.origin.x = startX
      }
      self.steppigLoopPlay(startX,endX:endX,stepSize:stepSize)
      
    }
  }
  
  
  func newScanPlay(startX:CGFloat,endX:CGFloat,mode:Int8,stepSize:CGFloat,stepNum:Int){
    print(" newScanPlay")
      cameraView.contentMode = .ScaleToFill
      cameraView.frame.origin.x = startX
      scanPlayAtoB = [startX,endX]
      UIView.animateWithDuration(0.1,
                                 animations: {() -> Void in
                                  //扉オープん
                                  if(stepSize>(self.viewerSettingData.2)){
                                    print("設定していたバーサイズより、ステップサイズの方が　大きいので勝手に適応する")
                                    self.frameViewR.frame.origin.x = self.screenWidth / 2 + stepSize
                                    self.frameViewL.frame.origin.x = -1 * stepSize
                                  }else{
                                  self.frameViewR.frame.origin.x = self.screenWidth / 2 + (self.viewerSettingData.2)
                                  self.frameViewL.frame.origin.x = -1 * (self.viewerSettingData.2)
                                  }
        },completion: { finished in
          if(mode == 0){
            self.phaize = 2
            print("mode0,phaze:",self.phaize)
             self.steppigPlay(endX,stepSize:stepSize)
            //single mode
           /* for i in 1.stride(to: stepNum+1, by: 1){
            print("\(i)回\(stepNum)")
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.016 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
              print("1/60秒")
              if(startX > 0){
              self.cameraView.frame.origin.x = self.cameraView.frame.origin.x - stepSize
              }else{
              self.cameraView.frame.origin.x = self.cameraView.frame.origin.x + stepSize
              }
              print("x=",self.cameraView.frame.origin.x)
              if(i == stepNum){
                self.closingPlayImage()
              }

              }//遅延
          }//for
            */
          }else if(mode == 1){
            self.phaize = 6
            print("phaze:",self.phaize)
            //self.view.addGestureRecognizer(self.viewTap)
            self.steppigLoopPlay(startX,endX:endX,stepSize:stepSize)
            //loop mode
           
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
  
  
  func scanPlay(startX:CGFloat,endX:CGFloat,mode:Int8,speed:Int){
    cameraView.contentMode = .ScaleToFill
    cameraView.frame.origin.x = startX
    scanPlayAtoB = [startX,endX]
    intervaltime = intervalTimeSet(cameraView,speed:scanSpeedTable[speed])
    
      UIView.animateWithDuration(0.1,
                               animations: {() -> Void in
                                //扉オープん
                                self.frameViewR.frame.origin.x = self.screenWidth / 2 + (self.viewerSettingData.2)
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

  func closingTapScanMode() {
    print("closingTapScanMode()")
    cameraView.layer.removeAllAnimations()
    UIView.animateWithDuration(0.3, animations: { () -> Void in
      //一度、真っ黒に扉が閉じる
      self.frameViewR.frame.origin.x = self.screenWidth / 2
      self.frameViewL.frame.origin.x = 0
      },completion: { finished in
        self.backMenu()
    })
  }
  func stopPlayTapped(gestureRecognizer: UITapGestureRecognizer){
    print("stopPlayTapped")
    self.closingPlayImage()
  }

  // MARK: - タイマー、nofitication
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
      //メニューウィンドウで、ピンチした時、
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
        self.noActionTimer = self.noActionTimer + 1
        print("tenCStimer:",self.noActionTimer)
        if(self.noActionTimer > 6){
           self.scanSizeFit(self.cameraView)
          
          UIView.animateWithDuration(0.5,
                                     animations: {() -> Void in
                                      self.frameViewR.alpha=0
                                      self.frameViewL.alpha=0
                                      self.cameraView.alpha = 0.3
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
            //infoボタン押された時
      
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
        self.noActionTimer = self.noActionTimer + 1
        print("tenCStimer:",self.noActionTimer)
      if(self.noActionTimer > 10){
          UIView.animateWithDuration(0.5,
                                     animations: {() -> Void in
                                      
                                      self.cameraView.alpha = 0.3
          },completion: { finished in
          })
        }//if
   if(self.noActionTimer > 100){
    
    self.scanSizeFit(self.cameraView)
          UIView.animateWithDuration(0.5,
                                     animations: {() -> Void in
                                      self.frameViewR.alpha=0
                                      self.frameViewL.alpha=0
                                      self.viewerOpeView.center.y =  self.buttonMainCenter.y
                                      self.myToolBar.alpha = 1
                                      self.editParametorViewChange(1)
            },completion: { finished in
              /*self.viewerInfoButton.setImage(UIImage(named:"up-alpha-nega-100px.png"), forState: UIControlState.Normal)
              UIView.animateWithDuration(0.3,
                animations: {() -> Void in
                  self.viewerInfoButton.alpha=1
                },completion: { finished in
              })*/
              self.phaize = 0
              print("phaze:",self.phaize)
              self.barSizeChangeAnimationCompleted = true
              self.noActionTimer = 0
              
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
  
  


  // MARK: - Stamp関連
  
  /*
   stamp tap
   */
  internal func prePreStampPlay(sender:UITapGestureRecognizer){
    print(sender.numberOfTouches())
    print("Taptag:",sender.view?.tag)
    if(sender.numberOfTouches() == 1 ){
      print("シングルタップ！")

      prePlay(2, mode: Int8(AsignData[3]), speed:(viewerSettingData.3))
      viewerStyleMode = [2,Int8(AsignData[3])]
    }else if(sender.numberOfTouches() == 2){
      print("ダブルタップ！")
      prePlay(2, mode: Int8(AsignData[4]), speed:(viewerSettingData.3))
      viewerStyleMode = [2,Int8(AsignData[4])]
    }else if(sender.numberOfTouches() == 3){
      print("トリプルタップ！")
      prePlay(2, mode: Int8(AsignData[5]), speed:(viewerSettingData.3))
      viewerStyleMode = [2,Int8(AsignData[5])]
    }
    switch AsignData[sender.numberOfTouches()+2] {
    case 0:
      self.selectedModeLabel.text = "Single Stamp Mode"
    case 2:
      self.selectedModeLabel.text = "Tap & Stamp Fire Mode"
    case 3:
      self.selectedModeLabel.text = "Freeze & Stamp Fire Mode"
    default:
     break
    }
    
  }
  
  internal func tappdDouble(sender:UITapGestureRecognizer){
    print("ダブルタップ！")
    prePlay(2, mode: 1, speed:(viewerSettingData.3))
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
      cameraView.frame.size = CGSizeMake(screenWidth*CGFloat(viewerSettingData.4)*0.01,screenHeight*CGFloat(viewerSettingData.4)*0.01)
      cameraView.center=CGPoint(x: screenWidth/2,y: screenHeight/2)
      
      
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
    case 2:
      self.phaize = 9
      print("phaze:",self.phaize)
      //helpを出すタイマースタート
      self.oneSecondTimer()
      //イメージをフルスクリーン
      cameraView.contentMode = .ScaleAspectFit
      cameraView.frame.size = CGSizeMake(screenWidth*CGFloat(viewerSettingData.4)*0.01,screenHeight*CGFloat(viewerSettingData.4)*0.01)
      cameraView.center=CGPoint(x: screenWidth/2,y: screenHeight/2)
      
      stampTime = stampSpeedTable[speed] * Double(NSEC_PER_SEC)
      
     case 3:
      self.phaize = 10
      print("phaze:",self.phaize)
      //helpを出すタイマースタート
      //self.oneSecondTimer()
      //イメージをフルスクリーン
      cameraView.contentMode = .ScaleAspectFit
      cameraView.frame.size = CGSizeMake(screenWidth*CGFloat(viewerSettingData.4)*0.01,screenHeight*CGFloat(viewerSettingData.4)*0.01)
      cameraView.center=CGPoint(x: screenWidth/2,y: screenHeight/2)
      
      stampTime = stampSpeedTable[speed] * Double(NSEC_PER_SEC)
      
     // print("gyroActive: ",myMotionManager.gyroActive
      
      myMotionManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()!,withHandler:gyroHandler)
      print("gyroActive: ",myMotionManager.gyroActive)
      
    default:
      break

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
  
  // MARK: - メイン画面での操作、ジェスチャー関連
  
  func setMainLabel(){
//    scanintervalLabel.text = String(format: "%.2fsec",intervalTimeSet(cameraView,speed:scanSpeedTable[ (viewerSettingData.0)])) + "\nsize:"+String(viewerSettingData.2)+"px"
//    
//    stampIntervalLabel.text = stampSpStringTable[(viewerSettingData.3)]+"sec"+"\nsize:"+String(viewerSettingData.4)+"%"

    scanintervalLabel.text = String(format: "%.2fsec",intervalTimeSet(cameraView,speed:scanSpeedTable[ (viewerSettingData.0)]))
    
    stampIntervalLabel.text = stampSpStringTable[(viewerSettingData.3)]+"sec"
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
//  print("pichi:\\t\(firstPoint)\t\(secondPoint)")
      (viewerSettingData.2) = (viewerSettingData.2) + secondPoint / 2
    if((viewerSettingData.2) < 1){
      (viewerSettingData.2) = 1
    }else if((viewerSettingData.2) > (screenWidth / 2 - 1)){
    (viewerSettingData.2) = (screenWidth / 2 - 1)
    }
    
    frameViewR.frame.origin.x = screenWidth/2 + (viewerSettingData.2)
    frameViewL.frame.origin.x = -1 * (viewerSettingData.2)
    //cameraView.frame.origin.x = screenWidth/2 - (viewerSettingData.2)
//    lightBarSizeLabel.text = String(format: "%.0fpx",(viewerSettingData.2))
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
                                self.frameViewR.alpha=1
                                self.frameViewL.alpha=1
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
    // 9 = tap Stamp mode Redy
    noActionTimer = 0
    stampFire()
  }else if(phaize == 8){
    print("viewTap、phaize8の動作")
    self.scanSizeFit(self.cameraView)
    UIView.animateWithDuration(0.5,
                               animations: {() -> Void in
                                self.frameViewR.alpha=0
                                self.frameViewL.alpha=0
                                self.cameraView.alpha = 0.3
                                self.viewerOpeView.center.y =  self.buttonMainCenter.y
                                self.myToolBar.alpha = 1
                                self.editParametorViewChange(1)
                                //self.viewerInfoButton.alpha=0
                                
      },completion: { finished in
        /*
        self.viewerInfoButton.setImage(UIImage(named:"up-alpha-nega-100px.png"), forState: UIControlState.Normal)
        UIView.animateWithDuration(0.3,
          animations: {() -> Void in
            self.viewerInfoButton.alpha=1
          },completion: { finished in
        })*/
        self.phaize = 0
        print("phaze:",self.phaize)
        self.barSizeChangeAnimationCompleted = true
        self.noActionTimer = 0
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
    print(movesize.x,movesize.y,sender.numberOfTouches())
    //let maxsize:CGFloat!
    //パンした指についてくる。離すと戻る。
    let modeNum:Int
    if(sender.numberOfTouches() > 0){
      print(buttonMainCenter.x,buttonMainCenter.y)
      print("viewerOpeView.center:",viewerOpeView.center.x,viewerOpeView.center.y)
      
        viewerOpeView.center = CGPointMake(buttonMainCenter.x + movesize.x,buttonMainCenter.y + movesize.y )
        modeNum = Int(sender.numberOfTouches()-1)
      
      if(AsignData[modeNum] == 0){
        selectedModeLabel.text = "Single Slide Mode"
      }else if(modeNum == 1){
        selectedModeLabel.text = "Loop Slide Mode"
      }else{
      selectedModeLabel.text = "Tap and Fire Mode"
      }
      
      
        if( viewerOpeView.center.x < screenWidth/8){
          print("phaze:",self.phaize)
          
          self.prePlay(0, mode: Int8(AsignData[modeNum]),speed:(viewerSettingData.0))
          
          viewerStyleMode = [0,Int8(AsignData[modeNum])]
        }else if(viewerOpeView.center.x > screenWidth * 0.8){
            print("start direction Right, mode =" ,modeNum)
          self.prePlay(1, mode: Int8(AsignData[modeNum]),speed:(viewerSettingData.0))
          viewerStyleMode = [1,Int8(AsignData[modeNum])]
          }
    }else{
      if(phaize == 0){
        print("ボタンバック")
        self.selectedModeLabel.text = ""
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
  
  
  
  internal func setTapGesture(sender: UITapGestureRecognizer){
    noActionTimer = 0
  print("tap:",sender.view?.tag)
    let ui_label: UILabel = sender.view as! UILabel
    switch sender.view?.tag{
    case 11?:
      print("tag11")
      var diffPoint:Int = (viewerDataBuffer.0) + 1
      print("tag11-0",diffPoint)
      if(diffPoint > ((scanSpeedTable.count)-1)){
        diffPoint = 0
      }
        ui_label.text = String(format: "Speed\n%.2fsec",intervalTimeSet(cameraView,speed:scanSpeedTable[diffPoint]))
        (viewerSettingData.0) = diffPoint
        (viewerDataBuffer.0) = (viewerSettingData.0)
    case 12?:
      print("12tap")
      var diffPoint:Int = (viewerDataBuffer.1)+1
      print("tag12-0",diffPoint)
      
      if(diffPoint > ((stampSpStringTable.count)-1)){
        diffPoint = 3
      }
      print("tag12-1",diffPoint)
      
      ui_label.text = "FlashRate\n"+stampSpStringTable[diffPoint]
        (viewerSettingData.1) = diffPoint
        (viewerDataBuffer.1) = (viewerSettingData.1)
      
    case 13?:
      print("tag13")
      var addedPoint:CGFloat = (viewerDataBuffer.2) + 3
      frameViewR.alpha=1
      frameViewL.alpha=1
      cameraView.alpha=1
      scanSizeFit(cameraView)
      if(addedPoint > (screenWidth / 2 - 1)){
        addedPoint = 1
      }

        ui_label.text = String(format: "BarSize\n%.0fpx",addedPoint)
        (viewerSettingData.2) = addedPoint
        (viewerDataBuffer.2) = (viewerSettingData.2)
        print("tag13-2",(viewerDataBuffer.2))
        frameViewR.frame.origin.x = screenWidth / 2 + (viewerSettingData.2)
        frameViewL.frame.origin.x = -1 * (viewerSettingData.2)
        cameraView.frame.origin.x = screenWidth / 2 - (viewerSettingData.2)
    case 14?:
      print("tag14")
      var diffPoint:Int = (viewerDataBuffer.3)+1
      print("tag14-0",diffPoint)
      
      if(diffPoint > ((stampSpStringTable.count)-1)){
        diffPoint = 0
      }
      print("tag14-1",diffPoint)
        ui_label.text = "Speed\n"+stampSpStringTable[diffPoint]
        (viewerSettingData.3) = diffPoint
        (viewerDataBuffer.3) = (viewerSettingData.3)
      
      
    case 15?:
      print("tag15")
      //扉を消して画像を表示
      frameViewR.alpha=0
      frameViewL.alpha=0
      //イメージをフルスクリーン
      cameraView.alpha=1
      cameraView.contentMode = .ScaleAspectFit
      var diffPoint:Int = (viewerDataBuffer.4)+10
      print("tag15-0",diffPoint)
      if(diffPoint > 200){
        diffPoint = 50
      }
        ui_label.text = "Size\n"+String(diffPoint)+"%"
        (viewerSettingData.4) = diffPoint
        (viewerDataBuffer.4) = (viewerSettingData.4)
        cameraView.frame = CGRectMake(0,0,screenWidth*CGFloat(viewerSettingData.4)*0.01,screenHeight*CGFloat(viewerSettingData.4)*0.01)
        cameraView.center=CGPoint(x: screenWidth/2,y: screenHeight/2)
    case 17?:
      print("tag17")
      let diffPoint:Int = abs(AsignBuffer[0] + 1)%3
        ui_label.text = AsignStringTable[diffPoint]
        AsignData[0] = diffPoint
        AsignBuffer[0] = AsignData[0]
    case 18?:
      print("tag18")
      let diffPoint:Int = abs(AsignBuffer[1]+1)%3
        ui_label.text = AsignStringTable[diffPoint]
        AsignData[1] = diffPoint
        AsignBuffer[1] = AsignData[1]
    case 19?:
      print("tag19")
      let diffPoint:Int = abs(AsignBuffer[2] + 1) % 3
              ui_label.text = AsignStringTable[diffPoint]
        AsignData[2] = diffPoint
        AsignBuffer[2] = AsignData[2]
    case 20?:
      print("tag20")
      var diffPoint:Int = abs(AsignBuffer[3] + 1)%3
      if(diffPoint > 0){
        diffPoint += 1 //StampにはLoopModeがないので、
      }
        ui_label.text = AsignStringTable[diffPoint]
        AsignData[3] = diffPoint
        AsignBuffer[3] = AsignData[3]
    case 21?:
      print("tag21")
      var diffPoint:Int = abs(AsignBuffer[4] + 1)%3
      if(diffPoint > 0){
        diffPoint += 1 //StampにはLoopModeがないので、
      }
        ui_label.text = AsignStringTable[diffPoint]
        AsignData[4] = diffPoint
        AsignBuffer[4] = AsignData[4]
    case 22?:
      print("tag22")
      var diffPoint:Int = abs(AsignBuffer[5]+1)%3
      if(diffPoint > 0){
        diffPoint += 1 //StampにはLoopModeがないので、
      }
        ui_label.text = AsignStringTable[diffPoint]
        AsignData[5] = diffPoint
        AsignBuffer[5] = AsignData[5]
    case 23?:
      print("tag23 フォルトに戻す。")
      
      //デフォルトに戻す。
      viewerSettingData = viewerDefaultSettingData
      viewerDataBuffer = viewerSettingData
      
      scanSpeedSetCircle.text = String(format: "Speed\n%.2fsec",intervalTimeSet(cameraView,speed:scanSpeedTable[ viewerSettingData.0]))
      scanintervalLabel.text = String(format: "%.2fsec",intervalTimeSet(cameraView,speed:scanSpeedTable[viewerSettingData.0]))
      
      lightBarSizeSetCircle.text = String(format: "BarSize\n%.0fpx",viewerSettingData.2)
      frameViewR.frame.origin.x = screenWidth / 2 + (viewerSettingData.2)
      frameViewL.frame.origin.x = -1 * (viewerSettingData.2)
      cameraView.frame.origin.x = screenWidth / 2 - (viewerSettingData.2)
//      lightBarSizeLabel.text = String(format: "%.0fpx",(viewerSettingData.2))
      
      stampSpeedSetCircle.text = "Speed\n"+stampSpStringTable[ (viewerSettingData.3)]
      stampIntervalLabel.text = stampSpStringTable[ (viewerSettingData.3)]
      
      stampSizeSetCircle.text = "Size\n"+String(viewerSettingData.4)+"%"
      cameraView.frame = CGRectMake(0,0,screenWidth*CGFloat(viewerSettingData.4)*0.01,screenHeight*CGFloat(viewerSettingData.4)*0.01)
      cameraView.center=CGPoint(x: screenWidth/2,y: screenHeight/2)
      
    default:
      
      break

    }
    setMainLabel()
  }
  /*
   パン.
   */
  internal func setPanGesture(sender: UIPanGestureRecognizer){
    let movesizeY = Int(sender.translationInView(self.view).y/20 )
    let movesizeFullY = Int(sender.translationInView(self.view).y)
    let ui_label: UILabel = sender.view as! UILabel
    noActionTimer = 0
    switch sender.view?.tag{
    case 11?:
      print("tag11")
      var diffPoint:Int = (viewerDataBuffer.0) + movesizeY
      print("tag11-0",diffPoint)
      if(diffPoint < 0){
        diffPoint = 0
      }else if(diffPoint > ((scanSpeedTable.count)-1)){
        diffPoint = (scanSpeedTable.count)-1
      }
      print("tag11-1",diffPoint)
      if(sender.numberOfTouches() > 0){
        ui_label.text = String(format: "%.2fsec",intervalTimeSet(cameraView,speed:scanSpeedTable[diffPoint]))
      }else{
        ui_label.text = String(format: "Speed\n%.2fsec",intervalTimeSet(cameraView,speed:scanSpeedTable[diffPoint]))
        (viewerSettingData.0) = diffPoint
         (viewerDataBuffer.0) = (viewerSettingData.0)
      
      }
    case 12?:
      print("tag12")
      var diffPoint:Int = (viewerDataBuffer.1) + movesizeY
      print("tag12-0",diffPoint)
      
      if(diffPoint < 3){
        diffPoint = 3
      }else if(diffPoint > ((stampSpStringTable.count)-1)){
        diffPoint = (stampSpStringTable.count)-1
      }
      print("tag12-1",diffPoint)
      
      if(sender.numberOfTouches() > 0){
        ui_label.text = stampSpStringTable[diffPoint]
      }else{
        ui_label.text = "FlashRate\n"+stampSpStringTable[diffPoint]
        (viewerSettingData.1) = diffPoint
        (viewerDataBuffer.1) = (viewerSettingData.1)
        
      }


    case 13?:
      print("tag13")
      var addedPoint:CGFloat = (viewerDataBuffer.2) + sender.translationInView(self.view).y
      //扉を表示
      frameViewR.alpha=1
      frameViewL.alpha=1
      cameraView.alpha=1
      scanSizeFit(cameraView)
      if(addedPoint < 1){
          addedPoint = 1
        }else if(addedPoint > (screenWidth / 2 - 1)){
          addedPoint = (screenWidth / 2 - 1)
        }
      print("tag13-(-1)",addedPoint)
      
      if(sender.numberOfTouches() > 0){
       ui_label.text = String(format: "%.0fpx",addedPoint)
        frameViewR.frame.origin.x = screenWidth / 2 + addedPoint
        frameViewL.frame.origin.x = -1 * addedPoint
        cameraView.frame.origin.x = screenWidth / 2 - addedPoint
      }else{
        print("tag13-0",addedPoint)
        ui_label.text = String(format: "BarSize\n%.0fpx",addedPoint)
        print("tag13-1",addedPoint)
        (viewerSettingData.2) = addedPoint
        
        (viewerDataBuffer.2) = (viewerSettingData.2)
        print("tag13-2",(viewerDataBuffer.2))
        frameViewR.frame.origin.x = screenWidth / 2 + (viewerSettingData.2)
        frameViewL.frame.origin.x = -1 * (viewerSettingData.2)
        cameraView.frame.origin.x = screenWidth / 2 - (viewerSettingData.2)
//        lightBarSizeLabel.text = String(format: "%.0fpx",(viewerSettingData.2))
        print("buffer:",(viewerDataBuffer.2),"addpoint:",addedPoint)

      }
    case 14?:
      print("tag14")
      var diffPoint:Int = (viewerDataBuffer.3) + movesizeY
      print("tag14-0",diffPoint)
      
      if(diffPoint < 0){
        diffPoint = 0
      }else if(diffPoint > ((stampSpStringTable.count)-1)){
        diffPoint = (stampSpStringTable.count)-1
      }
      print("tag14-1",diffPoint)
      
      if(sender.numberOfTouches() > 0){
        ui_label.text = stampSpStringTable[diffPoint]
      }else{
        ui_label.text = "Speed\n"+stampSpStringTable[diffPoint]
        (viewerSettingData.3) = diffPoint
        (viewerDataBuffer.3) = (viewerSettingData.3)
        
      }
    case 15?:
      print("tag15")
      //扉を消して画像を表示
      frameViewR.alpha=0
      frameViewL.alpha=0
      //イメージをフルスクリーン
      cameraView.alpha=1
      cameraView.contentMode = .ScaleAspectFit
      var diffPoint:Int = (viewerDataBuffer.4)+movesizeFullY
      print("tag15-0",diffPoint)
      if(diffPoint < 0){
        diffPoint = 0
      }else if(diffPoint > 400){
        diffPoint = 400
      }
      print("tag15-1",diffPoint)
      if(sender.numberOfTouches() > 0){
        ui_label.text = String(diffPoint) + "%"
        
        cameraView.frame = CGRectMake(0,0,screenWidth*CGFloat(diffPoint)*0.01,screenHeight*CGFloat(diffPoint)*0.01)
        cameraView.center=CGPoint(x: screenWidth/2,y: screenHeight/2)
      }else{
        ui_label.text = "Size\n"+String(diffPoint)+"%"
        (viewerSettingData.4) = diffPoint
        (viewerDataBuffer.4) = (viewerSettingData.4)
  
        cameraView.frame = CGRectMake(0,0,screenWidth*CGFloat(viewerSettingData.4)*0.01,screenHeight*CGFloat(viewerSettingData.4)*0.01)
        cameraView.center=CGPoint(x: screenWidth/2,y: screenHeight/2)
      }
      
      
      

     case 17?:
        print("tag17")
        let diffPoint:Int = abs(AsignBuffer[0] + movesizeY)%3
        if(sender.numberOfTouches() > 0){
          ui_label.text = AsignStringTable[diffPoint]
        }else{
          ui_label.text = AsignStringTable[diffPoint]
          AsignData[0] = diffPoint
          AsignBuffer[0] = AsignData[0]
        }
     case 18?:
        print("tag18")
        let diffPoint:Int = abs(AsignBuffer[1] + movesizeY)%3
        if(sender.numberOfTouches() > 0){
          ui_label.text = AsignStringTable[diffPoint]
        }else{
          ui_label.text = AsignStringTable[diffPoint]
          AsignData[1] = diffPoint
          AsignBuffer[1] = AsignData[1]
      }

     case 19?:
        print("tag19")
        let diffPoint:Int = abs(AsignBuffer[2] + movesizeY) % 3
        if(sender.numberOfTouches() > 0){
          ui_label.text = AsignStringTable[diffPoint]
        }else{
          ui_label.text = AsignStringTable[diffPoint]
          AsignData[2] = diffPoint
          AsignBuffer[2] = AsignData[2]
      }

     case 20?:
        print("tag20")
        var diffPoint:Int = abs(AsignBuffer[3] + movesizeY)%3
        if(diffPoint > 0){
          diffPoint += 1 //StampにはLoopModeがないので、
        }
        if(sender.numberOfTouches() > 0){
          ui_label.text = AsignStringTable[diffPoint]
          
        }else{
          ui_label.text = AsignStringTable[diffPoint]
          AsignData[3] = diffPoint
          AsignBuffer[3] = AsignData[3]
      }

     case 21?:
        print("tag21")
        var diffPoint:Int = abs(AsignBuffer[4] + movesizeY)%3
        if(diffPoint > 0){
          diffPoint += 1 //StampにはLoopModeがないので、
        }
        if(sender.numberOfTouches() > 0){
          ui_label.text = AsignStringTable[diffPoint]
          
        }else{
          ui_label.text = AsignStringTable[diffPoint]
          AsignData[4] = diffPoint
          AsignBuffer[4] = AsignData[4]
      }

     case 22?:
        print("tag22")
        var diffPoint:Int = abs(AsignBuffer[5] + movesizeY)%3
        if(diffPoint > 0){
          diffPoint += 1 //StampにはLoopModeがないので、
        }
        if(sender.numberOfTouches() > 0){
          ui_label.text = AsignStringTable[diffPoint]
          
        }else{
          ui_label.text = AsignStringTable[diffPoint]
          AsignData[5] = diffPoint
          AsignBuffer[5] = AsignData[5]
      }


    default:
      break
    }
    
    if(sender.numberOfTouches() > 0){
      sender.view?.alpha = 1.0
      sender.view?.backgroundColor = UIColor(red: 0,green: 0,blue: 0,alpha: 0.5)
      print("panning:",movesizeY)
    }else{
      sender.view?.alpha = 0.8
      sender.view?.backgroundColor = UIColor.clearColor()
      print("end:",movesizeY)
      //メインビューのラベルに反映
      setMainLabel()
      
    }
    
    
  }
  
  func editParametorViewChange(direction:Int){
     let setPreferenceYOrigin:CGFloat!
    let setMainYOrigin:CGFloat!
    if(direction == 0){
     setPreferenceYOrigin = 0
    setMainYOrigin = -self.screenHeight}
    else{
      setPreferenceYOrigin = self.screenHeight
       setMainYOrigin = 0
    }
    /*let textInfoSukima:CGFloat = scanSpeedSetCircle.frame.size.height
  scanSpeedSetCircle.center.y = setYCenter
  stampSpeedSetCircle.center.y = setYCenter
  lightBarSizeSetCircle.center.y = setYCenter
    scanSpeedInfoTxt.center.y = setYCenter  + textInfoSukima
   stampSpeedInfoTxt.center.y = setYCenter + textInfoSukima
    lightBarSizeInfoTxt.center.y = setYCenter + textInfoSukima
 */
    preferenceView.frame.origin.y =  setPreferenceYOrigin
    mainLabelView.frame.origin.y = setMainYOrigin
  }
  

  func editInfoViewAppear(){
     if (barSizeChangeAnimationCompleted == false){return}
//     viewerOpeView.removeGestureRecognizer(stampTap)
    print(" editInfoViewAppear")
    phaize = 8
    print("phaze:",self.phaize)
    self.noActionTimer = 0
    viewerDataBuffer = viewerSettingData
    barSizeChangeAnimationCompleted = false
    
    UIView.animateWithDuration(0.3,
                               animations: {() -> Void in
                                self.viewerOpeView.center.y = -1 * self.buttonMainSize.x
                                self.editParametorViewChange(0)
//                                self.cameraView.alpha = 1
                                self.myToolBar.alpha = 0
                                //self.viewerInfoButton.alpha=0
      },completion: { finished in
        /*
        self.viewerInfoButton.setImage(UIImage(named:"down-alpha-nega-100px.png"), forState: UIControlState.Normal)
        UIView.animateWithDuration(0.3,
          animations: {() -> Void in
            self.viewerInfoButton.alpha=1
          },completion: { finished in
        })
        */
        self.tenCentiSecondTimer()
    })

  }
  
  
  internal func  editInfoTapped(sender:UIButton){
    pageControl.currentPage = 1
    preferenceScrollView.contentOffset.x=preferenceView.frame.maxX

   editInfoViewAppear()
    
  }
  internal func upButtonTapped(sender:UIButton){
    if(phaize==0){
    pageControl.currentPage = 0
    preferenceScrollView.contentOffset.x=0
    editInfoViewAppear()
    }else{
      self.scanSizeFit(self.cameraView)
      
      UIView.animateWithDuration(0.5,
                                 animations: {() -> Void in
                                  self.frameViewR.alpha=0
                                  self.frameViewL.alpha=0
                                  self.viewerOpeView.center.y =  self.buttonMainCenter.y
                                  self.myToolBar.alpha = 1
                                  self.editParametorViewChange(1)
        },completion: { finished in
          /*self.viewerInfoButton.setImage(UIImage(named:"up-alpha-nega-100px.png"), forState: UIControlState.Normal)
          UIView.animateWithDuration(0.3,
            animations: {() -> Void in
              self.viewerInfoButton.alpha=1
            },completion: { finished in
          })*/
          self.barSizeChangeAnimationCompleted = true
          self.noActionTimer = 0
          self.phaize = 0
          print("phaze:",self.phaize)
      })
    }
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
      self.prePlay(1,mode:Int8(AsignData[0]),speed:(viewerSettingData.0))
      viewerStyleMode = [1,Int8(AsignData[0])]
    }
    else if sender.direction == .Left {
      print("Left")
      prePlay(0, mode:Int8(AsignData[0]),speed:(viewerSettingData.0))
      viewerStyleMode = [0,Int8(AsignData[0])]
    } else if sender.direction == .Up {
      print("Up")
      if (barSizeChangeAnimationCompleted == false){return}
      print(" editInfoTapped")
      phaize = 8
      print("phaze:",self.phaize)
      
      //どっちの設定画面かを指定しなくてもいいか、、
      //pageControl.currentPage = 0
      //preferenceScrollView.contentOffset.x=0
      
      self.noActionTimer = 0
      viewerDataBuffer = viewerSettingData
      barSizeChangeAnimationCompleted = false
      UIView.animateWithDuration(0.3,
                                 animations: {() -> Void in
                                  self.viewerOpeView.center.y = -1 * self.buttonMainSize.x
                                  self.editParametorViewChange(0)
//                                  self.cameraView.alpha = 1
                                  self.myToolBar.alpha = 0
                                  //self.viewerInfoButton.alpha=0
        },completion: { finished in
          /*self.viewerInfoButton.setImage(UIImage(named:"down-alpha-nega-100px.png"), forState: UIControlState.Normal)
          UIView.animateWithDuration(0.3,
            animations: {() -> Void in
              self.viewerInfoButton.alpha=1
            },completion: { finished in
          })*/
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
                                    //self.viewerInfoButton.alpha=0
          },completion: { finished in
            self.barSizeChangeAnimationCompleted = true
            /*self.viewerInfoButton.setImage(UIImage(named:"up-alpha-nega-100px.png"), forState: UIControlState.Normal)
            UIView.animateWithDuration(0.3,
              animations: {() -> Void in
                self.viewerInfoButton.alpha=1
              },completion: { finished in
            })*/
            self.phaize = 0
            print("phaze:",self.phaize)
            self.noActionTimer = 0
        })

      }
    case 9 :
      if(sender.direction == .Down){
        self.cameraView.contentMode = .ScaleToFill
        self.backMenu()
      }
    case 10:
      if(sender.direction == .Down){
        if(myMotionManager.gyroActive == true){
          print("myMotionManagerを終わらせる")
          myMotionManager.stopGyroUpdates()
        }
        self.cameraView.contentMode = .ScaleToFill
        self.backMenu()
      }

      
    default:
      break
  }
  
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
  

  
  
  
}