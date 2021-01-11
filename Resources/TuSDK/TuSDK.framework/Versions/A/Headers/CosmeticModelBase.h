//
//  CosmeticModelBase.h
//  TuSDK
//
//  Created by tusdk on 2020/10/13.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TuSDKFaceAligment.h"

static float COSMETIC_DEFAULT_VERTEX[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        1.0f, 1.0f,
        -1.0f, 1.0f
};

static int COSMETIC_DEFAULT_VERTEX_LENGTH = 8;

static float COSMETIC_DEFAULT_TEXTURE[] = {
        0.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
};

static int COSMETIC_DEFAULT_TEXTURE_LENGTH = 12;

@interface CosmeticModelBase : NSObject


-(void) updateFace:(TuSDKFaceAligment *)face size:(CGSize)size;

// 顶点坐标
 @property(readwrite,nonatomic) GLfloat *position;

// 纹理坐标
 @property(readwrite,nonatomic) GLfloat *coordinate;

-(GLfloat *)coordinate2;

-(GLint *)elementBuffer;

-(GLint)elementBufferSize;


@end

