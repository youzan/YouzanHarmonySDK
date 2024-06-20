import bundleManager from '@ohos.bundle.bundleManager';
import abilityAccessCtrl, { Permissions, PermissionRequestResult } from '@ohos.abilityAccessCtrl';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import { LogType, YzLog } from '../../../../../yzweb/src/main/ets/utils/YzLog'

// 允许应用获取设备模糊位置信息
const PERMISSION_APPROXIMATELY_LOCATION = 'ohos.permission.APPROXIMATELY_LOCATION'
// 允许应用获取设备位置信息
const PERMISSION_LOCATION = 'ohos.permission.LOCATION'
// 允许应用读取用户外部存储中的媒体文件信息
const PERMISSION_READ_MEDIA = 'ohos.permission.READ_MEDIA'
// 允许应用使用相机
const PERMISSION_CAMERA = 'ohos.permission.CAMERA'

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
    return new Promise((resolve, reject) => {
      YzPermissionsManager.checkAccessToken(PERMISSION_APPROXIMATELY_LOCATION).then((ret: abilityAccessCtrl.GrantStatus) => {
        YzPermissionsManager.checkAccessToken(PERMISSION_LOCATION).then((ret: abilityAccessCtrl.GrantStatus) => {
          resolve(ret == abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
        }).catch((err: BusinessError) => {
          reject(err)
        })
      }).catch((err: BusinessError) => {
        reject(err)
      })
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

  static async requestPermission(permission: Permissions, component?: Object): Promise<boolean> {
    return new Promise((resolve, reject) => {
      let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
      // 使用UIExtensionAbility：将common.UIAbilityContext 替换为common.UIExtensionContext
      let context: Context = getContext(component) as common.UIAbilityContext;
      try {
        atManager.requestPermissionsFromUser(context, [permission], (err: BusinessError, data: PermissionRequestResult)=>{
          if (err) {
            reject(err)
            YzLog.addLog(LogType.DEFAULT, `requestPermissionsFromUser fail, err->${JSON.stringify(err)}`);
          } else {

            YzLog.addLog(LogType.DEFAULT, 'data:' + JSON.stringify(data));
            YzLog.addLog(LogType.DEFAULT, 'data permissions:' + data.permissions);
            YzLog.addLog(LogType.DEFAULT, 'data authResults:' + data.authResults);

            if (data.authResults.length >= 1) {
              // 用户授权，可以继续访问目标操作
              resolve(data.authResults[0] == 0)
            } else {
              // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
              resolve(false)
            }
          }
        })
      } catch (err) {
        reject(err)
      }
    })
  }

  static async requestLocationPermission(component?: Object): Promise<boolean> {
    return new Promise((resolve, reject) => {
      YzPermissionsManager.requestPermission(PERMISSION_APPROXIMATELY_LOCATION, component).then((ret: boolean) => {
        if (ret) {
          YzPermissionsManager.requestPermission(PERMISSION_LOCATION, component).then((ret: boolean) => {
            resolve(ret)
          }).catch((err: BusinessError) => {
            reject(err)
          })
        } else {
          resolve(false)
        }
      }).catch((err: BusinessError) => {
        reject(err)
      })
    })
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