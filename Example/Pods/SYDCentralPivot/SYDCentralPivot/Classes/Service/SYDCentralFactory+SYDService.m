#import "SYDCentralFactory+SYDService.h"

@implementation SYDCentralFactory (SYDService)

- (id) getSYDServiceBean:(const NSString *) serviceKey{
   id serviceBean = [self getCommonBean:serviceKey];
   return serviceBean;
    
}

@end
