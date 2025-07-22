import { preferences } from '@kit.ArkData';
import axios, { AxiosError, AxiosResponse } from '@ohos/axios';

// 定义数据类型接口
interface Property {
  name: string;
  id: string;
  value: string;
  display_index: string;
  update_datetime: string;
  keyValue?: string;
}

interface ParentInfo {
  type: string;
  ieee: string;
  dispName: string;
}

interface DeviceInfo {
  rname: string;
  deviceName: string;
  out_of_date: boolean;
  id: string;
  ieee: string;
  shortIeee: string;
  roomid: string;
  terminalDefId: string;
  description: string;
  battery: string;
  rssi: string;
  updateTime: string;
  valid: string;
  cid: string;
  parentInfo: ParentInfo;
  maintype: string;
  subtype: string;
  status?: string;
  power?: string;
  properties?: Property[];
  devOrder: string;
  devCommonOrder: string;
}

interface ProcessInfo {
  processId: string;
  status: string;
  title: string;
  mode: string;
  modeEn: string;
  alias: string;
  processOrder: string;
  processCommonOrder: string;
  syncStatus: string;
  tabId: string;
  tabName: string | null;
  roomid: string;
  roomname: string;
  cid: string;
  dispOrder: string;
}

interface DeviceInfos {
  socks: DeviceInfo[];
  envs: DeviceInfo[];
}

interface ResponseData {
  processInfos: ProcessInfo[];
  deviceInfos: DeviceInfos;
  groupInfos: string[]; // 根据实际情况定义
}

interface ApiResponse {
  code: string;
  data: ResponseData;
}
class DataProcessor {
  // 解析JSON数据
  static parseData(jsonString: string): ApiResponse {
    return JSON.parse(jsonString) as ApiResponse;
  }

  // 获取所有设备名称
  static getAllDeviceNames(data: ApiResponse): string[] {
    const names: string[] = [];
    data.data.deviceInfos.socks.forEach(device => names.push(device.rname));
    data.data.deviceInfos.envs.forEach(device => names.push(device.rname));
    return names;
  }

}
@Entry
@Component
struct MainPage {
  aboutToAppear():void{
      let url = 'http://192.168.100.1/api/room/allDevAndProcess';
      let pref=preferences.getPreferencesSync(getContext(),{name:'zbox.xml'});
      let cookie = pref.getSync('cookie','') as string;
      // 省略4个参数 获取所有设备信息
      //传入IEEE 获取指定设备信息
      axios.post(url,null,{timeout:1000,headers:{'Content-Type':'application/json','cookie':cookie}})
        .then((resp:AxiosResponse)=>{
          console.log(JSON.stringify(resp));
        })
        .catch((err:AxiosError)=>{
          this.getUIContext().getPromptAction().showToast({ message: err.message })
        })
  }
  build() {
    Tabs({barPosition:BarPosition.End}){
      TabContent(){
        Column(){
          Grid(){//栅格式布局
            //读取本地的devices.xml
            //for each：
                //根据xml里的类型来弄图片
                //根据xml里的名字来弄名字
                //右上生成‘设置’按钮
                  //1.重命名，2.删除
            //右上角button增加设备
                //手动添加设备类型（下选框）、设备名、ieee地址
                //自动扫描设备

            GridItem(){
              Column({ space: 5 }){
                Image($r('app.media.icon_main_photo_a'))
                  .width(72)
                Text('智能插座')
              }.onClick(()=>{
                //this.getUIContext().getRouter().pushUrl({url:'pages/SwitchPage'});
              })
            }
            GridItem(){
              Column({ space: 5 }){
                Image($r('app.media.icon_main_net_a'))
                  .width(72)
                Text('标准SOS')
              }.onClick(()=>{
                this.getUIContext().getRouter().pushUrl({url:'pages/SOSPage'});
              })
            }
            GridItem(){
              Column({ space: 5 }){
                Image($r('app.media.icon_main_cloud_a'))
                  .width(72)
                Text('标准人体活动传感器')
              }.onClick(()=>{
                this.getUIContext().getRouter().pushUrl({url:'pages/MSPage'});
              })
            }
            GridItem(){
              Column({ space: 5 }){
                Image($r('app.media.icon_main_download_a'))
                  .width(72)
                Text('标准水浸传感器')
              }.onClick(()=>{
                this.getUIContext().getRouter().pushUrl({url:'pages/NetPage'});
              })
            }
            GridItem(){
              Column({ space: 5 }){
                Image($r('app.media.icon_main_data_a'))
                  .width(72)
                Text('标准温湿度传感器')
              }.onClick(()=>{
                this.getUIContext().getRouter().pushUrl({url:'pages/NetPage'});
              })
            }
            GridItem(){
              Column({ space: 5 }){
                Image($r('app.media.icon_main_scene_a'))
                  .width(72)
                Text('标准门磁传感器')
              }.onClick(()=>{
                this.getUIContext().getRouter().pushUrl({url:'pages/NetPage'});
              })
            }
            GridItem(){
              Column({ space: 5 }){
                Image($r('app.media.icon_main_scene_a'))
                  .width(72)
                Text('增加新的设备')
              }
              .onClick(()=>{
                this.getUIContext().getPromptAction().showToast({ message: '等待开发' })
              })
            }
          }
          .height('100%')
          .width('100%')
          .padding({left:18,right:18})//内边距
          .columnsTemplate('1fr 1fr')
          .columnsGap(20) //列间距
          .rowsGap(10) //行间距

        }
      }
      .tabBar('设备')

      TabContent(){
        Text('各个房间').fontSize(20)
      }
      .tabBar('房间')

      TabContent(){
        Text('扩展内容').fontSize(20)
      }
      .tabBar('发现')

      TabContent(){
        Text('各个场景').fontSize(20)
      }
      .tabBar('场景')

      TabContent(){

      }
      .tabBar('我的')
    }
  }

}