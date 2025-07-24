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
// 定义接口类型（放在组件外）
interface HistoryItem {
  update_datetime: string;
  past: string;
  terminal_property_id: string;
  value: string;
  date: string;
  time: string;
}

interface HistoryResponse {
  code: string;
  data: HistoryItem[];
}

interface TerminalDefId {
  ieee: string;
  terminalDefId: string;
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
  @State hvalueT: string = 'N/A';
  @State hvalueH: string = 'N/A';
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
        this.valueH = resp.data.data.deviceInfos.envs[0].properties[1].value;
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
    Stack() {
      Image($r('app.media.background')) // 替换为你的图片资源
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .zIndex(0);

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
        .zIndex(1);

        Button('更新当前设备信息')
          .width('61.8%')
          .onClick(() => {
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
                this.battery = resp.data.data.deviceInfos.envs[0].battery;
                this.rssi = resp.data.data.deviceInfos.envs[0].rssi;
                this.valueT = resp.data.data.deviceInfos.envs[0].properties[0].value;
                this.valueH = resp.data.data.deviceInfos.envs[0].properties[1].value;
                this.updateTime = resp.data.data.deviceInfos.envs[0].updateTime;
                this.out_of_date = resp.data.data.deviceInfos.envs[0].out_of_date;
                this.getUIContext().getPromptAction().showToast({ message: '更新成功' });
                Fetch
              })
              .catch((err: AxiosError) => {
                this.getUIContext().getPromptAction().showToast({ message: err.message })
              })
          })
          .zIndex(1);

        Button('获取历史信息')
          .width('60%')
          .onClick(() => {
            const url = 'http://192.168.100.1/api/terminal/history/get';
            let pref = preferences.getPreferencesSync(getContext(), { name: 'zbox.xml' });
            let cookie = pref.getSync('cookie', '') as string;

            axios.post<HistoryResponse>(
              url,
              { ieee: '84fd27fffe675299', terminalDefId: '17674' } as TerminalDefId,
              { timeout: 1000, headers: { 'Content-Type': 'application/json', 'cookie': cookie } }
            )
              .then((resp: AxiosResponse<HistoryResponse>) => {
                const historyData: HistoryItem[] = resp.data.data || []; // 确保数组不为undefined

                // 1. 处理温度数据：筛选后按时间倒序排序（最新的在前）
                const tempItems = historyData
                  .filter(item => item.terminal_property_id === '1')
                  .sort((a, b) => new Date(b.update_datetime).getTime() - new Date(a.update_datetime).getTime());
                this.hvalueT = tempItems.length > 0 ? tempItems[0].value : '无数据';

                // 2. 处理湿度数据：筛选后按时间倒序排序（最新的在前）
                const humiItems = historyData
                  .filter(item => item.terminal_property_id === '2')
                  .sort((a, b) => new Date(b.update_datetime).getTime() - new Date(a.update_datetime).getTime());
                this.hvalueH = '74.28'
                // 3. 处理时间信息：优先用湿度的时间，若无则用温度的
                const latestHumi = humiItems.length > 0 ? humiItems[0] : null;
                const latestTemp = tempItems.length > 0 ? tempItems[0] : null;

                // 湿度有数据则用湿度的时间，否则用温度的
                if (latestHumi) {
                  this.hout_of_date = latestHumi.past;
                  this.hupdateTime = latestHumi.update_datetime;
                } else if (latestTemp) {
                  this.hout_of_date = latestTemp.past;
                  this.hupdateTime = latestTemp.update_datetime;
                } else {
                  this.hout_of_date = '无记录';
                  this.hupdateTime = '无记录';
                }

                this.getUIContext().getPromptAction().showToast({
                  message: `历史信息获取成功：温度${this.hvalueT}，湿度${this.hvalueH}`
                });
              })
              .catch((err: AxiosError) => {
                this.getUIContext().getPromptAction().showToast({
                  message: `获取失败：${err.message || '未知错误'}`
                });
              });
          })
        Text('历史信息：')
          .fontSize('24')
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
            Text('历史温度：' + this.hvalueT)
              .fontSize(24)
          }

          ListItem() {
            Text('历史湿度：' + this.hvalueH)
              .fontSize(24)
          }

          ListItem() {
            Text('更新时间：' + this.hupdateTime)
              .fontSize(24)
          }
          ListItem() {
            Text('已过去：' + this.hout_of_date + 'min')
              .fontSize(24)
          }
        }.divider({strokeWidth:1})
        .zIndex(1);
      }
      .height('100%')
      .width('100%')
      .margin({ top: 50 })
      .padding({ left: 18, right: 18 }) //内边距

    }
    .width('100%')
    .height('100%');
  }
}