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
    self.textColor = UIColor.blackColor()
    self.backgroundColor = UIColor.whiteColor()
    self.layer.masksToBounds = true
    self.layer.cornerRadius = self.frame.width / 2
    self.textAlignment = NSTextAlignment.Center
  }
}


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
  var lightBarWidth:CGFloat! = 10
  var scanPlayAtoB:[CGFloat]!
  
  
  //多次元配列にパラメーターを保存していく。
var viewerData :[Int8]!
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
  var directionLeft:Bool = true
  var phaize:Int8 = 0
  /*
   0 = menu,
   1 = pre-prePlay,
   2 = play
   3 = done
   4 = ?
   */
  
  
  
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
  var addImageButton: UIButton!
  
  var scanXdataLabel: UILabel!
  var intervalLabel: UILabel!
  var count3Label: UILabel!
  var count2Label: UILabel!
  var count1Label: UILabel!
  
  //ジェスチャー
  var resetTap:UITapGestureRecognizer!
  var stopTap:UITapGestureRecognizer!
  var stampTap:UITapGestureRecognizer!
  var replayTap:UITapGestureRecognizer!
  var myPan:UIPanGestureRecognizer!
  var swipeLeft:UISwipeGestureRecognizer!
  var swipeRight:UISwipeGestureRecognizer!
  
  var stampSpeedTable:[Double]!
  var stampSpStringTable:[String]!
  var scanSpeedTable:[Double]!
  
  

  
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
    
    
    stampSpeedTable = [0.033,0.017,0.011,0.0083,0.0066,0.005]
    stampSpStringTable = ["1/30","1/60","1/90","1/120","1/150","1/200"]
    scanSpeedTable = [0.25,0.5,1.0,1.5,2.0,3.0]
    
    
    //viewerData set 
    viewerData = [0,0] //scan direction Left , single play

    print(UIDevice.currentDevice().localizedModel)
    
    // Screen Size の取得
    screenWidth = self.view.bounds.width
    screenHeight = self.view.bounds.height
    step  = screenWidth / 20
    lightBarWidth = step

    //viewの設定
    self.view.backgroundColor=UIColor.blackColor()
    
    // ピンチを認識.
    let myPinchGesture = UIPinchGestureRecognizer(target: self, action: "pinchGesture:")
    self.view.addGestureRecognizer(myPinchGesture)
    
    
    // パン認識.スワイプ左、右
    resetTap = UITapGestureRecognizer(target: self, action: "resetImage:")
    stopTap = UITapGestureRecognizer(target: self, action: "stopPlayTapped:")
    stampTap = UITapGestureRecognizer(target:self, action:"prePreStampPlay:")
    replayTap = UITapGestureRecognizer(target:self, action:"replayTapped:")
    myPan = UIPanGestureRecognizer(target: self, action: "panGesture:")
    swipeLeft = UISwipeGestureRecognizer(target: self, action: "didSwipe:")
    swipeRight = UISwipeGestureRecognizer(target: self, action: "didSwipe:")
    swipeLeft.direction = .Left
    swipeRight.direction = .Right

    

    cameraView = UIImageView(frame: CGRectMake(0,0,screenWidth,screenHeight))
    //cameraView.contentMode =
    cameraView.image = UIImage(named:"IMG_1485low200pxMetaDataOFF.jpg")
    
    scanXdataLabel = UILabel(frame: CGRectMake(screenWidth * 8 / 10, screenHeight / 10, screenWidth * 2 / 10, screenHeight / 10 ))
    scanXdataLabel.textColor = UIColor.redColor()
    scanXdataLabel.text = "scan:x"
    
    buttonMainCenter = CGPointMake(screenWidth/2, screenWidth * 0.4+screenHeight / 10 * 2.5)
    buttonMainSize = CGPointMake(screenWidth * 0.8, screenWidth * 0.8)
    
    let countRect:CGRect=CGRectMake(screenWidth, screenHeight / 10 * 2.5, buttonMainSize.x, buttonMainSize.y)
    
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
    viewerOpeView  = UIView(frame: countRect)
    viewerOpeView.center.x=buttonMainCenter.x
    viewerOpeView.layer.masksToBounds = true
    viewerOpeView.layer.cornerRadius = screenWidth * 0.4
    viewerOpeView.backgroundColor = UIColor.yellowColor()
    
    
    
    intervalLabel = UILabel(frame: CGRectMake(buttonMainSize.x/2, buttonMainSize.y/2, screenWidth * 2 / 10, screenHeight / 20 ))
    intervalLabel.textColor = UIColor.redColor()
    intervalLabel.text = "time"
    
    //設定ボタン
    viewerInfoButton = UIButton(frame: CGRectMake(buttonMainSize.x/2, buttonMainSize.y/2, screenWidth * 2 / 10,screenWidth * 2 / 10  ))
    viewerInfoButton.layer.cornerRadius = viewerInfoButton.frame.width / 2
    viewerInfoButton.center =  CGPointMake(buttonMainSize.x * 0.75,buttonMainSize.y * 0.25)
    viewerInfoButton.backgroundColor = UIColor.whiteColor()
    viewerInfoButton.setTitle("Info", forState: UIControlState.Normal)
    viewerOpeView.addSubview(viewerInfoButton)
    
    //ジェスチャーの追加
    viewerOpeView.addGestureRecognizer(myPan)
    viewerOpeView.addGestureRecognizer(swipeLeft)
    viewerOpeView.addGestureRecognizer(swipeRight)
    viewerOpeView.addGestureRecognizer(stampTap)
    
    
    addImageButton = UIButton(type: UIButtonType.ContactAdd)
    addImageButton.center = CGPointMake(screenWidth / 2, screenHeight - step)
    // イベントを追加する.
    addImageButton.addTarget(self, action: "showAlbum:",forControlEvents: UIControlEvents.TouchUpInside)
    
    
  
    viewerOpeView.addSubview(intervalLabel)
    //viewerOpeView.addSubview(viewerOpeView)
  
    
    
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
    self.view.addSubview(scanXdataLabel)
    //self.view.addSubview(intervalLabel)
    self.view.addSubview(count3Label)
    self.view.addSubview(count2Label)
    self.view.addSubview(count1Label)
    
    //UIButtonを追加
    self.view.addSubview(addImageButton)
    self.view.addSubview(viewerOpeView)
    
    
    
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
  @IBAction func CameraStart(sender: AnyObject) {
    
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
    let imgFrame =  CGRectMake(lightBarWidth * 9.5, 0, lightBarWidth *  imgWidth / imgHeight * screenHeight, screenHeight)
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
      
      cameraView.image = pickedImage
      opeImage = UIImageView(frame:viewerOpeView.frame)
      opeImage.image = pickedImage
      opeImage.frame.origin=CGPointMake(0,0)
      print(viewerOpeView.subviews.count)
      
      viewerOpeView.subviews
      viewerOpeView.addSubview(opeImage)
      //viewerOpeView.sendSubviewToBack(opeImage)
      viewerOpeView.bringSubviewToFront(viewerInfoButton)
      viewerOpeView.bringSubviewToFront(intervalLabel)
      
      // 画像の幅・高さの取得
      Iwidth = pickedImage.size.width
      Iheight = pickedImage.size.height
      
      intervaltime = intervalTimeSet(cameraView, speed:1.5)
      print("intervaltime:",intervaltime)
      
      intervalLabel.text = String(format: "%.1f秒",intervaltime)
   
      cameraView.frame = scanSizeSet(cameraView)
      

      print("frame:x=",cameraView.frame.origin.x,"frame:y=",cameraView.frame.origin.y,"frame:heigth=",cameraView.frame.size.height,"frame:width=",cameraView.frame.size.width)
      
      self.view.bringSubviewToFront(viewerOpeView)
      self.view.bringSubviewToFront(scanXdataLabel)
      self.view.bringSubviewToFront(intervalLabel)
      
    }
    
    //閉じる処理
    imagePicker.dismissViewControllerAnimated(true, completion: nil)
    //Label.text = "Tap the [Save] to save a picture"
    
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


  func showAlbum(sender: UIButton){
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
  
  func prePlay(style:Int8,mode:Int8,speed:Int8){
    phaize = 1
    
    
    // アニメーション処理
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.7 * Double(NSEC_PER_SEC)))
    print("prePlay")
    
    
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
  
  
  func playimage(style:Int8,mode:Int8,speed:Int8){
  
  phaize = 2
    // アニメーション処理
  print("animation")
  cameraView.frame = scanSizeSet(cameraView)
  let rightImagePoint :CGFloat! = self.step  * 9.5 - self.cameraView.frame.width - self.lightBarWidth
  let leftImagePoint : CGFloat! = self.step  * 10 + self.lightBarWidth
  
  
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
  
  
  func scanPlay(startX:CGFloat,endX:CGFloat,mode:Int8,speed:Int8){
    cameraView.contentMode = .ScaleToFill
    cameraView.frame.origin.x = startX
    scanPlayAtoB = [startX,endX]
    
      UIView.animateWithDuration(0.1,
                               animations: {() -> Void in
                                //扉オープん
                                self.frameViewR.frame.origin.x = self.step * 10 + self.lightBarWidth
                                self.frameViewL.frame.origin.x = -1 * self.lightBarWidth
      },completion: { finished in
        if(mode == 0){
          //single mode
        UIView.animateWithDuration(self.intervaltime,
          animations: {() -> Void in
            self.cameraView.frame.origin.x = endX
          },completion: { finished in
                self.closingPlayImage()
        })
        }else if(mode == 1 ){
          self.view.addGestureRecognizer(self.stopTap)
          //loop mode
          UIView.animateWithDuration(self.intervaltime, delay: 0.0,
            options: UIViewAnimationOptions.Repeat, animations: { () -> Void in
              self.cameraView.frame.origin.x = endX
            }, completion: nil)
        }else{
          //tapping restart mode
          print("tapping restart mode")
          self.view.addGestureRecognizer(self.replayTap)
          
        
        }//ifelse
    })
    
  }
  
  func replayTapped(gestureRecognizer: UITapGestureRecognizer){
    cameraView.layer.removeAllAnimations()
    cameraView.frame.origin.x = scanPlayAtoB[0]
        UIView.animateWithDuration(self.intervaltime,
          animations: {() -> Void in
            self.cameraView.frame.origin.x = self.scanPlayAtoB[1]
          },completion: { finished in
        })
}
  
  
  func closingPlayImage() {
    UIView.animateWithDuration(0.3, animations: { () -> Void in
      //一度、真っ黒に扉が閉じる
      self.frameViewR.frame.origin.x = self.step * 10
      self.frameViewL.frame.origin.x = 0
      },completion: { finished in
        self.phaize = 3
        self.view.addGestureRecognizer(self.resetTap)
        self.cameraView.frame.origin.x = self.step * 10 - self.lightBarWidth
    })

    
}
  
  func stopPlayTapped(gestureRecognizer: UITapGestureRecognizer){
    print("stopPlayTapped")
    cameraView.layer.removeAllAnimations()
    self.closingPlayImage()
  }
  
  func stampPlay(mode:Int8,speed:Int8){
    
    //扉を消して画像を表示
    frameViewR.alpha=0
    frameViewL.alpha=0
    //イメージをフルスクリーン
    cameraView.contentMode = .ScaleAspectFit
    cameraView.frame = CGRectMake(0,0,screenWidth,screenHeight)
     print("frame:x=",cameraView.frame.origin.x,"frame:y=",cameraView.frame.origin.y,"frame:heigth=",cameraView.frame.size.height,"frame:width=",cameraView.frame.size.width)
    //画像表示
    //self.cameraView.alpha = 1
    let time:Double = stampSpeedTable[Int(speed)] * Double(NSEC_PER_SEC)
    print("speed:",stampSpeedTable[Int(speed)])
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(time)), dispatch_get_main_queue()) {
    //self.cameraView.alpha = 0
    self.view.addGestureRecognizer(self.resetTap)
      self.frameViewR.alpha=1
      self.frameViewL.alpha=1
      self.cameraView.contentMode = .ScaleToFill
      
      print("frame:x=",self.cameraView.frame.origin.x,"frame:y=",self.cameraView.frame.origin.y,"frame:heigth=",self.cameraView.frame.size.height,"frame:width=",self.cameraView.frame.size.width)
    }
  }
  
  /*
   ピンチイベントの実装.
   */
  internal func pinchGesture(sender: UIPinchGestureRecognizer){
    let firstPoint = sender.scale
    let secondPoint = sender.velocity
  print("pichi:\\t\(firstPoint)\t\(secondPoint)")
      lightBarWidth = lightBarWidth + secondPoint / 2   * step
    if(lightBarWidth < 1){
      lightBarWidth = 1
    }else if(lightBarWidth > (screenWidth / 2 - 1)){
    lightBarWidth = (screenWidth / 2 - 1)
    }
    frameViewR.frame.origin.x = step * 10 + lightBarWidth
    frameViewL.frame.origin.x = -1 * lightBarWidth
    cameraView.frame.origin.x = step * 10 - lightBarWidth
  }
  
