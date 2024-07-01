import picker from '@ohos.file.picker';
import { BusinessError } from '@ohos.base';
import { LogType, YzLog } from '@youzanyun/app_web';

export class YzDocumentVIewPicker {
  static async select(): Promise<string[]> {
    return new Promise((resolve, reject) => {
      try {
        let documentSelectOptions = new picker.DocumentSelectOptions();
        let documentPicker = new picker.DocumentViewPicker();
        documentPicker.select(documentSelectOptions).then((documentSelectResult: Array<string>) => {
          YzLog.addLog(LogType.REQUEST, 'YzDocumentViewPicker.select successfully, documentSelectResult uri: ' + JSON.stringify(documentSelectResult))
          resolve(documentSelectResult)
        }).catch((err: BusinessError) => {
          YzLog.addLog(LogType.REQUEST, 'YzDocumentViewPicker.select failed with err: ' + JSON.stringify(err))
          reject(err)
        })
      } catch (error) {
        let err: BusinessError = error as BusinessError
        YzLog.addLog(LogType.REQUEST, 'YzDocumentViewPicker failed with err: ' + JSON.stringify(err))
        reject(err)
      }
    })
  }
}

export class YzPhotoViewPicker {
  static async select(isImage: boolean): Promise<string[]> {
    return new Promise((resolve, reject) => {
      let photoSelectOptions = new picker.PhotoSelectOptions();
      let photoPicker = new picker.PhotoViewPicker();
      // 过滤选择媒体文件类型为IMAGE
      photoSelectOptions.MIMEType = isImage ? picker.PhotoViewMIMETypes.IMAGE_TYPE: picker.PhotoViewMIMETypes.VIDEO_TYPE;
      // 设置最大选择数量
      photoSelectOptions.maxSelectNumber = 6;
      photoPicker.select(photoSelectOptions).then((result: picker.PhotoSelectResult) => {
        YzLog.addLog(LogType.REQUEST, 'YzPhotoViewPicker.select failed with err: ' + JSON.stringify(result.photoUris))
        resolve(result.photoUris)
      }).catch((err: BusinessError) => {
        YzLog.addLog(LogType.REQUEST, 'YzPhotoViewPicker.select failed with err: ' + JSON.stringify(err))
        reject(err)
      })
    })
  }
}