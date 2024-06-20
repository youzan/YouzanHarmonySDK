import AbilityStage from '@ohos.app.ability.AbilityStage';
import type Want from '@ohos.app.ability.Want';
import { YzLog } from '@youzan/app_web/Index';
import { AbilityConstant } from '@kit.AbilityKit';

export default class MyAbilityStage extends AbilityStage {
  onCreate(): void {
    // 应用的HAP在首次加载的时，为该Module初始化操作
    YzLog.print("MyAbilityStage oncreate")
  }

  onAcceptWant(want: Want): string {
    return super.onAcceptWant(want);
  }

  onMemoryLevel(level: AbilityConstant.MemoryLevel): void {
    super.onMemoryLevel(level);
  }
}