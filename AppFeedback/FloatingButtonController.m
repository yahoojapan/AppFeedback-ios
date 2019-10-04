//
//  FloatingButtonController.m
//  FloatingButtonController
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


#import "FloatingButtonController.h"
#import "FloatingButtonView.h"
#import "FloatingButtonOuterView.h"
#import "AppFeedbackInternal.h"
#import "AppFeedback.h"


// ボタンの直径st
static const CGFloat BUTTON_SIZE = 50.0;
static const CGFloat SHADOW_SIZE = 5.0;

@interface FloatingButtonController ()

@property (nonatomic, strong) FloatingButtonWindow *window;
@property (nonatomic, strong) FloatingButtonView *buttonView;

@end

@implementation FloatingButtonController

- (id)init {    
    if (self = [super init]) {
        self.window = [[FloatingButtonWindow alloc] init];

        self.hidden = NO;
        self.window.rootViewController = self;
    }
    return self;
}

- (BOOL)hidden {
    return self.window.hidden;
}

- (void)setHidden:(BOOL)hidden {
    self.window.hidden = hidden;
}

- (void)setButtonState:(FloatingButtonState)buttonState {
    self.buttonView.buttonState = buttonState;
}

- (void)loadView {
    NSBundle *bundle = AppFeedback.frameworkBundle;

    // 初期位置
    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    CGRect initRect = CGRectMake(screenSize.width - (BUTTON_SIZE + SHADOW_SIZE),
                                 70,
                                 BUTTON_SIZE + SHADOW_SIZE * 2,
                                 BUTTON_SIZE + SHADOW_SIZE * 2);
    self.window.frame = initRect;

    FloatingButtonOuterView *view = [[FloatingButtonOuterView alloc] initWithFrame:CGRectMake(SHADOW_SIZE, SHADOW_SIZE, BUTTON_SIZE, BUTTON_SIZE)];
    view.backgroundColor = [UIColor clearColor];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [[UIColor blackColor] CGColor];
    view.layer.shadowRadius = 2;
    view.layer.shadowOpacity = 0.5;
    view.layer.shadowOffset = CGSizeMake(0.5, 2);
    view.layer.cornerRadius = BUTTON_SIZE / 2;

    FloatingButtonView *buttonView = [[bundle loadNibNamed:@"FloatingButton" owner:nil options:0] firstObject];
    buttonView.frame = CGRectMake(SHADOW_SIZE, SHADOW_SIZE, BUTTON_SIZE, BUTTON_SIZE);
    buttonView.layer.cornerRadius = BUTTON_SIZE / 2;
    buttonView.buttonState = FloatingButtonStateFeedback;
    [buttonView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTapped:)]];
    view.autoresizesSubviews = NO;

    [view addSubview:buttonView];
    view.buttonView = buttonView;

    self.buttonView = buttonView;
    self.window.buttonView = buttonView;

    UIPanGestureRecognizer *panner = [[UIPanGestureRecognizer new] initWithTarget:self action:@selector(pandDidFire:)];
    [buttonView addGestureRecognizer:panner];

    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [self snapButtonToSocket];
}

- (void)snapButtonToSocket {
    CGFloat distanceToBestSocket = CGFLOAT_MAX;
    CGPoint center = self.window.center;
    CGPoint bestSocket = center;
    CGFloat snapDistanceThreshold = 50;

    for (NSValue *v in [self sockets]) {
        CGPoint socket = v.CGPointValue;

        // 画面の隅に来ていたらsnapする
        CGFloat distance = hypot(center.x - socket.x, center.y - socket.y);
        if (distance < distanceToBestSocket && distance < snapDistanceThreshold) {
            distanceToBestSocket = distance;
            bestSocket = socket;
        }
    }
    
    // 画面からはみ出していたら画面内に収めるように移動

    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    
    if (bestSocket.x - self.window.bounds.size.width / 2 < 0) {
        bestSocket.x = self.window.bounds.size.width / 2;
    }
    else if (bestSocket.x + self.window.bounds.size.width / 2 > screenSize.width) {
        bestSocket.x = screenSize.width - self.window.bounds.size.width / 2;
    }

    if (bestSocket.y - self.window.bounds.size.height / 2 < 0) {
        bestSocket.y = self.window.bounds.size.height / 2;
    }
    else if (bestSocket.y + self.window.bounds.size.height / 2 > screenSize.height) {
        bestSocket.y = screenSize.height - self.window.bounds.size.height / 2;
    }

    self.window.center = bestSocket;
}


- (NSArray *)sockets {
    CGSize buttonSize = self.buttonView.bounds.size;
    CGFloat margin = 4;
    CGRect rect = CGRectInset(UIScreen.mainScreen.bounds, margin + buttonSize.width / 2, margin + buttonSize.height / 2);

    NSArray *sockets = @[
                       [NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))],
                       [NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))],
                       [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))],
                       [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))],
                       ];
    return sockets;
}

- (void)pandDidFire:(UIPanGestureRecognizer *)panner {
    CGPoint offset = [panner translationInView:panner.view];
    [panner setTranslation:CGPointZero inView:panner.view];

    CGPoint center = self.window.center;
    center.x += offset.x;
    center.y += offset.y;
    self.window.center = center;

    CGFloat animDuration = 0.3;
    if (panner.state == UIGestureRecognizerStateEnded || panner.state == UIGestureRecognizerStateCancelled) {
        [UIView animateWithDuration:animDuration animations:^{
            [self snapButtonToSocket];
        }];
    }
}

- (void)buttonTapped:(UITapGestureRecognizer *)recognizer {
    if (self.delegate) {
        [self.delegate floatingButtonTapped];
    }
}

#pragma mark - rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // 何故か回転中に UIWindow の周りが黒くなるので回転中は消す
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.hidden = YES;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [AppFeedback.shared updateFloatingButtonState];
    }];
}

#pragma mark - progress

- (void)startProgressWithSecs:(float)seconds {
    [self.buttonView startProgressWithSecs:seconds];
}

- (void)endProgress {
    [self.buttonView endProgress];
}

@end
