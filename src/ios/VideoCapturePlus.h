#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <Cordova/CDVPlugin.h>

enum CDVCaptureError {
    CAPTURE_INTERNAL_ERR = 0,
    CAPTURE_APPLICATION_BUSY = 1,
    CAPTURE_INVALID_ARGUMENT = 2,
    CAPTURE_NO_MEDIA_FILES = 3,
    CAPTURE_NOT_SUPPORTED = 20
};
typedef NSUInteger CDVCaptureError;

@interface CDVImagePickerPlus : UIImagePickerController {
}
@property (copy)   NSString* callbackId;

@end

@interface VideoCapturePlus : CDVPlugin <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    CDVImagePickerPlus* pickerController;
    BOOL inUse;
    NSTimer* timer;
	AVCaptureSession *CaptureSession;
	AVCaptureMovieFileOutput *MovieFileOutput;
    UIImage* portraitOverlay;
    UIImage* landscapeOverlay;
}
@property BOOL inUse;
@property (nonatomic, strong) NSTimer* timer;
@property (strong, nonatomic) UILabel *overlayBox;
@property (strong, nonatomic) UILabel *stopwatchLabel;
@property (strong, nonatomic) UILabel *progressbarLabel;
- (void)captureVideo:(CDVInvokedUrlCommand*)command;
- (CDVPluginResult*)processVideo:(NSString*)moviePath forCallbackId:(NSString*)callbackId;
- (void)getFormatData:(CDVInvokedUrlCommand*)command;
- (NSDictionary*)getMediaDictionaryFromPath:(NSString*)fullPath ofType:(NSString*)type;
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info;
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingImage:(UIImage*)image editingInfo:(NSDictionary*)editingInfo;

@end