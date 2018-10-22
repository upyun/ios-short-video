//
//  TuSDKOpenGLAssistant_h

//  TuSDKVideo
//
//  Created by sprint on 09/05/2018.
//  Copyright © 2018 TuSDK. All rights reserved.
//

#ifndef TuSDKOpenGLAssistant_h
#define TuSDKOpenGLAssistant_h

/** 正常角度不旋转 */
static GLfloat lsqNoRotationTextureCoordinates[] = {
    0.0f, 0.0f,1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f,};
/** 旋转270度 */
static GLfloat lsqRotateLeftTextureCoordinates[] = {
    1.0f, 0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f, };
/** 旋转90度 */
static GLfloat lsqRotateRightTextureCoordinates[] = {
    0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 0.0f, };
/** 垂直镜像 */
static GLfloat lsqVerticalFlipTextureCoordinates[] = {
    0.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, };
/** 水平镜像 */
static GLfloat lsqHorizontalFlipTextureCoordinates[] = {
    1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 1.0f, };
/** 旋转90度垂直镜像 */
static GLfloat lsqRotateRightVerticalFlipTextureCoordinates[] = {
    0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 1.0f, 1.0f, };
/** 旋转90度水平镜像 */
static GLfloat lsqRotateRightHorizontalFlipTextureCoordinates[] = {
    1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, };
/** 旋转180度 */
static GLfloat lsqRotate180TextureCoordinates[] = {
    1.0f, 1.0f, 0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f, };

/** 材质绘制顶点 */
static GLfloat lsqImageVertices[] = {
    -1.0f, -1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 1.0f, 1.0f, };


/***
 * 根据方向获取坐标信息
 * @param rotationMode 方向
 * @return 坐标信息
 */
static GLfloat* textureCoordinatesFromOrientation(GPUImageRotationMode rotationMode)
{
    
    switch (rotationMode) {
        case kGPUImageRotateLeft:
            return lsqRotateLeftTextureCoordinates;
        case kGPUImageRotateRight:
            return lsqRotateRightTextureCoordinates;
        case kGPUImageFlipVertical:
            return lsqVerticalFlipTextureCoordinates;
        case kGPUImageFlipHorizonal:
            return lsqHorizontalFlipTextureCoordinates;
        case kGPUImageRotateRightFlipVertical:
            return lsqRotateRightVerticalFlipTextureCoordinates;
        case kGPUImageRotateRightFlipHorizontal:
            return lsqRotateRightHorizontalFlipTextureCoordinates;
        case kGPUImageRotate180:
            return lsqRotate180TextureCoordinates;
        case kGPUImageNoRotation:
        default:
            return lsqNoRotationTextureCoordinates;
    }
}

/** 计算旋转坐标*/
static void rotateCoordinates(GPUImageRotationMode rotation, GLfloat* textureCoordinates)
{
    GLfloat t[] = {textureCoordinates[0], textureCoordinates[1], textureCoordinates[2], textureCoordinates[3], textureCoordinates[4],textureCoordinates[5], textureCoordinates[6], textureCoordinates[7]};
    
    switch (rotation)
    {
        case kGPUImageFlipHorizonal:
            textureCoordinates[0] = t[2];
            textureCoordinates[1] = t[3];
            textureCoordinates[2] = t[0];
            textureCoordinates[3] = t[1];
            textureCoordinates[4] = t[6];
            textureCoordinates[5] = t[7];
            textureCoordinates[6] = t[4];
            textureCoordinates[7] = t[5];
            break;
        case kGPUImageFlipVertical:
            
            textureCoordinates[0] = t[4];
            textureCoordinates[1] = t[5];
            textureCoordinates[2] = t[6];
            textureCoordinates[3] = t[7];
            textureCoordinates[4] = t[0];
            textureCoordinates[5] = t[1];
            textureCoordinates[6] = t[2];
            textureCoordinates[7] = t[3];
            
            break;
        case kGPUImageRotateLeft:
            
            textureCoordinates[0] = t[2];
            textureCoordinates[1] = t[3];
            textureCoordinates[2] = t[6];
            textureCoordinates[3] = t[7];
            textureCoordinates[4] = t[0];
            textureCoordinates[5] = t[1];
            textureCoordinates[6] = t[4];
            textureCoordinates[7] = t[5];
            
            
            break;
        case kGPUImageRotateRight:
            
            textureCoordinates[0] = t[4];
            textureCoordinates[1] = t[5];
            textureCoordinates[2] = t[0];
            textureCoordinates[3] = t[1];
            textureCoordinates[4] = t[6];
            textureCoordinates[5] = t[7];
            textureCoordinates[6] = t[2];
            textureCoordinates[7] = t[3];
            
            
            break;
        case kGPUImageRotateRightFlipVertical:
            
            textureCoordinates[0] = t[0];
            textureCoordinates[1] = t[1];
            textureCoordinates[2] = t[4];
            textureCoordinates[3] = t[5];
            textureCoordinates[4] = t[2];
            textureCoordinates[5] = t[3];
            textureCoordinates[6] = t[6];
            textureCoordinates[7] = t[7];
            
            break;
        case kGPUImageRotateRightFlipHorizontal:
            
            textureCoordinates[0] = t[6];
            textureCoordinates[1] = t[7];
            textureCoordinates[2] = t[2];
            textureCoordinates[3] = t[3];
            textureCoordinates[4] = t[4];
            textureCoordinates[5] = t[5];
            textureCoordinates[6] = t[0];
            textureCoordinates[7] = t[1];
            
            
            break;
        case kGPUImageRotate180:
            
            textureCoordinates[0] = t[6];
            textureCoordinates[1] = t[7];
            textureCoordinates[2] = t[4];
            textureCoordinates[3] = t[5];
            textureCoordinates[4] = t[2];
            textureCoordinates[5] = t[3];
            textureCoordinates[6] = t[0];
            textureCoordinates[7] = t[1];
            
            break;
        case kGPUImageNoRotation:
        default:
            break;
    }
    
}

#endif /* TuSDKOpenGLAssistant_h */

