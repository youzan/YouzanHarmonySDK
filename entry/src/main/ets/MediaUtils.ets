import photoAccessHelper from '@ohos.file.photoAccessHelper';
import fs from '@ohos.file.fs';
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { YzLog } from '@youzanyun/app_web/Index';
import Url from '@ohos.url'

export class MediaUtils {
  static async saveToAlbum(context: common.UIAbilityContext, url: string) {
    YzLog.print(`图片地: ${url}`)
    url = url.replace("!large.webp", "")
    http.createHttp()
      .request(url || 'https://img01.yzcdn.cn/upload_files/2024/06/11/FpvGjOWpeYGT8l-ZSOp7lO1jsUNw.png',
        (error: BusinessError, data: http.HttpResponse) => {
          if (error) {
            promptAction.showToast({
              message: '保存图片失败',
              duration: 2000
            })
            return
          }
          if (data.result instanceof ArrayBuffer) {
            MediaUtils.saveImage(context, data.result as ArrayBuffer).then(()=> {
              promptAction.showToast({
                message: '保存图片成功',
                duration: 2000
              })
            }).catch(() => {
              promptAction.showToast({
                message: '保存图片失败',
                duration: 2000
              })
            })
          }
        })

  }


  static async saveImage(context: common.UIAbilityContext, buffer: ArrayBuffer | string): Promise<void> {
    let helper = photoAccessHelper.getPhotoAccessHelper(context);
    let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg');
    let file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    await fs.write(file.fd, buffer);
    await fs.close(file.fd);
  }
}