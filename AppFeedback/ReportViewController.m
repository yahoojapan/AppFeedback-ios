//
//  ReportViewController.m
//  ReportViewController
//
//  Copyright (c) 2018 Yahoo Japan Corporation.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "ReportViewController.h"
#import "DrawViewController.h"
#import "DeviceUtil.h"
#import "UIView+TTCategory.h"
#import "UIPlaceHolderTextView.h"
#import "Config.h"
#import "AppFeedbackInternal.h"
#import "NSURL+Sizse.h"
#import "Color.h"
#import "ExpansionButton.h"
#import "SlackAPI.h"

@import AVFoundation;
@import AVKit;

typedef void (^AlertComletionBlock) (NSInteger buttonIndex);

typedef enum AlertButtonIndex : NSUInteger {
    UIAlertCancelButtonIndex = 0,
    UIAlertDestructiveButtonIndex = 1,
    UIAlertFirstOtherButtonIndex = 2
}AlertButtonIndex;

@interface ReportViewController ()
<UITextFieldDelegate,
UITextViewDelegate
>

#pragma mark - Private properties

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *reporterName;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *freeCommentField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIView *keyboardAccessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardAccessoryBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *freeCommentHeightConstraint;
@property (nonatomic) CGFloat keyboardHeight;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *activityView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *DrawingButton;
@property (weak, nonatomic) IBOutlet UIButton *RecordingButton;
@property (weak, nonatomic) IBOutlet UILabel *feedbackCategoryLabel;

@property (weak, nonatomic) IBOutlet ExpansionButton *feedbackCategoryButton;
@property (nonatomic) NSString* notSelectedCategoryTitle;

@end

@implementation ReportViewController {
    BOOL focusOnReporterName;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //self.container.hidden = YES;
    [self p_setupView];

    [self.feedbackCategoryButton setPerceivableAreaWithLeftArea:0.0f rightArea:30.0f];
    self.notSelectedCategoryTitle = AppFeedbackLocalizedString(@"select", @"");

    self.keyboardAccessoryView.hidden = YES;
    
    [self setupNavBarAttributes:self.navigationController];

    // dismiss時にcallbackが呼ばれない問題の対応
    // http://stackoverflow.com/a/30069208/7642392
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    self.freeCommentField.minHeight = self.freeCommentHeightConstraint.constant;
    self.freeCommentField.heightConstraint = self.freeCommentHeightConstraint;
    
    self.activityView.hidden = YES;
    [self.activityView.superview bringSubviewToFront:self.activityView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // キーボード表示・非表示時のイベント登録

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChange:)
                                                 name:UIKeyboardWillChangeFrameNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

    [self p_setupImageView];
    [self p_setupView];
    [self hiddenButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    // キーボード表示・非表示時のイベント削除
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)p_close {
    [self p_close:^{}];
}

- (void)p_close:(void (^)(void))completion {
    [self closeKeyboard];
    self.drawnImage = nil;

    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate) {
            [self.delegate reportViewControllerClosed];
        }
        completion();
    }];
}

- (void)p_setupView {
    self.container.clipsToBounds  = YES;
    self.freeCommentField.clipsToBounds = YES;
    
    self.freeCommentField.layer.cornerRadius = 5.0f;
    
    self.freeCommentField.placeholder = AppFeedbackLocalizedString(@"comment", @"");
    self.freeCommentField.placeholderColor = [UIColor lightGrayColor];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaults stringForKey:@"report.user_name"];
    if (userName) {
        self.reporterName.text = userName;
    }
    
    self.reporterName.delegate = self;
    self.freeCommentField.delegate = self;
    self.titleTextField.delegate = self;
}

- (void)p_setupImageView {
    if (self.videoPath) {
        UIImage *image = [self generateVideoPreviewImage:self.videoPath];
        if (image) {
            self.imageView.image = image;
        }
        self.playButton.hidden = NO;
    } else if (self.drawnImage) {
        self.playButton.hidden = YES;
        self.imageView.image = self.drawnImage;
    } else if (self.image) {
        self.playButton.hidden = YES;
        self.imageView.image = self.image;
    }
}

