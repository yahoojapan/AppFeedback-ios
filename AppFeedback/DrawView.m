//
//  DrawView.m
//  DrawView
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


#import "DrawView.h"
#import "DrawViewController.h"

@interface DrawView ()

@property (weak, nonatomic) UIImageView *imageView;
@property (nonatomic) CGPoint panningStartPoint;
@property (nonatomic) CGRect panningRect;
@property (nonatomic) float lineWidthRatio;

@end

@implementation DrawView

// DrawViewに対する合成画像の大きさ
static const float COMPOSITE_IMAGE_SIZE_RATIO = 2.0;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    CGRect screen = [[UIScreen mainScreen] bounds];
    if (self) {
        // スクリーンサイズに対する強調枠線の太さの比を設定（4pxを基準とする）
        if (screen.size.width < screen.size.height) {
            self.lineWidthRatio = 4.0/screen.size.width;
        } else {
            self.lineWidthRatio = 4.0/screen.size.height;
        }
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    // コンテキストの初期化
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context,[UIColor redColor].CGColor);
    
    // 強調枠線の太さを設定
    CGFloat lineWidth;
    
    // Viewの縦・横幅の小さい方を基準として太さを決める
    if (self.frame.size.width < self.frame.size.height) {
        lineWidth = self.frame.size.width * self.lineWidthRatio;
    } else {
        lineWidth = self.frame.size.height * self.lineWidthRatio;
    }
    CGContextSetLineWidth(context, lineWidth);
    
    // 強調枠線の描画
    CGContextAddRect(context,self.panningRect);
    CGContextStrokePath(context);
}

// UIViewの描画内容をUIImageに変換する
- (UIImage *)transformViewToImage {
    // コンテキストにUIViewの内容を描画
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    
    // コンテキストの内容をUIImageに変換
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // コンテキストの解放
    UIGraphicsEndImageContext();
    
    return image;
}

// 裏側にあるUIImageViewを変数として保持する
- (void)linkUIImageView:(UIImageView *)imageView {
    self.imageView = imageView;
}

//画面がタッチされた時，描画開始座標を取得
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.panningStartPoint = [[touches anyObject] locationInView:self];
}

// ドラッグ中の強調枠線を描画
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint panningCurrentPoint = [[touches anyObject] locationInView:self];
    CGSize panSize = CGSizeMake(panningCurrentPoint.x - self.panningStartPoint.x, panningCurrentPoint.y - self.panningStartPoint.y);
    self.panningRect = CGRectMake(self.panningStartPoint.x, self.panningStartPoint.y, panSize.width, panSize.height);
    [self setNeedsDisplay];
}

// 描画した枠線を裏のImageViewに合成する
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // 合成素材(スクリーンショットのImage・強調枠線のImage)の初期化
    UIImage *drawImage = [self transformViewToImage];
    UIImage *resizedOriginalImage = [[UIImage alloc] initWithCGImage:self.imageView.image.CGImage];
    
    // 画像の合成
    CGFloat imageWidth = self.frame.size.width * COMPOSITE_IMAGE_SIZE_RATIO;
    CGFloat imageHeight = self.frame.size.height * COMPOSITE_IMAGE_SIZE_RATIO;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageWidth, imageHeight), false, 0.0);
    [resizedOriginalImage drawInRect:CGRectMake(0, 0, imageWidth, imageHeight)];
    [drawImage drawInRect:CGRectMake(0, 0, imageWidth, imageHeight)];
    
    // 合成後の画像をViewの背景画像にする
    UIImage *blendImage = UIGraphicsGetImageFromCurrentImageContext();
   
    // ドラッグ終了をDrawViewControllerに通知する
    [self.delegate finishPannig:blendImage];
    
    UIGraphicsEndImageContext();
    self.panningRect = CGRectNull;
    [self setNeedsDisplay];
}

@end
