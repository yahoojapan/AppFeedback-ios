//
//  DrawViewController.m
//  DrawViewController
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


#import "DrawViewController.h"
#import "DrawView.h"

@interface DrawViewController () <DrawViewDelegate>

@property CGPoint startPoint;
@property CGPoint currentPoint;

@end

@implementation DrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 編集途中の画像がある場合はそれを表示する
    if (self.editingImage) {
        self.imageView.image = self.editingImage;
        self.clearButton.enabled = true;
    } else {
        self.imageView.image = self.originImage;
        self.clearButton.enabled = false;
    }
    
    // 描画領域のアスペクト比は画像に合わせて動的に変更
    NSLayoutConstraint *drawingRectAspect = [NSLayoutConstraint constraintWithItem:self.drawingView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.drawingView attribute:NSLayoutAttributeWidth multiplier:self.originImage.size.height/self.originImage.size.width constant:1];
    drawingRectAspect.priority = 1000;
    [self.drawingView addConstraint:drawingRectAspect];
    
    self.drawingView.delegate = self;
    
    [self.drawingView linkUIImageView:self.imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// クリアボタンを押された場合の処理
- (IBAction)undo:(id)sender {
    self.imageView.image = self.originImage;
    self.clearButton.enabled = false;
    self.editingImage = nil;
}

// DrawViewがドラッグされた時の処理
- (void)finishPannig:(UIImage*)image {
    self.imageView.image = image;
    self.clearButton.enabled = true;
    self.editingImage = image;
}
- (IBAction)closeButtonTapped:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