//動画保存時は「画像編集開始」ボタンを非表示・描画画像保存時は「キャプチャ開始」ボタンを非表示
- (void)hiddenButton{
    if(self.videoPath){
        self.DrawingButton.enabled = NO;
        self.DrawingButton.alpha = 0.4f;
        
        self.RecordingButton.enabled = YES;
        self.RecordingButton.alpha = 1;
        
    }else if(self.drawnImage){
        self.DrawingButton.enabled = YES;
        self.DrawingButton.alpha = 1;
        
        self.RecordingButton.enabled = NO;
        self.RecordingButton.alpha = 0.4f;
        
    }else{
       self.DrawingButton.enabled = YES;
       self.DrawingButton.alpha = 1;
        
       self.RecordingButton.enabled = YES;
       self.RecordingButton.alpha = 1;
    }
}

-(void)closeKeyboard
{
    [self.view endEditing:YES];
}

- (void)p_createAlertWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelTitle destructiveButtonTitle:(NSString*)destructiveTitle otherButtonTitle:(NSString*)otherTitle tapBlock:(AlertComletionBlock)tapBlock {
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancelTitle) {
        [ac addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
            if (tapBlock) {
                tapBlock(UIAlertCancelButtonIndex);
            }
        }]];
    }
    if (destructiveTitle) {
        [ac addAction:[UIAlertAction actionWithTitle:destructiveTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
            if (tapBlock) {
                tapBlock(UIAlertDestructiveButtonIndex);
            }
        }]];
    }
    if (otherTitle) {
        [ac addAction:[UIAlertAction actionWithTitle:otherTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
            if (tapBlock) {
                tapBlock(UIAlertFirstOtherButtonIndex);
            }
        }]];
    }
    
    [self presentViewController:ac animated:YES completion:nil];
}

- (NSData*)p_takeScreenShot:(UIImage*)image
{
    NSData* imageData = [[NSData alloc] initWithData:UIImagePNGRepresentation( image )] ;

    return imageData;
}

- (void)p_sendMessage {
    if (self.videoPath) {
        __weak typeof(self) wself = self;
        
        NSInteger videoSize = [self.videoPath fileSize];
        NSInteger indicatorThresholdSize = 1 * 1024 * 1024;
        if (videoSize > indicatorThresholdSize) {
            [self enableActivityIndicator:YES];
        }
        
        [wself p_sendMessage:nil videoPath:self.videoPath];
    } else {
        [self p_sendMessage:self.imageView.image videoPath:nil];
    }
}

