#if defined(YI_IOS) || defined(YI_TVOS)

#import "AppDelegate.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import <Bugsnag/Bugsnag.h>

#define LOG_TAG "AppDelegate"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions {
#if defined(YI_IOS)
    [Bugsnag startBugsnagWithApiKey:@"ec866230dd7116c94845586bafc31326"];
#elif defined(YI_TVOS)
    [Bugsnag startBugsnagWithApiKey:@"adb5ee13b5816cfad337cfee6bd13e1a"];
#endif

    [Bugsnag notifyError:[NSError errorWithDomain:@"tv.youi" code:408 userInfo:nil]];

    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end

#endif
