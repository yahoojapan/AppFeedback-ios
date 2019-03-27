//
//  ReportViewController.swift
//  AppFeedback
//
//  Created by tahori on 2019/03/27.
//  Copyright © 2019 Yahoo! JAPAN Corporation. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit

protocol ReportViewControllerDelegate {
    func reportViewControllerClosed()
}

class ReportViewController : UIViewController {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage!
    var videoPath: NSURL!
    var drawnImage: UIImage!
    var sourceClassName: String
    var config: Config
    var delegate: ReportViewControllerDelegate
    
    typealias AlertComletionBlock = (buttonIndex: Int) ->  Void
    
    enum AlertButtonIndex : Int {
        UIAlertCancelButtonIndex = 0,
        UIAlertDestructiveButtonIndex = 1,
        UIAlertFirstOtherButtonIndex = 2
    }
    

    // MARK: - Private properties
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var reporterName: UITextField!
    @IBOutlet weak var freeCommentField: UIPlaceHolderTextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var keyboardAccessoryView: UIView!
    @IBOutlet weak var keyboardAccessoryBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var freeCommentHeightConstraint: NSLayoutConstraint!
    var keyboardHeight: CGFloat = 0
    @IBOutlet weak var activityView: UIVisualEffectView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var DrawingButton: UIButton!
    @IBOutlet weak var RecordingButton: UIButton!
    @IBOutlet weak var feedbackCategoryLabel: UILabel!
    @IBOutlet weak var sendingLabel: UILabel!
    @IBOutlet weak var feedbackCategoryButton: ExpansionButton
    var notSelectedCategoryTitle: String

    var focusOnReporterName: Bool
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.p_setupView();
        self.feedbackCategoryButton.setPerceivableArea(leftArea: 0.0, rightArea: 0.0)
        self.notSelectedCategoryTitle = AppFeedbackLocalizedString.string(for: "select")
    
        self.keyboardAccessoryView.hidden = true
    
        self.setupNavBarAttributes(self.navigationController)
    
        // dismiss時にcallbackが呼ばれない問題の対応
        // http://stackoverflow.com/a/30069208/7642392
        self.modalPresentationStyle = UIModalPresentationFullScreen
        self.freeCommentField.minHeight = self.freeCommentHeightConstraint.constant
        self.freeCommentField.heightConstraint = self.freeCommentHeightConstraint
    
        self.activityView.isHidden = true
        self.activityView.superview?.bringSubviewToFront(self.activityView)
    
