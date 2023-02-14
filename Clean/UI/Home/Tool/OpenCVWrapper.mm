//
//  OpenCVWrapper.m
//  OpenCVDemo
//
//  Created by Urika on 2020/10/26.
//  Copyright © 2020年 dev. All rights reserved.
//

#import <opencv2/calib3d.hpp>
#import <opencv2/features2d.hpp>
#import <opencv2/xfeatures2d.hpp>
#import <opencv2/imgproc/imgproc.hpp>

#import "OpenCVWrapper.h"

#include "iostream"
using namespace std;

@implementation OpenCVWrapper

/**
 UIImage转换为Mat
 */
cv::Mat cvMatFromUIImage(UIImage * image)
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}


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
+(BOOL) checkBurry:(UIImage*) image {
    cv::Mat matImage = cvMatFromUIImage(image);
    
    // 将图片转换为灰度图片
    cv::Mat matImageGrey;
    cvtColor(matImage, matImageGrey, cv::COLOR_BGR2GRAY);
    matImage.release();
    
    // 边缘检测,Laplacian变换
    cv::Mat laplacianImage;
    Laplacian(matImageGrey, laplacianImage, CV_64F);
    matImageGrey.release();
    
    // 计算方差
    cv::Scalar mean, stddev; // 0:1st channel, 1:2nd channel and 2:3rd channel
    meanStdDev(laplacianImage, mean, stddev, cv::Mat());
    double variance = stddev.val[0] * stddev.val[0];
    laplacianImage.release();
    
    double threshold = 100;
    
    // 根据Laplacian变换的方差值进行判断
    BOOL isBlur = variance <= threshold;

    return isBlur;
}

/**
 缩放图片
 */
UIImage* scaleToSize(UIImage* img, CGSize size) {
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
} 

/**
 计算图片均值哈希值
 */
+ (UInt64) calcHash:(UIImage*)image {
    image = scaleToSize(image,CGSizeMake(8, 8));
    cv::Mat matImage = cvMatFromUIImage(image);
    // 将图片转换为灰度图片
    cv::Mat matImageGrey;
    cvtColor(matImage, matImageGrey, cv::COLOR_BGR2GRAY);
    matImage.release();
    
    int s = 0;
    for (int i = 0; i<matImageGrey.cols ; i++) {
        for (int j = 0; j<matImageGrey.rows ; j++) {
            s += *matImageGrey.ptr(i, j);
        }
    }
    int avg = s / 64;
	UInt64 hash = 0;
    for (int i = 0; i<matImageGrey.cols ; i++) {
        for (int j = 0; j<matImageGrey.rows ; j++) {
            if(*matImageGrey.ptr(i, j) > avg) {
                hash |= (((UInt64)1) << (i * 8 + j));
            }
        }
    }
    matImageGrey.release();
    
    return hash;
}


/**
 计算图片直方图矩阵
 */
cv::Mat calc_hist(UIImage* orgImg) {
    cv::Mat matOrgImage = cvMatFromUIImage(orgImg);
    //HSV颜色特征模型(色调H,饱和度S，亮度V)
    cvtColor(matOrgImage, matOrgImage, cv::COLOR_BGR2HSV);
    int hBins = 256, sBins = 256;
    int histSize[] = { hBins,sBins };
    //H:0~180, S:0~255,V:0~255
    //H色调取值范围
    float hRanges[] = { 0,180 };
    //S饱和度取值范围
    float sRanges[] = { 0,255 };
    const float* ranges[] = { hRanges,sRanges };
    int channels[] = { 0,1 };//二维直方图
    cv::Mat hist1;
    calcHist(&matOrgImage, 1, channels, cv::Mat(), hist1, 2, histSize, ranges, true, false);
    normalize(hist1, hist1, 0, 1, cv::NORM_MINMAX, -1, cv::Mat());
	matOrgImage.release();
    return hist1;
}


/**
 检测两张图片是否相似
 
 颜色分布法
 
 每张图片都可以生成颜色分布的直方图（color histogram）。如果两张图片的直方图很接近，就可以认为它们很相似。
 */
