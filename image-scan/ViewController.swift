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
    self.alpha = 0.7
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
  
  
   var viewerSettingData=(Int(4),Int(4),CGFloat(100.0),Int(1),Int(100))
   var viewerDataBuffer=(Int(4),Int(4),CGFloat(100.0),Int(1),Int(100))

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
  var phaize:Int8! = 0
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
  var viewerOpeView: UIView! //メインのオペレーションビュー
  var preferenceView: UIView! //設定画面
  var preferenceScrollView:UIScrollView!//スクロールビュー
  var pageControl:UIPageControl!
  var opeImage:UIImageView! //サブビュー
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
    if(screenWidth < screenHeight){
      print("縦長！画面")
      step  = screenWidth / 20

      buttonMainCenter = CGPointMake(screenWidth/2,screenHeight * 2 / 5)
      buttonMainSize = CGPointMake(screenWidth * 0.8, screenWidth * 0.8)
      
      //LightBar サイズの設定 縦：横＝1 : 0.01
      (viewerSettingData.2) = screenWidth * 0.01
      print("tuple:",viewerSettingData)
      viewerDataBuffer = viewerSettingData
    }else{
      
      print("横長！画面")
      step  = screenWidth / 30

      buttonMainCenter = CGPointMake(screenWidth/2,screenHeight * 2 / 5)
      buttonMainSize = CGPointMake(screenHeight * 0.4, screenHeight * 0.4)
      
      //LightBar サイズの設定 縦：横＝1 : 0.01
      (viewerSettingData.2) = screenHeight * 0.01
      print("tuple:",viewerSettingData)
      viewerDataBuffer = viewerSettingData
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
    
    //Playボタンのカスタマイズ
    viewerOpeView = UIView(frame: countRect)
    viewerOpeView.center=buttonMainCenter
    viewerOpeView.layer.masksToBounds = true
//    viewerOpeView.layer.borderColor = UIColor.darkGrayColor().CGColor
//    viewerOpeView.layer.borderWidth = step / 3
    viewerOpeView.layer.cornerRadius = viewerOpeView.frame.width / 2
    viewerOpeView.backgroundColor = UIColor.clearColor()
    
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
    
    
    preferenceCircleRect = CGRectMake(0,0,buttonMainSize.x/3.3,buttonMainSize.x/3.3)
    scanSpeedSetCircle = UILabel(frame:preferenceCircleRect)
    scanSpeedSetCircle.text = "1sec"
    scanSpeedSetCircle.infoLabelformat()
    scanSpeedSetCircle.center = preferenceGridCenterSet(0,ynum:0)
    scanSpeedSetCircle.tag = 11
    scanSpeedSetCircle.addGestureRecognizer( UIPanGestureRecognizer(target: self, action: #selector(ViewController.setPanGesture(_:))))
    scanSpeedSetCircle.alpha = 0.5
    preferenceScrollView.addSubview(scanSpeedSetCircle)
    
    scanFlashSetCircle = UILabel(frame:preferenceCircleRect)
    scanFlashSetCircle.text = "1sec"
    scanFlashSetCircle.infoLabelformat()
    scanFlashSetCircle.center = preferenceGridCenterSet(1,ynum:0)
    scanFlashSetCircle.tag = 12
    scanFlashSetCircle.addGestureRecognizer( UIPanGestureRecognizer(target: self, action: #selector(ViewController.setPanGesture(_:))))
    scanFlashSetCircle.alpha = 0.5
    preferenceScrollView.addSubview(scanFlashSetCircle)
    
    lightBarSizeSetCircle = UILabel(frame:preferenceCircleRect)
    lightBarSizeSetCircle.text = "20px"
    lightBarSizeSetCircle.infoLabelformat()
    lightBarSizeSetCircle.center =  preferenceGridCenterSet(2,ynum:0)
    lightBarSizeSetCircle.tag = 13
    lightBarSizeSetCircle.addGestureRecognizer( UIPanGestureRecognizer(target: self, action: #selector(ViewController.setPanGesture(_:))))
    lightBarSizeSetCircle.alpha = 0.5
    preferenceScrollView.addSubview(lightBarSizeSetCircle)
    
    let  preferenceScanLabel = UILabel(frame:preferenceCircleRect)
    //preferenceScanLabel.text = "S\nL\nI\nD\nE"
    preferenceScanLabel.text = "Slide Play"
    preferenceScanLabel.adjustsFontSizeToFitWidth=true
    preferenceScanLabel.infoLabelformat()
    preferenceScanLabel.layer.borderWidth = 0
    preferenceScanLabel.center = preferenceGridCenterSet(1,ynum:0)
    preferenceScanLabel.center.y = (preferenceScanLabel.center.y)-(preferenceCircleRect.size.height*0.7)
    preferenceScrollView.addSubview(preferenceScanLabel)
    

    
    
    stampSpeedSetCircle = UILabel(frame:preferenceCircleRect)
    stampSpeedSetCircle.text = "1/60"
    stampSpeedSetCircle.infoLabelformat()
    stampSpeedSetCircle.center = preferenceGridCenterSet(0,ynum:1)
    stampSpeedSetCircle.tag = 14
    stampSpeedSetCircle.addGestureRecognizer( UIPanGestureRecognizer(target: self, action: #selector(ViewController.setPanGesture(_:))))
    stampSpeedSetCircle.alpha = 0.5
    preferenceScrollView.addSubview(stampSpeedSetCircle)
    
    stampSizeSetCircle = UILabel(frame:preferenceCircleRect)
    stampSizeSetCircle.text = "100%"
    stampSizeSetCircle.infoLabelformat()
    stampSizeSetCircle.center = preferenceGridCenterSet(1,ynum:1)
    stampSizeSetCircle.tag = 15
    stampSizeSetCircle.addGestureRecognizer( UIPanGestureRecognizer(target: self, action: #selector(ViewController.setPanGesture(_:))))
    stampSizeSetCircle.alpha = 0.5
    preferenceScrollView.addSubview(stampSizeSetCircle)
    
    let  preferenceStampLabel = UILabel(frame:preferenceCircleRect)
    //preferenceStampLabel.text = "S\nT\nA\nM\nP"
    preferenceStampLabel.text = "Stamp play"
    preferenceStampLabel.infoLabelformat()
    preferenceStampLabel.layer.borderWidth = 0
    preferenceStampLabel.center = preferenceGridCenterSet(1,ynum:1)
    preferenceStampLabel.center.y = (preferenceStampLabel.center.y)-(preferenceCircleRect.size.height*0.7)
    preferenceScrollView.addSubview(preferenceStampLabel)
    
    
    
    scan1fAsignSetCircle = UILabel(frame:preferenceCircleRect)
    scan1fAsignSetCircle.text = AsignStringTable[AsignData[0]]
    scan1fAsignSetCircle.infoLabelformat()
    scan1fAsignSetCircle.center = preferenceGridCenterSet(3,ynum:0)
    scan1fAsignSetCircle.tag = 17
    scan1fAsignSetCircle.addGestureRecognizer( UIPanGestureRecognizer(target: self, action: #selector(ViewController.setPanGesture(_:))))
    scan1fAsignSetCircle.alpha = 0.5
    preferenceScrollView.addSubview(scan1fAsignSetCircle)
    
    scan2fAsignSetCircle = UILabel(frame:preferenceCircleRect)
    scan2fAsignSetCircle.text = AsignStringTable[AsignData[1]]
    scan2fAsignSetCircle.infoLabelformat()
    scan2fAsignSetCircle.center = preferenceGridCenterSet(4,ynum:0)
    scan2fAsignSetCircle.tag = 18
    scan2fAsignSetCircle.addGestureRecognizer( UIPanGestureRecognizer(target: self, action: #selector(ViewController.setPanGesture(_:))))
    scan2fAsignSetCircle.alpha = 0.5
    preferenceScrollView.addSubview(scan2fAsignSetCircle)
    
    scan3fAsignSetCircle = UILabel(frame:preferenceCircleRect)
    scan3fAsignSetCircle.text = AsignStringTable[AsignData[2]]
    scan3fAsignSetCircle.infoLabelformat()
    scan3fAsignSetCircle.center =  preferenceGridCenterSet(5,ynum:0)
    scan3fAsignSetCircle.tag = 19
    scan3fAsignSetCircle.addGestureRecognizer( UIPanGestureRecognizer(target: self, action: #selector(ViewController.setPanGesture(_:))))
    scan3fAsignSetCircle.alpha = 0.5
    preferenceScrollView.addSubview(scan3fAsignSetCircle)
    
       let   scanAsignLabel = UILabel(frame:preferenceCircleRect)
    // scanAsignLabel.text = "S\nL\nI\nD\nE"
    scanAsignLabel.text = "Slide Play"
    scanAsignLabel.adjustsFontSizeToFitWidth=true
    scanAsignLabel.infoLabelformat()
    scanAsignLabel.layer.borderWidth = 0
    scanAsignLabel.center = preferenceGridCenterSet(4,ynum:0)
    scanAsignLabel.center.y = (scanAsignLabel.center.y)-(preferenceCircleRect.size.height*0.7)
    preferenceScrollView.addSubview( scanAsignLabel)
    

    
    
    
    
    stamp1fAsignSetCircle = UILabel(frame:preferenceCircleRect)
    stamp1fAsignSetCircle.text = AsignStringTable[AsignData[3]]
    stamp1fAsignSetCircle.infoLabelformat()
    stamp1fAsignSetCircle.center = preferenceGridCenterSet(3,ynum:1)
    stamp1fAsignSetCircle.tag = 20
    stamp1fAsignSetCircle.addGestureRecognizer( UIPanGestureRecognizer(target: self, action: #selector(ViewController.setPanGesture(_:))))
    stamp1fAsignSetCircle.alpha = 0.5
    preferenceScrollView.addSubview(stamp1fAsignSetCircle)
    
    stamp2fAsignSetCircle = UILabel(frame:preferenceCircleRect)
    stamp2fAsignSetCircle.text = AsignStringTable[AsignData[4]]
    stamp2fAsignSetCircle.infoLabelformat()
    stamp2fAsignSetCircle.center = preferenceGridCenterSet(4,ynum:1)
    stamp2fAsignSetCircle.tag = 21
    stamp2fAsignSetCircle.addGestureRecognizer( UIPanGestureRecognizer(target: self, action: #selector(ViewController.setPanGesture(_:))))
    stamp2fAsignSetCircle.alpha = 0.5
    preferenceScrollView.addSubview(stamp2fAsignSetCircle)
    
    stamp3fAsignSetCircle = UILabel(frame:preferenceCircleRect)
    stamp3fAsignSetCircle.text = AsignStringTable[AsignData[5]]
    stamp3fAsignSetCircle.infoLabelformat()
    stamp3fAsignSetCircle.center =  preferenceGridCenterSet(5,ynum:1)
    stamp3fAsignSetCircle.tag = 22
    stamp3fAsignSetCircle.addGestureRecognizer( UIPanGestureRecognizer(target: self, action: #selector(ViewController.setPanGesture(_:))))
    stamp3fAsignSetCircle.alpha = 0.5
    preferenceScrollView.addSubview(stamp3fAsignSetCircle)
    
    
   
    
    let   stampAsignLabel = UILabel(frame:preferenceCircleRect)
    // stampAsignLabel.text = "S\nL\nI\nD\nE"
     stampAsignLabel.text = "Stamp Play"
     stampAsignLabel.adjustsFontSizeToFitWidth=true
     stampAsignLabel.infoLabelformat()
     stampAsignLabel.layer.borderWidth = 0
     stampAsignLabel.center = preferenceGridCenterSet(4,ynum:1)
     stampAsignLabel.center.y = (stampAsignLabel.center.y)-(preferenceCircleRect.size.height*0.7)
    preferenceScrollView.addSubview( stampAsignLabel)
    

    
    
    
    let  preference1stPageLabel = UILabel(frame:preferenceCircleRect)
    preference1stPageLabel.frame.size.width = screenWidth/2
    preference1stPageLabel.text = "Player\nPreference"
    preference1stPageLabel.font = UIFont.systemFontOfSize(CGFloat(30))
    //preference1stPageLabel.font = UIFont.boldSystemFontOfSize(UIFont.labelFontSize())
    preference1stPageLabel.infoLabelformat()
    preference1stPageLabel.layer.cornerRadius = 0
    preference1stPageLabel.layer.borderWidth = 0
    preference1stPageLabel.center = preferenceGridCenterSet(1,ynum:0)
    preference1stPageLabel.center.y = (preference1stPageLabel.center.y)-(preferenceCircleRect.size.height*1.5)
    preferenceScrollView.addSubview(preference1stPageLabel)
    
    let  preference2stPageLabel = UILabel(frame:CGRectMake(screenWidth,screenHeight/4,screenWidth,preferenceCircleRect.height))
    
    preference2stPageLabel.frame.size.width = screenWidth/2
    preference2stPageLabel.text = "Asign\nPreference"
     preference2stPageLabel.font = UIFont.systemFontOfSize(CGFloat(30))
    preference2stPageLabel.infoLabelformat()
    preference2stPageLabel.layer.cornerRadius = 0
    preference2stPageLabel.layer.borderWidth = 0
    preference2stPageLabel.center = preferenceGridCenterSet(4,ynum:0)
    preference2stPageLabel.center.y = (preference2stPageLabel.center.y)-(preferenceCircleRect.size.height*1.5)
    preferenceScrollView.addSubview(preference2stPageLabel)

    
    
    
    
    selectedModeLabel = UILabel(frame: CGRectMake(0,0, screenWidth, 88))
    selectedModeLabel.font=UIFont.systemFontOfSize(CGFloat(30))
    selectedModeLabel.adjustsFontSizeToFitWidth=true
    selectedModeLabel.backgroundColor=UIColor.clearColor()
    selectedModeLabel.textColor = self.view.tintColor
    selectedModeLabel.textAlignment =  NSTextAlignment.Center
    
    
    
    //加速度センサ系の設定
    motionProcess()
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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

    print("center",centerPoint)
    
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
        
        let infoframe:CGRect = CGRectMake(buttonMainSize.x/2-screenWidth * 2 / 10,buttonMainSize.y/2,screenWidth * 4 / 10,screenWidth * 4 / 10)
        let infoSize = CGSizeMake(buttonMainSize.x / 4.2, buttonMainSize.x / 4.2)
        
        scanintervalLabel = UILabel(frame:infoframe)
        scanintervalLabel.frame.size = infoSize
        scanintervalLabel.center.y = buttonMainSize.y * 6.5 / 10
        scanintervalLabel.center.x = buttonMainSize.x / 4
        scanintervalLabel.infoLabelformat()
        scanintervalLabel.text = ""
        scanintervalLabel.tag = 21
//        scanintervalLabel.addGestureRecognizer(stampTap)
//        scanintervalLabel.userInteractionEnabled=true
        viewerOpeView.addSubview(scanintervalLabel)
        
        
        
        stampIntervalLabel = UILabel(frame:infoframe)
        stampIntervalLabel.frame.size = infoSize
        stampIntervalLabel.center.y = buttonMainSize.y * 6.5 / 10
        stampIntervalLabel.center.x = buttonMainSize.x * 2 / 4
        stampIntervalLabel.infoLabelformat()
        stampIntervalLabel.text = ""
        stampIntervalLabel.tag = 22
//        stampIntervalLabel.addGestureRecognizer(stampTap)
//        stampIntervalLabel.userInteractionEnabled=true
        viewerOpeView.addSubview(stampIntervalLabel)
        
        
        lightBarSizeLabel = UILabel(frame:infoframe)
        lightBarSizeLabel.frame.size = infoSize
        lightBarSizeLabel.center.y = buttonMainSize.y * 6.5 / 10
        lightBarSizeLabel.center.x = buttonMainSize.x * 3 / 4
        lightBarSizeLabel.infoLabelformat()
        lightBarSizeLabel.text = ""
         lightBarSizeLabel.tag = 23
//        lightBarSizeLabel.userInteractionEnabled=true
//        lightBarSizeLabel.addGestureRecognizer(stampTap)
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
        self.view.addSubview(selectedModeLabel)
        
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
      
      scanSizeFit(cameraView)
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
     print("タッチした画像のタグ:",touch?.view?.tag,"count:",touches.count)
    if(touch?.view?.tag > 20 && touch?.view?.tag < 24  ){
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
      

      
    }
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
    cameraView.layer.removeAllAnimations()
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
   if(self.noActionTimer > 30){
    
    self.scanSizeFit(self.cameraView)
    
          UIView.animateWithDuration(0.5,
                                     animations: {() -> Void in
                                      self.frameViewR.alpha=0
                                      self.frameViewL.alpha=0
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
      cameraView.frame = CGRectMake(0,0,screenWidth*CGFloat(viewerSettingData.4)*0.01,screenHeight*CGFloat(viewerSettingData.4)*0.01)
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
      cameraView.frame = CGRectMake(0,0,screenWidth,screenHeight)
      stampTime = stampSpeedTable[speed] * Double(NSEC_PER_SEC)
      
     case 3:
      self.phaize = 10
      print("phaze:",self.phaize)
      //helpを出すタイマースタート
      //self.oneSecondTimer()
      //イメージをフルスクリーン
      cameraView.contentMode = .ScaleAspectFit
      cameraView.frame = CGRectMake(0,0,screenWidth,screenHeight)
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
    // 9 = tap Stamp mode 
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
        scanintervalLabel.text = String(format: "%.2fsec",intervalTimeSet(cameraView,speed:scanSpeedTable[diffPoint]))

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
        lightBarSizeLabel.text = String(format: "%.0fpx",(viewerSettingData.2))
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
        stampIntervalLabel.text = stampSpStringTable[diffPoint]
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
      sender.view?.alpha = 0.75
      sender.view?.backgroundColor = UIColor.clearColor()
      print("end:",movesizeY)
      
    }
    
    
  }
  
  func editParametorViewChange(direction:Int){
     let setYOrigin:CGFloat!
    if(direction == 0){
     setYOrigin = 0}
    else{
      setYOrigin = self.screenHeight
    }
    /*let textInfoSukima:CGFloat = scanSpeedSetCircle.frame.size.height
  scanSpeedSetCircle.center.y = setYCenter
  stampSpeedSetCircle.center.y = setYCenter
  lightBarSizeSetCircle.center.y = setYCenter
    scanSpeedInfoTxt.center.y = setYCenter  + textInfoSukima
   stampSpeedInfoTxt.center.y = setYCenter + textInfoSukima
    lightBarSizeInfoTxt.center.y = setYCenter + textInfoSukima
 */
    preferenceView.frame.origin.y =  setYOrigin
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
      },completion: { finished in
        self.tenCentiSecondTimer()
    })

  }
  
  
  internal func  editInfoTapped(sender:UIButton){
    pageControl.currentPage = 1
    preferenceScrollView.contentOffset.x=preferenceView.frame.maxX

   editInfoViewAppear()
    
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