//
//  TuSDKVideo.h
//  TuSDKVideo
//
//  Created by Yanlin on 3/5/16.
//  Copyright © 2016 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TuSDKVideoImport.h"
#import "TuSDKLiveVideoCamera.h"
#import "TuSDKRecordVideoCamera.h"
#import "TuSDKLiveVideoProcessor.h"
#import "TuSDKLiveRTCProcessor.h"
#import "TuSDKFilterProcessor.h"
#import "TuSDKVideoFocusTouchView.h"
#import "TuSDKFilterConfigProtocol.h"
#import "TuSDKFilterConfigViewBase.h"
#import "TuSDKMovieEditor.h"
#import "TuSDKVideoResult.h"
#import "TuSDKAudioResult.h"
#import "TuSDKMoiveFragment.h"

// 视频渲染特效

#import "TuSDKMediaEffectData.h"
#import "TuSDKMediaAudioEffectData.h"
#import "TuSDKMediaStickerAudioEffectData.h"
#import "TuSDKMediaParticleEffectData.h"
#import "TuSDKMediaSceneEffectData.h"
#import "TuSDKMediaTextEffectData.h"
#import "TuSDK2DTextFilterWrap.h"

// API

#import "TuSDKGIFImageEncoder.h"
#import "TuSDKGIFImage.h"

#import "TuSDKAssetVideoComposer.h"
#import "TuSDKTSAudioMixer.h"
#import "TuSDKTSMovieMixer.h"
#import "TuSDKTSMovieSplicer.h"
#import "TuSDKMovieClipper.h"
#import "TuSDKTSAudioRecorder.h"
#import "TuSDKTSMovieCompresser.h"
#import "TuSDKVideoImageExtractor.h"

#import "TuSDKMediaAssetInfo.h"
#import "TuSDKMediaTimelineSlice.h"
#import "TuSDKMediaAudioRender.h"
#import "TuSDKMediaVideoRender.h"

#import "TuSDKMediaAssetExportSession.h"
#import "TuSDKMediaMovieAssetExportSession.h"
#import "TuSDKMediaMovieEditorExportSession.h"

// 音效API

#import "TuSDKAudioPitchEngine.h"
#import "TuSDKAudioResampleEngine.h"

// 音频录制API

#import "TuSDKMediaAudioRecorder.h"
#import "TuSDKMediaAssetAudioRecorder.h"


/** Video版本号 */
extern NSString * const lsqVideoVersion;

@interface TuSDKVideo : NSObject

@end
