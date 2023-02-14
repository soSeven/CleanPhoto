//
//  OpenCVWrapper.h
//  OpenCVDemo
//
//  Created by Urika on 2020/10/26.
//  Copyright © 2020年 dev. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject
/**
 模糊图片检测
 
 原理简介
 整个算法的原理和拉普拉斯算子本身的定义有关，该算子主要用来测量图像的二阶导数。它强调了包含快速强度变化的图像区域。拉普拉斯算子经常被用来做边缘检测。
 这里存在着一个假设，即如果一个图像中包含着高方差，那么在图像中会有较大范围的响应，包括边缘和非边缘，这代表着一张正常图像。但是如果该图像的方差很低，那么响应的范围很小，这表明图像中的边缘很小。众所周知的是当图像越模糊时，包含的边缘信息就会越少。
 
 算法实现步骤
 步骤1-读取输入图片；
 步骤2-输入图片灰度化；
 步骤3-与特定的Laplacian核进行卷积；
 步骤4-计算响应的方差值；
 步骤5-如果当前的方差值<threshold，则该图片为模糊图片，否则不是模糊图片。
 
 @param image 需要检测的UIImage
 @return 是否模糊
 */
+ (BOOL)checkBurry:(UIImage*) image;

/**
 计算图片均值哈希值
 */
+ (UInt64) calcHash:(UIImage*)image;

/**
 检测两张图片是否相似 - 颜色分布法
 
 每张图片都可以生成颜色分布的直方图（color histogram）。如果两张图片的直方图很接近，就可以认为它们很相似。
 */
+ (BOOL)checkSimilar2:(UIImage*)imageA imageB:(UIImage*)imageB;

/**
 检测两张图片是否相似 - 特征比较法
 
 提取图片的特征点，并对比特征是否相似
 */
+ (BOOL)checkSimilar3:(UIImage*)imageA imageB:(UIImage*)imageB;



@end

NS_ASSUME_NONNULL_END

