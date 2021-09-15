
#import "SYDCentralFactory.h"

@interface SYDCentralFactory (SYDService)

- (id _Nullable) getSYDServiceBean:(const NSString * _Nonnull) serviceKey;

@end