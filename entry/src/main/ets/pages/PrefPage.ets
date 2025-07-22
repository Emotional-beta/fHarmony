import { preferences } from '@kit.ArkData';

@Entry
@Component
struct PrefPage {
  @State message: string = '';

  build() {
    Column({space:10}){
      TextInput({placeholder:'请输入',text:$$this.message})//$$ UI=>变量
        .width('80%')
      Button('保存')
        .width('49.44%')
        .onClick(()=>{
          //Sync:使用同步的方法获取首选项对象（等待当前方法执行完毕）
            let pref = preferences.getPreferencesSync(getContext(),{name:'abc.xml'});
            //存值
          pref.putSync('1000',this.message);
          //强制写（清空缓存）
          pref.flushSync();

          this.getUIContext().getPromptAction().showToast({message:'保存成功'});
        })
      Button('读取')
        .width('49.44%')
        .onClick(()=>{
          let pref = preferences.getPreferencesSync(getContext(),{name:'abc.xml'});
          //参数1 KEY 参数2 当KEY对应的值在文件中不存在的情况，返回参数2（默认值）
          let msg = pref.getSync('1000','') as string;

          this.getUIContext().getPromptAction().showToast({message:msg});
        })
      Button('删除')
        .width('49.44%')
        .onClick(()=>{
          let pref = preferences.getPreferencesSync(getContext(),{name:'abc.xml'});
          pref.deleteSync('1000');//clear删除文件全部内容 delete按键值删除
          this.getUIContext().getPromptAction().showToast({message:'删除成功'});
        })
    }
    .height('100%')
    .width('100%')
  }
}