func resetImage(gestureRecognizer: UITapGestureRecognizer){
    UIView.animateWithDuration(0.3, animations: { () -> Void in
      self.viewerOpeView.alpha = 1.0
      self.viewerOpeView.center.x = self.screenWidth * 0.5
      //扉オープん
      self.frameViewR.frame.origin.x = self.step * 10 + self.lightBarWidth
      self.frameViewL.frame.origin.x = -1 * self.lightBarWidth
      },completion: { finished in
        self.phaize = 0
        //self.view.bringSubviewToFront(self.scanXdataLabel)
        //self.view.bringSubviewToFront(self.intervalLabel)
        self.view.removeGestureRecognizer(self.resetTap)
        
    })
  
  
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
            print("start  direction left, mode =" ,modeNum)
          phaize = 1
          
          self.prePlay(0, mode: modeNum, speed:1)
        }else if(viewerOpeView.center.x > screenWidth * 0.8){
            print("start direction Right, mode =" ,modeNum)
          phaize = 1
          self.prePlay(1,mode: modeNum, speed:1)
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
   swipe.
   */
internal func didSwipe(sender: UISwipeGestureRecognizer){
    let point = sender.locationInView(self.view)
    print(point)
    
    if sender.direction == .Right {
      print("Right")
      phaize = 1
      self.prePlay(1,mode:0,speed:1)
    }
    else if sender.direction == .Left {
      print("Left")
      phaize = 1
      prePlay(0, mode: 1,speed:1)

    }
  
}
  
  /*
   stamp tap
 */
  internal func prePreStampPlay(sender:UITapGestureRecognizer){
    prePlay(2, mode: 0, speed:1)
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