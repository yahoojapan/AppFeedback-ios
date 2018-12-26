//
//  ExpansionButton.m
//  ExpansionButton
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


#import <Foundation/Foundation.h>
#import "ExpansionButton.h"

@interface ExpansionButton ()
#pragma mark - Private properties
@property (nonatomic) CGFloat leftPerceivableArea;
@property (nonatomic) CGFloat rightPerceivableArea;
@end

@implementation ExpansionButton

- (void)setPerceivableAreaWithLeftArea:(CGFloat)leftArea rightArea:(CGFloat)rightArea {
    self.leftPerceivableArea = leftArea;
    self.rightPerceivableArea = rightArea;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // タップ確認用の CGRect を新規作成
    CGRect rect = self.bounds;

    // 指定した Area 分、拡張する（位置をオフセットし、幅を足す）
    rect.origin.x -= self.leftPerceivableArea;
    rect.size.width  += (self.leftPerceivableArea + self.rightPerceivableArea);

    // 拡張したエリアとのタップ判定を返す
    return CGRectContainsPoint(rect, point);
}

@end
