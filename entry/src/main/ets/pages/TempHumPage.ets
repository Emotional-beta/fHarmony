import { preferences, relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import axios, { AxiosError, AxiosResponse } from '@ohos/axios';
import Fetch from '@system.fetch';


interface IEEE {
  ieee:string
}
interface terminalDefId{
  ieee:string
  terminalDefId:string
}
@Entry
@Component
@Preview

struct TempHumPage {
  @State rname: string = 'N/A';
  @State battery: string = 'N/A';
  @State rssi: string = 'N/A';
  @State valueT: string = 'N/A';
  @State valueH: string = 'N/A';
  @State updateTime: string = 'N/A';
  @State out_of_date: string = 'N/A';
  @State hrname: string = 'N/A';
  @State hbattery: string = 'N/A';
  @State hrssi: string = 'N/A';
  @State hvalue: string = 'N/A';
  @State hupdateTime: string = 'N/A';
  @State hout_of_date: string = 'N/A';

  aboutToAppear(): void {
    let url = 'http://192.168.100.1/api/room/allDevAndProcess';
    let pref = preferences.getPreferencesSync(getContext(), { name: 'zbox.xml' });
    let cookie = pref.getSync('cookie', '') as string;
    // 省略4个参数 获取所有设备信息
    //传入IEEE 获取指定设备信息
    axios.post(url, { ieee: '84fd27fffe675299' } as IEEE,
      { timeout: 1000, headers: { 'Content-Type': 'application/json', 'cookie': cookie } })
      .then((resp: AxiosResponse) => {
        console.log(JSON.stringify(resp));
        this.rname = resp.data.data.deviceInfos.envs[0].rname;
        //this.getUIContext().getPromptAction().showToast({ message: JSON.stringify(resp)});
        this.rname = resp.data.data.deviceInfos.envs[0].rname;
        this.battery = resp.data.data.deviceInfos.envs[0].battery;
        this.rssi = resp.data.data.deviceInfos.envs[0].rssi;
        this.valueT = resp.data.data.deviceInfos.envs[0].properties[0].value;
        this.updateTime = resp.data.data.deviceInfos.envs[0].updateTime;
        this.out_of_date = resp.data.data.deviceInfos.envs[0].out_of_date;
        this.getUIContext().getPromptAction().showToast({ message: '更新成功' });
        Fetch
      })
      .catch((err: AxiosError) => {
        this.getUIContext().getPromptAction().showToast({ message: err.message })
      })
  }

  build() {
    Column({ space: 20 }) {
      List() {
        //参数1 循环对象 参数2 循环体 e表示数组中每一个元素

        ListItem() {
          Text('设备名称：' + this.rname)
            .fontSize(24)
        }

        ListItem() {
          Text('在线状态：' + this.out_of_date)
            .fontSize(24)
        }

        ListItem() {
          Text('电量：' + this.battery + '%')
            .fontSize(24)
        }

        ListItem() {
          Text('信号强度：' + this.rssi + 'dBm')
            .fontSize(24)
        }

        ListItem() {
          Text('当前温度：' + this.valueT)
            .fontSize(24)
        }

        ListItem() {
          Text('当前湿度：' + this.valueH)
            .fontSize(24)
        }

        ListItem() {
          Text('更新时间：' + this.updateTime)
            .fontSize(24)
        }
      }.divider({ strokeWidth: 1 })

      Button('更新当前设备信息')
        .width('61.8%')
        .onClick(() => {
          let url = 'http://192.168.100.1/api/room/allDevAndProcess';
          let pref = preferences.getPreferencesSync(getContext(), { name: 'zbox.xml' });
          let cookie = pref.getSync('cookie', '') as string;
          // 省略4个参数 获取所有设备信息
          //传入IEEE 获取指定设备信息
          axios.post(url, { ieee: '5c0272fffe8576cb' } as IEEE,
            { timeout: 1000, headers: { 'Content-Type': 'application/json', 'cookie': cookie } })
            .then((resp: AxiosResponse) => {
              console.log(JSON.stringify(resp));
              this.rname = resp.data.deviceInfos.envs[0].rname;
              this.battery = resp.data.deviceInfos.envs[0].battery;
              this.rssi = resp.data.deviceInfos.envs[0].rssi;
              this.valueT = resp.data.deviceInfos.envs[0].properties[0].value;
              this.updateTime = resp.data.deviceInfos.envs[0].updateTime;
              this.out_of_date = resp.data.deviceInfos.envs[0].out_of_date;
              this.getUIContext().getPromptAction().showToast({ message: '更新成功' });
              Fetch
            })
            .catch((err: AxiosError) => {
              this.getUIContext().getPromptAction().showToast({ message: err.message })
            })
        })
    }
    .height('100%')
    .width('100%')
    .margin({ top: 50 })
    .padding({ left: 18, right: 18 }) //内边距

  }
}