+ (BOOL) checkSimilar2:(UIImage*)imageA imageB:(UIImage*)imageB {
    cv::Mat hist1 = calc_hist(imageA);
    cv::Mat hist2 = calc_hist(imageB);
    double similarityValue = compareHist(hist1, hist2, cv::HISTCMP_CORREL);
	hist1.release();
	hist2.release();
//    cout << "相似度：" << similarityValue << endl;
    if (similarityValue >= 0.85)
    {
        return true;
    }
    return false;
}


/**
 检测两张图片是否相似 - 特征比较法
 */
+ (BOOL) checkSimilar3:(UIImage*)imageA imageB:(UIImage*)imageB {
    return compareImagesSURF(imageA, imageB, 100) < 1;
}

/**
 * \brief	Matches the two given sets of feature descriptors and
 *		calculates a value representing the similarity of the
 *		associated images. This is done by considering only
 *		"good" matches i.e. matches with a small distance.
 *
 * \param 	descriptors1	A matrix holding all descriptors of the
 *				first image
 * \param	descriptors2	A matrix holding all descriptors of the
 *				second image
 *
 * \return	The sum of all squared distances in the resulting matching.
 */
float matchDescriptors(cv::Mat& descriptors1, cv::Mat& descriptors2)
{
    float result = 0;
    
    //calculate matching
    cv::FlannBasedMatcher matcher;
    vector< cv::DMatch > matches;
    matcher.match( descriptors1, descriptors2, matches);
    
    //search best match
    double minDist = 100;
    for (int i = 0; i < matches.size(); i++)
    {
        if(matches[i].distance < minDist) minDist = matches[i].distance;
    }
    
    //Calculate result. Only good matches are considered.
    int numGoodMatches = 0;
    for( int i = 0; i < matches.size(); i++ )
    {
        if(matches[i].distance <= 2 * minDist)
        {
            result += matches[i].distance * matches[i].distance;
            numGoodMatches++;
        }
    }
    result /= numGoodMatches;
    result *= 1000;
    //cout << "numGoodMatches:" << numGoodMatches << "/" << matches.size() << endl;
    
    return result;
}

/**
 * \brief	Compares two images using SURF features
 *
 * \param	imageA	The fist image. Must be a 3 channel RGB image.
 * \param	imageB	The second image. Must be a 3 channel RGB image.
 * \param	ht	The hessian Threshold used in the SURF algorithm
 *
 * \return	A value indicating the distance between the both images.
 *		0 means that both images are identical. The higher the
 *		distance, the lower the similarity of the images.
 */
double compareImagesSURF(UIImage* imageA, UIImage* imageB, double ht)
{
    cv::Mat image1 = cvMatFromUIImage(imageA);
    cv::Mat image2 = cvMatFromUIImage(imageB);
    
    //convert first image to gray scale
    cv::Mat img1;
    cv::cvtColor(image1, img1, cv::COLOR_RGB2GRAY);
    image1.release();
    
    //convert second image to gray scale
    cv::Mat img2;
    cv::cvtColor(image2, img2, cv::COLOR_RGB2GRAY);
    image2.release();
    
    //initialize SURF objects
    cv::Ptr<cv::xfeatures2d::SURF> detector = cv::xfeatures2d::SURF::create(ht);
    
    vector<cv::KeyPoint> keyPoints1, keyPoints2;
    cv::Mat descriptors1, descriptors2;
    
    //calculate SURF features for the first image
    detector->detectAndCompute(img1, cv::Mat(), keyPoints1, descriptors1);
    
    //calculate SURF features for the second image
    detector->detectAndCompute(img2, cv::Mat(), keyPoints2, descriptors2);
    
    //compare features
    float result = FLT_MAX;
    if (keyPoints1.size() > 0 && keyPoints2.size() > 0)
    {
        result = matchDescriptors(descriptors1, descriptors2);
    }
    descriptors1.release();
    descriptors2.release();
    img1.release();
    img2.release();
    
//    cout << "compareImagesSURF: " << result << endl;
    return result;
}
@end