        self.sendingLabel.text = AppFeedbackLocalizedString.string(for: "sendingLabelText")
        self.sendingLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // キーボード表示・非表示時のイベント登録
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: .keyboardWillChangeFrameNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: .keyboardWillHideNotification , object: nil)

    
        self.p_setupImageView()
        self.p_setupView()
        self.hiddenButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
        // キーボード表示・非表示時のイベント削除
        NotificationCenter.default.removeObserver(self, name: .keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .keyboardWillHideNotification, object: nil)
    }
    
    func p_close() {
        self.p_close {}
    }
    
    func p_close(completion () -> Void) {
        self.closeKeyboard()
        self.drawnImage = nil

        self.dismiss(animated: true) {
            if self.delegate {
                self.delegate.reportViewControllerClosed()
            }
        }
        completion();
    }

    func p_setupView() {
        self.container.clipsToBounds  = true
        self.freeCommentField.clipsToBounds = true
    
        self.freeCommentField.layer.cornerRadius = 5.0
    
        self.freeCommentField.placeholder = AppFeedbackLocalizedString.string(for : "comment")
        self.freeCommentField.placeholderColor = UIColor.lightGray
    
        let userDefaults = UserDefaults.standard
        let userName = userDefaults.string(forKey: "report.user_name")
        if userName {
            self.reporterName.text = userName
        }
    
        self.reporterName.delegate = self
        self.freeCommentField.delegate = self
        self.titleTextField.delegate = self
    }
    
    func p_setupImageView() {
        if self.videoPath {
            if let image = self.generateVideoPreviewImage(self.videoPath) {
                self.imageView.image = image
            }
            self.playButton.isHidden = false
        } else if self.drawnImage {
            self.playButton.isHidden = true
            self.imageView.image = self.drawnImage
        } else if self.image {
            self.playButton.isHidden = true
            self.imageView.image = self.image
        }
    }
    
    //動画保存時は「画像編集開始」ボタンを非表示・描画画像保存時は「キャプチャ開始」ボタンを非表示
    func hiddenButton() {
        if self.videoPath {
            self.DrawingButton.isEnabled = false
            self.DrawingButton.alpha = 0.4
    
            self.RecordingButton.isEnabled = true
            self.RecordingButton.alpha = 1
    
        } else if self.drawnImage {
            self.DrawingButton.isEnabled = true
            self.DrawingButton.alpha = 1
    
            self.RecordingButton.isEnabled = false
            self.RecordingButton.alpha = 0.4
        } else {
            self.DrawingButton.isEnabled = true
            self.DrawingButton.alpha = 1
    
            self.RecordingButton.isEnabled = true
            self.RecordingButton.alpha = 1
        }
    }
    
    func closeKeyboard() {
        self.view.endEditing(true)
    }
    
    func p_createAlertWithTitle(title: String, message: String, cancelButtonTitle: String destructiveButtonTitle String, otherButtonTitle: String tapBlock: AlertComletionBlock) {
    
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
        if cancelButtonTitle {
            ac.addAction(UIAlertAction(title: cancelButtonTitle, style: .default) { action in
                if tapBlock {
                    tapBlock(.UIAlertCancelButtonIndex)
                }
            })
        }

        if destructiveButtonTitle {
            ac.addAction(UIAlertAction(title: destructiveButtonTitle, style: .default) {
                if tapBlock {
                    tapBlock(.UIAlertDestructiveButtonIndex)
                }
            })
        }

        if otherButtonTitle {
            ac.addAction(UIAlertAction(title: otherButtonTitle, style: .default) {
                if tapBlock {
                    tapBlock(.UIAlertFirstOtherButtonIndex)
                }
            })
        }
    
        [self presentViewController:ac animated:YES completion:nil];
    }
    
    func p_takeScreenShot(image: UIImage) -> Data {

        let imageData =UIImagePNGRepresentation( image )
    
        return imageData;
    }
    
    func p_sendMessage() {
        if self.videoPath {
    
            let videoSize = self.videoPath(fileSize)
            let indicatorThresholdSize = 1 * 1024 * 1024

            if videoSize > indicatorThresholdSize {
                self.enableActivityIndicator(true)
            }

            self.p_sendMessage(image: nil, videoPath: self.videoPath)
        } else {
            self.p_sendMessage(image: self.imageView.image videoPath: nil)
        }
    }
    
    func p_sendMessage(image: UIImage, videoPath: NSURL) {
        //ScreenShot取得
        let imageData = self.p_takeScreenShot(image)
    
        let data = SendData(imageData: imageData, videoPath: videoPath, title: self.titleTextField, category: self.feedbackCategoryLabel, comment: self.freeCommentField.text, username: self.reporterName.text, appTitle: Bundle.main.infoDictionary?["CFBundleName"], appVersion: DeviceUtil.appVersion, appBuildVersion: DeviceUtil.appBuildVersion, systemVersion: DeviceUtil.osVersion, modelCode: DeviceUtil.modelCode, modelName: DeviceUtil.modelName)
    
        self.sendingLabel.isHidden = false
    
        let slackAPI = SlackAPI(token: self.config.slackToken, channel: self.config.slackChannel, apiUrl: self.config.slackApiUrl, branchName: self.config.branchName) [[SlackAPI alloc] initWithToken:self.config.slackToken

            slackAPI.post(data: data) { (data, response, error) in

            self.enableActivityIndicator(false)
            self.sendingLabel.isHidden = true
    
            if error {
            if error.code == kCFURLErrorUserCancelledAuthentication {//401(Authentication failure)
            self.p_createAlert(title: AppFeedbackLocalizedString.string(for: "slackPostErrorTitle"),
            message: AppFeedbackLocalizedString.string(for: "slackPostInvalidMessage")
    cancelButtonTitle:nil
    destructiveButtonTitle:nil
    otherButtonTitle:@"OK"
    tapBlock:nil];
    } else {
    [self
    p_createAlertWithTitle:[AppFeedbackLocalizedString stringFor:@"slackPostErrorTitle"]
    message:[AppFeedbackLocalizedString stringFor:@"slackPostClientErrorMessage"]
    cancelButtonTitle:nil
    destructiveButtonTitle:nil
    otherButtonTitle:@"OK"
    tapBlock:nil];
    }
    return;
    }
    
    NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
    
    switch (statusCode) {
    case 200: {
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data
    options:NSJSONReadingAllowFragments
    error:nil];
    if ([responseDictionary[@"ok"] boolValue] == NO) {
    NSString *errorMessage = responseDictionary[@"error"];
    [self p_createAlertWithTitle:@"Slack Error" message: errorMessage cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitle:@"OK" tapBlock:nil];
    return;
    }
    
    self.titleTextField.text = @"";
    self.freeCommentField.text = @"";
    [self doneSelectedFeedbackCategory:self.notSelectedCategoryTitle :false]; // 未選択の状態に戻す
    
    [self
    p_createAlertWithTitle:[AppFeedbackLocalizedString stringFor:@"slackPostSuccessTitle"]
    message:[AppFeedbackLocalizedString stringFor:@"slackPostSuccessMessage"]
    cancelButtonTitle:nil
    destructiveButtonTitle:nil
    otherButtonTitle:@"OK"
    tapBlock:^(NSInteger buttonIndex){
    [self p_close];
    }];
    break;
    }
    
    case 403:// Forbidden
    [self
    p_createAlertWithTitle:[AppFeedbackLocalizedString stringFor:@"slackPostErrorTitle"]
    message:[AppFeedbackLocalizedString stringFor:@"slackPostAuthorizationErrorMessage"]
    cancelButtonTitle:nil
    destructiveButtonTitle:nil
    otherButtonTitle:@"OK"
    tapBlock:nil];
    break;
    
    case 500://Internal Error
    [self
    p_createAlertWithTitle:[AppFeedbackLocalizedString stringFor:@"slackPostErrorTitle"]
    message:[AppFeedbackLocalizedString stringFor:@"slackPostUnknownErrorMessage"]
    cancelButtonTitle:nil
    destructiveButtonTitle:nil
    otherButtonTitle:@"OK"
    tapBlock:nil];
    break;
    
    default:
    [self
    p_createAlertWithTitle:[AppFeedbackLocalizedString stringFor:@"slackPostErrorTitle"]
    message:[NSString stringWithFormat:[AppFeedbackLocalizedString stringFor:@"slackPostUnknownErrorStatucCodeMessage"], (long)statusCode]
    cancelButtonTitle:nil
    destructiveButtonTitle:nil
    otherButtonTitle:@"OK"
    tapBlock:nil];
    break;
    }
    }];
    }
    
    - (void)enableActivityIndicator:(BOOL)enable {
    self.activityView.hidden = !enable;
    self.sendButton.enabled = !enable;
    }
    
    - (NSMutableData*)setTextData:(NSMutableData *)feedbackData textDictionary:(NSDictionary *)textDictionary boundary:(NSString *)boundary {
    for (id key in [textDictionary keyEnumerator]) {
    NSString* value = [textDictionary valueForKey:key];
    [feedbackData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [feedbackData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data;"] dataUsingEncoding:NSUTF8StringEncoding]];
    [feedbackData appendData:[[NSString stringWithFormat:@"name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
    [feedbackData appendData:[[NSString stringWithFormat:@"%@\r\n", value] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return feedbackData;
    }
    
    - (NSMutableData*)setImageData:(NSMutableData *)feedbackData imageData:(NSData *)imageData videoPath:(NSURL *)videoPath boundary:(NSString *)boundary {
    [feedbackData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [feedbackData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data;"] dataUsingEncoding:NSUTF8StringEncoding]];
    [feedbackData appendData:[[NSString stringWithFormat:@"name=\"%@\";", @"file"] dataUsingEncoding:NSUTF8StringEncoding]];
    [feedbackData appendData:[[NSString stringWithFormat:@"filename=\"%@\"\r\n", @"file"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (videoPath) {
    NSData *videoData = [NSData dataWithContentsOfURL:videoPath];
    [feedbackData appendData:[[NSString stringWithFormat:@"Content-Type: video/mp4\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [feedbackData appendData:videoData];
    } else {
    [feedbackData appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [feedbackData appendData:imageData];
    }
    
    [feedbackData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // last
    [feedbackData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return feedbackData;
    }
    
    - (void)scrollToTextViewCaret:(UIView<UITextInput> *)textView {
    CGRect caretRect = [textView caretRectForPosition:textView.selectedTextRange.end];
    
    // カーソルが最後にあると INFINITY になる……？
    if (caretRect.origin.y == INFINITY) {
    caretRect.origin.y = textView.frame.size.height;
    caretRect.origin.x = 0;
    caretRect.size.height = 10;
    caretRect.size.width = 1;
    }
    
    caretRect.origin = [textView convertPoint:caretRect.origin toView:self.scrollView];
    
    CGFloat keyboardTopBorder = self.scrollView.frame.size.height - self.keyboardHeight;
    
    if (caretRect.origin.y + caretRect.size.height > keyboardTopBorder) {
    CGRect rect = caretRect;
    [self.scrollView scrollRectToVisible:rect animated:YES];
    }
    }
    
    #pragma mark - Video関連
    
    -(UIImage *)generateVideoPreviewImage:(NSURL *)url
    {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    
    CMTime thumbTime = CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);
    
    NSError *error = nil;
    CGImageRef imageRef = [generator copyCGImageAtTime:thumbTime actualTime:NULL error:&error];
    UIImage *image = [UIImage imageWithCGImage:imageRef
    scale:UIScreen.mainScreen.scale
    orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    
    return image;
    
    }
    
    #pragma mark - IBActions
    
    - (IBAction)didTapOK:(id)sender {
    if (self.reporterName.text.length > 0) {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:self.reporterName.text forKey:@"report.user_name"];
    [userDefaults synchronize];
    }
    
    if (self.titleTextField.text.length == 0) {
    [self
    p_createAlertWithTitle:nil
    message:[AppFeedbackLocalizedString stringFor:@"confirmReportSettingInputTitleMessage"]
    cancelButtonTitle:nil
    destructiveButtonTitle:nil
    otherButtonTitle:@"OK"
    tapBlock:^(NSInteger buttonIndex){
    [self.titleTextField becomeFirstResponder];
    }];
    return;
    }
    
    if (self.reporterName.text.length == 0) {
    [self
    p_createAlertWithTitle:[AppFeedbackLocalizedString stringFor:@"confirmReportSettingMessage"]
    message:[AppFeedbackLocalizedString stringFor:@"confirmReportSettingSlackIdCausionMessage"]
    cancelButtonTitle:nil
    destructiveButtonTitle:nil
    otherButtonTitle:@"OK"
    tapBlock:^(NSInteger buttonIndex){
    [self.reporterName becomeFirstResponder];
    }];
    return;
    }
    
    NSString *confirmMsg = [AppFeedbackLocalizedString stringFor:@"confirmReportSettingMessage"];
    
    if ([self.feedbackCategoryButton.currentTitle  isEqual: self.notSelectedCategoryTitle]) {
    confirmMsg = [NSString stringWithFormat:@"%@\n\n%@", confirmMsg, [AppFeedbackLocalizedString stringFor:@"confirmReportSettingNotSelectedCategoryMessage"]];
    }
    
    
    [self p_createAlertWithTitle:[AppFeedbackLocalizedString stringFor:@"confirm"] message:confirmMsg cancelButtonTitle:[AppFeedbackLocalizedString stringFor:@"cancel"] destructiveButtonTitle:nil otherButtonTitle:[AppFeedbackLocalizedString stringFor:@"send"] tapBlock:^(NSInteger buttonIndex){
    if (buttonIndex == UIAlertFirstOtherButtonIndex) {
    [self p_sendMessage];
    [self closeKeyboard];
    }
    }];
    }
    
    - (IBAction)didTapCancel:(id)sender {
    [self p_close];
    }
    
    
    - (IBAction)videoButtonTapped:(id)sender {
    NSString *message = [NSString stringWithFormat:[AppFeedbackLocalizedString stringFor:@"videoButtonTappedAlertMessage"], (int)floor(VIDEO_LIMIT_SECS)];
    [self p_createAlertWithTitle:[AppFeedbackLocalizedString stringFor:@"videoButtonTappedAlertTitle"] message:message cancelButtonTitle:[AppFeedbackLocalizedString stringFor:@"cancel"] destructiveButtonTitle:nil otherButtonTitle:[AppFeedbackLocalizedString stringFor:@"videoButtonTappedAlertStartButtonTitle"] tapBlock:^(NSInteger buttonIndex){
    if (buttonIndex == UIAlertFirstOtherButtonIndex) {
    [self p_close:^{
    [AppFeedback startRecording];
    }];
    }
    }];
    }
    
    - (IBAction)playButtonTapped:(id)sender {
    if (!self.videoPath) return;
    
    AVPlayer *avPlayer = [AVPlayer playerWithURL:self.videoPath];
    AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
    controller.player = avPlayer;
    [self presentViewController:controller animated:YES completion:^{
    [avPlayer play];
    }];
    }
    
    - (IBAction)closeKeyboardButtonTapped:(id)sender {
    [self closeKeyboard];
    }
    
    #pragma mark - Textfield Delegate
    - (BOOL)textFieldShouldReturn:(UITextField *)textField
    {
    if (textField == self.reporterName) {
    [textField resignFirstResponder];
    return YES;
    }
    
    if (textField == self.titleTextField) {
    [textField resignFirstResponder];
    [self.freeCommentField becomeFirstResponder];
    return NO;
    }
    
    return YES;
    }
    
    - (void)keyboardWillChange:(NSNotification*)notification
    {[self.view layoutIfNeeded];
    // キーボードの top を取得する
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect origKeyboardRect = keyboardRect;
    CGFloat margin = 4.0;
    
    
    if(focusOnReporterName){
    self.keyboardAccessoryView.hidden = YES;
    }else{
    self.keyboardAccessoryView.hidden = NO;
    }
    
    keyboardRect.size.height += self.keyboardAccessoryView.frame.size.height + margin;
    keyboardRect.origin.y -= self.keyboardAccessoryView.frame.size.height - margin;
    self.keyboardHeight = keyboardRect.size.height;
    
    // キーボードアニメーションと同じ間隔、速度になるように設定
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.keyboardAccessoryBottomConstraint.constant = origKeyboardRect.size.height;
    [self.view layoutIfNeeded];
    
    // 表示アニメーション開始
    [UIView commitAnimations];
    
    // scrollView の contentInset と scrollIndicatorInsets の bottom に追加
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardRect.size.height, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    if (self.freeCommentField.isFirstResponder) {
    [self scrollToTextViewCaret:self.freeCommentField];
    }
    }
    
    - (void)keyboardWillHidden:(NSNotification*)notification
    {
    // キーボードアニメーションと同じ間隔、速度になるように設定
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.keyboardHeight = 0;
    
    // インセットを 0 にする
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    self.keyboardAccessoryView.hidden = YES;
    self.keyboardAccessoryBottomConstraint.constant = 0;
    [self.view layoutIfNeeded];
    
    // 非表示アニメーション開始
    [UIView commitAnimations];
    }
    
    // reporterNameにフォーカスが当たった
    - (void)textFieldDidBeginEditing:(UITextField *)textField
    {
    focusOnReporterName = textField == self.reporterName;
    }
    
    // reporterNameからフォーカスが外れた
    - (void)textFieldDidEndEditing:(UITextField *)textField{/*特にやることなし*/}
    
    // freeCommentFieldにフォーカスが当たった
    - (BOOL)textViewShouldBeginEditing:(UITextView *)textView
    {
    focusOnReporterName = NO;
    [self scrollToTextViewCaret:textView];
    return YES;
    }
    
    - (void)textViewDidChange:(UITextView *)textView {
    [textView setNeedsLayout];
    [textView layoutIfNeeded];
    [self scrollToTextViewCaret:textView];
    }
    
    // freeCommentFieldからフォーカスが外れた
    - (BOOL)textViewShouldEndEditing:(UITextView *)textView{/*特にやることなし*/ return YES;}
    
    // 描画画面に遷移する際スクリーンショットを渡す
    - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"goToDrawing"]) {
    UINavigationController *navController = segue.destinationViewController;
    [self setupNavBarAttributes:navController];
    DrawViewController *drawViewController = (DrawViewController *)navController.topViewController;
    drawViewController.originImage = [[UIImage alloc] initWithCGImage:self.image.CGImage];
    if (sender != nil) {
    drawViewController.editingImage = [[UIImage alloc] initWithCGImage:((UIImage*)sender).CGImage];
    }
    }
    }
    
    // 保存ボタンを押して描画画面から戻った時の処理
    - (IBAction)unwindToDrawViewController:(UIStoryboardSegue *)segue
    {
    DrawViewController *drawViewController = [segue sourceViewController];
    if (drawViewController.editingImage) {
    drawViewController.editingImage = nil;
    self.drawnImage = [drawViewController.imageView image];
    } else {
    self.drawnImage = nil;
    self.imageView.image = drawViewController.originImage;
    }
    self.videoPath = nil;
    }
    
    // 画像編集ボタンを押した時の処理
    - (IBAction)editButton:(id)sender {
    // 既に保存されている画像がある場合、途中から編集する
    if (self.drawnImage) {
    [self performSegueWithIdentifier:@"goToDrawing" sender:self.imageView.image];
    } else {
    [self performSegueWithIdentifier:@"goToDrawing" sender:nil];
    }
    }
    
    - (void)setupNavBarAttributes:(UINavigationController *)navController {
    // storyboardからだと反映されないので、コードから直接色指定する。
    navController.navigationBar.barTintColor = [UIColor colorWithRed:0.278 green:0.729 blue:0.678 alpha:1.0];
    navController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: UIColor.whiteColor };
    }
    
    // フィードバックカテゴリ選択ボタンを押下した時の処理
    - (IBAction)selectFeedbackCategory:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[AppFeedbackLocalizedString stringFor:@"categoryMessage"]
    message:nil
    preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[AppFeedbackLocalizedString stringFor:@"cancel"]
    style:UIAlertActionStyleCancel
    handler:^(UIAlertAction * action) {}];
    
    [alertController addAction:cancelAction];
    
    [self.config.categories enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    UIAlertAction * selectAction = [UIAlertAction actionWithTitle:self.config.categories[idx]
    style:UIAlertActionStyleDefault
    handler:^(UIAlertAction * action) {
    [self doneSelectedFeedbackCategory:self.config.categories[idx] :true];
    }];
    
    [selectAction setValue:[UIColor darkGrayColor] forKey:@"titleTextColor"];
    [alertController addAction:selectAction];
    }];
    
    // iPad で Action Sheet を使う場合、popoverPresentationController を設定しないとクラッシュする。
    alertController.popoverPresentationController.sourceView = self.feedbackCategoryLabel;
    alertController.popoverPresentationController.sourceRect = self.feedbackCategoryButton.frame;
    
    [self presentViewController:alertController animated:YES completion:nil];
    }
    
    // 選択したフィードバックカテゴリを画面に反映する。
    - (void)doneSelectedFeedbackCategory:(NSString *)selectedCategory :(BOOL)isSelected {
    [self.feedbackCategoryButton setTitle:selectedCategory forState:UIControlStateNormal];
    self.feedbackCategoryButton.selected = isSelected;
    }
    
    @end

}

