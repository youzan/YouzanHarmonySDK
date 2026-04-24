import bundleManager from '@ohos.bundle.bundleManager';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import { LogType, YzLog } from '@youzanyun/app_web';

// 允许应用获取设备模糊位置信息
const PERMISSION_APPROXIMATELY_LOCATION = 'ohos.permission.APPROXIMATELY_LOCATION'
// 允许应用获取设备位置信息
const PERMISSION_LOCATION = 'ohos.permission.LOCATION'
// 允许应用读取用户外部存储中的媒体文件信息
const PERMISSION_READ_MEDIA = 'ohos.permission.READ_MEDIA'
// 允许应用使用相机
const PERMISSION_CAMERA = 'ohos.permission.CAMERA'
const LOCATION_PERMISSIONS: Permissions[] = [PERMISSION_APPROXIMATELY_LOCATION, PERMISSION_LOCATION]

export class YzPermissionsManager {
  static async checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

    // 获取应用程序的accessTokenID
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;

    } catch (error) {
      const err: BusinessError = error as BusinessError;
      YzLog.addLog(LogType.DEFAULT, `Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }

    // 校验应用是否被授予权限
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      YzLog.addLog(LogType.DEFAULT, `Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }

    return grantStatus;
  }

  // 检查位置授权情况
  static async checkLocationPermission(): Promise<boolean> {
    const grantStatusList = await Promise.all(LOCATION_PERMISSIONS.map((permission: Permissions) => {
      return YzPermissionsManager.checkAccessToken(permission);
    }))
    return grantStatusList.some((grantStatus: abilityAccessCtrl.GrantStatus) => {
      return grantStatus == abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
    })
  }

  // 检查读取用户外部存储中的媒体文件信息授权情况
  static async checkReadMediaPermission(): Promise<boolean> {
    return new Promise((resolve, reject) => {
      YzPermissionsManager.checkAccessToken(PERMISSION_READ_MEDIA).then((ret: abilityAccessCtrl.GrantStatus) => {
        resolve(ret == abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
      }).catch((err: BusinessError) => {
        reject(err)
      })
    })
  }

  // 检查相机授权情况
  static async checkCameraPermission(): Promise<boolean> {
    return new Promise((resolve, reject) => {
      YzPermissionsManager.checkAccessToken(PERMISSION_CAMERA).then((ret: abilityAccessCtrl.GrantStatus) => {
        resolve(ret == abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
      }).catch((err: BusinessError) => {
        reject(err)
      })
    })
  }

  static async requestPermissions(permissions: Permissions[], component?: Object): Promise<boolean> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    // 使用UIExtensionAbility：将common.UIAbilityContext 替换为common.UIExtensionContext
    let context: Context = getContext(component) as common.UIAbilityContext;

    try {
      const data = await atManager.requestPermissionsFromUser(context, permissions);
      YzLog.addLog(LogType.DEFAULT, 'data:' + JSON.stringify(data));
      YzLog.addLog(LogType.DEFAULT, 'data permissions:' + data.permissions);
      YzLog.addLog(LogType.DEFAULT, 'data authResults:' + data.authResults);

      return data.authResults.some((authResult: number) => authResult == 0)
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      YzLog.addLog(LogType.DEFAULT, `requestPermissionsFromUser fail, err->${JSON.stringify(err)}`);
    }

    return false
  }

  static async requestPermission(permission: Permissions, component?: Object): Promise<boolean> {
    return YzPermissionsManager.requestPermissions([permission], component)
  }

  static async requestLocationPermission(component?: Object): Promise<boolean> {
    if (await YzPermissionsManager.checkLocationPermission()) {
      return true
    }
    return YzPermissionsManager.requestPermissions(LOCATION_PERMISSIONS, component)
  }

  static async requestReadMediaPermission(component?: Object): Promise<boolean> {
    return new Promise((resolve, reject) => {
      YzPermissionsManager.requestPermission(PERMISSION_READ_MEDIA, component).then((ret: boolean) => {
        resolve(ret)
      }).catch((err: BusinessError) => {
        reject(err)
      })
    })
  }

  static async requestCameraPermission(component?: Object): Promise<boolean> {
    return new Promise((resolve, reject) => {
      YzPermissionsManager.requestPermission(PERMISSION_CAMERA, component).then((ret: boolean) => {
        resolve(ret)
      }).catch((err: BusinessError) => {
        reject(err)
      })
    })
  }
}

export { PERMISSION_APPROXIMATELY_LOCATION, PERMISSION_LOCATION, PERMISSION_READ_MEDIA, PERMISSION_CAMERA }