- (void)p_sendMessage:(UIImage*)image videoPath:(NSURL *)videoPath
{
    //ScreenShot取得
    NSData *imageData = [self p_takeScreenShot:image];

    SendData* data = [SendData new];
    data.imageData = imageData;
    data.videoPath = videoPath;
    data.title = self.titleTextField.text;
    data.category = self.feedbackCategoryButton.currentTitle;
    data.comment = self.freeCommentField.text;
    data.username = self.reporterName.text;
    data.appTitle = (NSString*)[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    data.appVersion = DeviceUtil.appVersion;
    data.appBuildVersion = DeviceUtil.appBuildVersion;
    data.systemVersion = DeviceUtil.OSVersion;
    data.modelCode = DeviceUtil.ModelCode;
    data.modelName = DeviceUtil.ModelName;

    SlackAPI* slackAPI = [[SlackAPI alloc] initWithToken:self.config.slackToken channel:self.config.slackChannel];
    [slackAPI postData:data
     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self enableActivityIndicator:NO];
        if (error) {
            if (error.code == kCFURLErrorUserCancelledAuthentication) {//401(Authentication failure)
                [self
                 p_createAlertWithTitle:AppFeedbackLocalizedString(@"slackPostErrorTitle", @"")
                 message:AppFeedbackLocalizedString(@"slackPostInvalidMessage", @"")
                 cancelButtonTitle:nil
                 destructiveButtonTitle:nil
                 otherButtonTitle:@"OK"
                 tapBlock:nil];
            } else {
                [self
                 p_createAlertWithTitle:AppFeedbackLocalizedString(@"slackPostErrorTitle", @"")
                 message:AppFeedbackLocalizedString(@"slackPostClientErrorMessage", @"")
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
                if (responseDictionary[@"mym_res"] == [NSNull null]) {
                    [self
                     p_createAlertWithTitle:AppFeedbackLocalizedString(@"slackPostErrorTitle", @"")
                     message:AppFeedbackLocalizedString(@"slackPostSettingErrorMessage", @"")
                     cancelButtonTitle:nil
                     destructiveButtonTitle:nil
                     otherButtonTitle:@"OK"
                     tapBlock:nil];
                    return;
                }
                
                if ([responseDictionary[@"ok"] boolValue] == NO) {
                    NSString *errorMessage = responseDictionary[@"error"];
                    [self p_createAlertWithTitle:@"Slack Error" message: errorMessage cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitle:@"OK" tapBlock:nil];
                    return;
                }
                
                self.titleTextField.text = @"";
                self.freeCommentField.text = @"";
                [self doneSelectedFeedbackCategory:self.notSelectedCategoryTitle :false]; // 未選択の状態に戻す
                
                [self
                 p_createAlertWithTitle:AppFeedbackLocalizedString(@"slackPostSuccessTitle", @"")
                 message:AppFeedbackLocalizedString(@"slackPostSuccessMessage", @"")
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
                 p_createAlertWithTitle:AppFeedbackLocalizedString(@"slackPostErrorTitle", @"")
                 message:AppFeedbackLocalizedString(@"slackPostAuthorizationErrorMessage", @"")
                 cancelButtonTitle:nil
                 destructiveButtonTitle:nil
                 otherButtonTitle:@"OK"
                 tapBlock:nil];
                break;
                
            case 404://Application Not found
                [self
                 p_createAlertWithTitle:AppFeedbackLocalizedString(@"slackPostErrorTitle", @"")
                 message:AppFeedbackLocalizedString(@"slackPostDataNotFoundErrorMessage", @"")
                 cancelButtonTitle:nil
                 destructiveButtonTitle:nil
                 otherButtonTitle:@"OK"
                 tapBlock:nil];
                break;
                
            case 500://Internal Error
                [self
                 p_createAlertWithTitle:AppFeedbackLocalizedString(@"slackPostErrorTitle", @"")
                 message:AppFeedbackLocalizedString(@"slackPostUnknownErrorMessage", @"")
                 cancelButtonTitle:nil
                 destructiveButtonTitle:nil
                 otherButtonTitle:@"OK"
                 tapBlock:nil];
                break;
                
            default:
                [self
                 p_createAlertWithTitle:AppFeedbackLocalizedString(@"slackPostErrorTitle", @"")
                 message:[NSString stringWithFormat:AppFeedbackLocalizedString(@"slackPostUnknownErrorStatucCodeMessage", @""), (long)statusCode]
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
         message:AppFeedbackLocalizedString(@"confirmReportSettingInputTitleMessage", @"")
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
         p_createAlertWithTitle:AppFeedbackLocalizedString(@"confirmReportSettingMessage", @"")
         message:AppFeedbackLocalizedString(@"confirmReportSettingSlackIdCausionMessage", @"")
         cancelButtonTitle:nil
         destructiveButtonTitle:nil
         otherButtonTitle:@"OK"
         tapBlock:^(NSInteger buttonIndex){
            [self.reporterName becomeFirstResponder];
        }];
        return;
    }
    
    NSString *confirmMsg = AppFeedbackLocalizedString(@"confirmReportSettingMessage", @"");
    
    if ([self.feedbackCategoryButton.currentTitle  isEqual: self.notSelectedCategoryTitle]) {
        confirmMsg = [NSString stringWithFormat:@"%@\n\n%@", confirmMsg, AppFeedbackLocalizedString(@"confirmReportSettingNotSelectedCategoryMessage", @"")];
    }


    [self p_createAlertWithTitle:AppFeedbackLocalizedString(@"confirm", @"") message:confirmMsg cancelButtonTitle:AppFeedbackLocalizedString(@"cancel", @"") destructiveButtonTitle:nil otherButtonTitle:AppFeedbackLocalizedString(@"send", @"") tapBlock:^(NSInteger buttonIndex){
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
    NSString *message = [NSString stringWithFormat:AppFeedbackLocalizedString(@"videoButtonTappedAlertMessage", @""), (int)floor(VIDEO_LIMIT_SECS)];
    [self p_createAlertWithTitle:AppFeedbackLocalizedString(@"videoButtonTappedAlertTitle", @"") message:message cancelButtonTitle:AppFeedbackLocalizedString(@"cancel", @"") destructiveButtonTitle:nil otherButtonTitle:AppFeedbackLocalizedString(@"videoButtonTappedAlertStartButtonTitle", @"") tapBlock:^(NSInteger buttonIndex){
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
    navController.navigationBar.barTintColor = Color.navBarTint;
    navController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: UIColor.whiteColor };
}

// フィードバックカテゴリ選択ボタンを押下した時の処理
- (IBAction)selectFeedbackCategory:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:AppFeedbackLocalizedString(@"categoryMessage", @"")
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:AppFeedbackLocalizedString(@"cancel", @"")
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
