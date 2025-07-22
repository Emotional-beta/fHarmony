import { preferences, relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import axios, { AxiosError, AxiosResponse } from '@ohos/axios';


interface IEEE {
  ieee:string
}
@Entry
@Component

struct DbPage {

  @State rname: string = 'N/A';
  @State battery: string = 'N/A';
  @State rssi: string = 'N/A';
  @State value: string = 'N/A';
  @State updateTime: string = 'N/A';


  build() {
    Column({space:20}){
      //短连接：在一个业务中（函数） 连接=>CRUD =>关闭连接 存在周期最短
      //长连接：APP启动（连接 从来不关闭）=>在一个业务中（函数）CRUD（多次） =>APP退出（关闭连接）
      //连接池（Web开发）
      //一个库对应一个数据库文件（.db）
      //如果库不存在，创建并 连接（返回数据库对象）
      //如果库存在，连接
      Button('更新当前设备信息')
        .width('61.8%')
        .onClick(()=>{
          let url = 'http://192.168.100.1/api/room/allDevAndProcess';
          let pref=preferences.getPreferencesSync(getContext(),{name:'zbox.xml'});
          let cookie = pref.getSync('cookie','') as string;
          // 省略4个参数 获取所有设备信息
          //传入IEEE 获取指定设备信息
          axios.post(url, {ieee:'5c0272fffe8576cb'} as IEEE,{timeout:1000,headers:{'Content-Type':'application/json','cookie':cookie}})
            .then((resp:AxiosResponse)=>{
              console.log(JSON.stringify(resp));
              this.getUIContext().getPromptAction().showToast({ message: JSON.stringify(resp.data.data.deviceInfos.envs.rname) })
              //this.rname=resp.data.data.deviceInfos.envs.rname;
              //this.battery=resp.data.data.deviceInfos.envs.battery;
              //this.rssi=resp.data.data.deviceInfos.envs.rssi;
              //this.value=resp.data.data.deviceInfos.envs.properties.value;
              //this.updateTime=resp.data.data.deviceInfos.envs.updateTime;
              //Text('设备名称：'+this.rname);
              //Text('电量：'+this.battery);
              //Text('信号强度：'+this.rssi+'dBm');
              //Text('活动状态：'+this.value);
              //Text('更新时间：'+this.updateTime);
            })
            .catch((err:AxiosError)=>{
              this.getUIContext().getPromptAction().showToast({ message: err.message })
            })
        })
    }
    .height('100%')
    .width('100%')
  }
}