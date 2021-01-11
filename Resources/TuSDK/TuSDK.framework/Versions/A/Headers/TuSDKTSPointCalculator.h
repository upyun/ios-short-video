//
//  PointCalc.h
//  TuSDK
//
//  Created by tutu on 2018/8/20.
//  Copyright © 2018年 tusdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PointCalc : NSObject


+(float) Distance:(CGPoint)start end:(CGPoint)end;
+(CGPoint) Center:(CGPoint)start end:(CGPoint)end;
+(CGPoint) Cross:(CGPoint)aStart aEnd:(CGPoint)aEnd bStart:(CGPoint)bStart bEnd:(CGPoint)bEnd;
+(CGPoint) Extension:(CGPoint)start end:(CGPoint)end percentage:(float)percentage;
+(CGPoint) Extension:(CGPoint)start end:(CGPoint)end distance:(float)distance;

+(CGPoint) Percentage:(CGPoint)start end:(CGPoint)end percentage:(float)percentage;

+(CGRect)Circle:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3; // 计算三个点所包含的圆，返回值为(centerX, centerY, radius, radius)
+(CGPoint) Rotate:(CGPoint)point center:(CGPoint)center angle:(float)angle;
+(CGPoint) Vertical:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3;
+(NSArray*) VerticalPointsByDistance:(CGPoint)p1 p2:(CGPoint)p2 distance:(float)distance; //计算p2 p1垂线上距离p1点距离为distance的两个点

+(CGPoint) Minus:(CGPoint)p1 p2:(CGPoint)p2;
+(CGPoint) Add:(CGPoint)p1 p2:(CGPoint)p2;

+(CGPoint) Real:(CGPoint)p1 size:(CGSize)size;
+(CGPoint) Normalize:(CGPoint)p1 size:(CGSize)size;

+(float) smoothstep:(float)a b:(float)b x:(float)x;

/* 3点确地一圆心，按照数量<count>等分取前两点构成的圆弧上的点 */
+(NSArray *) pointerInsert:(CGPoint) pt1 pt2:(CGPoint) pt2 pt3:(CGPoint) pt3 count:(int)count invert:(BOOL)invert;

/* 3点确地一圆心，取前两点构成的圆弧上的中点 */
+(CGPoint) pointerInsert:(CGPoint) pt1 pt2:(CGPoint) pt2 pt3:(CGPoint) pt3;

/* 已知直线AB = （pa,pb）,求一点p，直线PC=（p,pc）,直线PB=(p,pb),使得PC 平行于 AB , PB 垂直于 AB。 */
+(CGPoint) boundCornerPoint:(CGPoint) pa pb:(CGPoint) pb pc:(CGPoint) pc;

/* 已知直线AB = （pa,pb）,求一点P，直线PA=（p,pa）,使得点P与点A的距离为dis , PA 垂直于 AB。 */
+(NSArray *)footPoint:(CGPoint)pa pb:(CGPoint)pb dis:(float)dis;

@end
