import axios, { AxiosError, AxiosResponse } from '@ohos/axios';
import { preferences } from '@kit.ArkData';
import promptAction from '@ohos.promptAction';


// --------------- 紧急呼叫相关类型定义 ---------------
interface EmergencyCallRequest {
  ieee: string; // 设备标识，复用现有设备IEEE
  reason?: string; // 可选：紧急原因描述
}

interface EmergencyCallResponse {
  code: string; // 状态码，0000000表示成功
  message: string; // 响应信息
}


// --------------- 原有类型定义 ---------------
interface HistoryRequest {
  ieee: string;
  terminalDefId: string;
}

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

interface DeviceProperty {
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
  properties?: DeviceProperty[];
  devOrder: string;
  devCommonOrder: string;
}

interface DeviceInfos {
  socks: DeviceInfo[];
  envs: DeviceInfo[];
}

interface DeviceResponseData {
  processInfos: DeviceInfo[];
  deviceInfos: DeviceInfos;
  groupInfos: DeviceInfo[];
}

interface DeviceResponse {
  code: string;
  data: DeviceResponseData;
}

interface SOSDeviceState {
  battery: string;
  rssi: string;
  alarmStatus: string;
  updateDatetime: string;
}


// --------------- 组件定义 ---------------
@Entry
@Component
struct SOSPage {
  @State message: string = 'Hello World';
  @State historyList: HistoryItem[] = [];
  @State isLoading: boolean = false;
  @State sosInfo: SOSDeviceState = {
    battery: '未知',
    rssi: '未知',
    alarmStatus: '未知',
    updateDatetime: '无数据'
  };
  @State isCalling: boolean = false; // 紧急呼叫加载状态
  private deviceIeee: string = 'cc86ecfffe5ac492'; // 设备IEEE标识
  private refreshTimer: number = -1; // 定时器ID


  // 生命周期：页面显示时启动定时器
  onPageShow() {
    // 立即刷新一次
    this.refreshAllData();

    // 启动定时器，每5秒刷新一次
    this.refreshTimer = setInterval(() => {
      this.refreshAllData();
    }, 10000);
  }

  // 生命周期：页面隐藏时清除定时器
  onPageHide() {
    if (this.refreshTimer !== -1) {
      clearInterval(this.refreshTimer);
      this.refreshTimer = -1;
    }
  }

  // 统一刷新数据方法
  private refreshAllData() {
    // 显示刷新提示
    promptAction.showToast({
      message: '正在刷新SOS信息...',
      duration: 1000
    });

    // 刷新设备信息和历史记录
    this.getDeviceInfo();
    this.getSOSHistory();
  }


  // 获取设备信息
  getDeviceInfo() {
    const url = 'http://192.168.100.1/api/room/allDevAndProcess';
    this.isLoading = true;

    try {
      const pref = preferences.getPreferencesSync(getContext(), { name: 'zbox.xml' });
      const cookie: string = pref.getSync('cookie', '').toString();

      axios.get<DeviceResponse>(
        url,
        {
          timeout: 10000,
          headers: {
            'Content-Type': 'application/json',
            'cookie': cookie
          }
        }
      )
        .then((resp: AxiosResponse<DeviceResponse>) => {
          console.log('设备信息请求成功: ' + JSON.stringify(resp.data));
          if (resp.data.code === '0000000') {
            const sosDevice: DeviceInfo | undefined = resp.data.data.deviceInfos.envs.find(
              (device: DeviceInfo) => device.maintype === 'sos' && device.deviceName === '标准SOS'
            );

            if (sosDevice) {
              this.sosInfo.battery = `${sosDevice.battery}%`;
              this.sosInfo.rssi = `${sosDevice.rssi}dBm`;

              const alarmProp: DeviceProperty | undefined = sosDevice.properties?.find(
                (prop: DeviceProperty) => prop.name === 'SOS报警状态'
              );
              if (alarmProp) {
                this.sosInfo.alarmStatus = alarmProp.value;
                this.sosInfo.updateDatetime = alarmProp.update_datetime;
              }
            } else {
              promptAction.showToast({ message: '未找到标准SOS设备' });
            }
          } else {
            promptAction.showToast({ message: '获取设备数据失败: 接口返回错误' });
          }
          this.isLoading = false;
        })
        .catch((err: AxiosError) => {
          let errorMsg = '设备信息请求失败: ';
          if (err.response) {
            errorMsg += `状态码: ${err.response.status}, 信息: ${err.message}`;
          } else {
            errorMsg += err.message || '未知错误';
          }
          console.error(errorMsg);
          promptAction.showToast({ message: errorMsg });
          this.isLoading = false;
        });
    } catch (innerErr) {
      const errorMsg = `获取配置失败: ${JSON.stringify(innerErr)}`;
      console.error(errorMsg);
      promptAction.showToast({ message: errorMsg });
      this.isLoading = false;
    }
  }


  // 获取历史记录
  getSOSHistory() {
    const url = 'http://192.168.100.1/api/terminal/history/get';
    this.isLoading = true;

    try {
      const pref = preferences.getPreferencesSync(getContext(), { name: 'zbox.xml' });
      const cookie: string = pref.getSync('cookie', '').toString();
      const terminalDefId = '17686';

      axios.post<HistoryResponse>(
        url,
        { ieee: this.deviceIeee, terminalDefId } as HistoryRequest,
        {
          timeout: 10000,
          headers: {
            'Content-Type': 'application/json',
            'cookie': cookie
          }
        }
      )
        .then((resp: AxiosResponse<HistoryResponse>) => {
          console.log('SOS历史信息请求成功: ' + JSON.stringify(resp.data));
          if (resp.data.code === '0000000') {
            this.historyList = resp.data.data;
          } else {
            promptAction.showToast({ message: '获取历史数据失败: 接口返回错误' });
          }
          this.isLoading = false;
        })
        .catch((err: AxiosError) => {
          let errorMsg = '历史记录请求失败: ';
          if (err.response) {
            errorMsg += `状态码: ${err.response.status}, 信息: ${err.message}`;
          } else {
            errorMsg += err.message || '未知错误';
          }
          console.error(errorMsg);
          promptAction.showToast({ message: errorMsg });
          this.isLoading = false;
        });
    } catch (innerErr) {
      const errorMsg = `获取配置失败: ${JSON.stringify(innerErr)}`;
      console.error(errorMsg);
      promptAction.showToast({ message: errorMsg });
      this.isLoading = false;
    }
  }


  // 紧急呼叫功能
  emergencyCall() {
    if (this.isCalling) return; // 防止重复点击
    this.isCalling = true;
    const url = 'http://192.168.100.1/api/emergency/call'; // 紧急呼叫后端接口

    try {
      const pref = preferences.getPreferencesSync(getContext(), { name: 'zbox.xml' });
      const cookie: string = pref.getSync('cookie', '').toString();

      // 紧急呼叫请求参数
      const requestData: EmergencyCallRequest = {
        ieee: this.deviceIeee,
        reason: '用户触发紧急呼叫' // 可选：携带呼叫原因
      };

      axios.post<EmergencyCallResponse>(
        url,
        requestData,
        {
          timeout: 15000, // 紧急请求超时时间稍长
          headers: {
            'Content-Type': 'application/json',
            'cookie': cookie
          }
        }
      )
        .then((resp: AxiosResponse<EmergencyCallResponse>) => {
          console.log('紧急呼叫请求结果: ' + JSON.stringify(resp.data));
          if (resp.data.code === '0000000') {
            promptAction.showToast({
              message: '紧急呼叫已发出，正在联系救援',
              duration: 3000 // 延长提示时间
            });
          } else {
            promptAction.showToast({
              message: `呼叫失败: ${resp.data.message || '服务器处理错误'}`,
              duration: 3000
            });
          }
          this.isCalling = false;
        })
        .catch((err: AxiosError) => {
          let errorMsg = '紧急呼叫请求失败: ';
          if (err.response) {
            errorMsg += `状态码: ${err.response.status}, 信息: ${err.message}`;
          } else {
            errorMsg += err.message || '网络异常，无法连接服务器';
          }
          console.error(errorMsg);
          promptAction.showToast({
            message: errorMsg,
            duration: 3000
          });
          this.isCalling = false;
        });
    } catch (innerErr) {
      const errorMsg = `呼叫配置错误: ${JSON.stringify(innerErr)}`;
      console.error(errorMsg);
      promptAction.showToast({
        message: errorMsg,
        duration: 3000
      });
      this.isCalling = false;
    }
  }


  build() {
    Column() {
      // 紧急呼叫按钮
      Button(this.isCalling ? '正在呼叫...' : '紧急呼叫')
        .onClick(() => this.emergencyCall())
        .backgroundColor(this.isCalling ? Color.Gray : Color.Red) // 呼叫中灰色，否则红色
        .fontColor(Color.White)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('90%')
        .height(50)
        .borderRadius(25)
        .margin({ bottom: 15 })
        .enabled(!this.isCalling); // 呼叫中禁用按钮

      // 原有功能按钮
      Button('刷新信息')
        .onClick(() => this.refreshAllData())
        .margin({ bottom: 10 })
        .enabled(!this.isLoading && !this.isCalling); // 其他操作时禁用

      // 加载状态显示
      if (this.isLoading) {
        Progress({ value: 0, total: 100 })
          .width('80%')
          .margin({ bottom: 10 });
      }
      if (this.isCalling) {
        Progress({ value: 0, total: 100})
          .width(30)
          .height(30)
          .margin({ bottom: 10 });
      }

      // 设备信息展示
      Column() {
        Text('标准SOS设备信息')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 10, top: 10 });

        List() {
          ListItem() {
            Row() {
              Text('电池电量:')
                .width('40%')
                .fontSize(14);
              Text(this.sosInfo.battery)
                .width('60%')
                .fontSize(14)
                .fontColor(this.sosInfo.battery !== '未知' ? Color.Black : Color.Gray);
            }
            .padding(5);
          }

          ListItem() {
            Row() {
              Text('信号强度:')
                .width('40%')
                .fontSize(14);
              Text(this.sosInfo.rssi)
                .width('60%')
                .fontSize(14)
                .fontColor(this.sosInfo.rssi !== '未知' ? Color.Black : Color.Gray);
            }
            .padding(5);
          }

          ListItem() {
            Row() {
              Text('报警状态:')
                .width('40%')
                .fontSize(14);
              Text(this.sosInfo.alarmStatus)
                .width('60%')
                .fontSize(14)
                .fontColor(this.sosInfo.alarmStatus === '正常' ? Color.Green : Color.Red);
            }
            .padding(5);
          }

          ListItem() {
            Row() {
              Text('最后更新时间:')
                .width('40%')
                .fontSize(14);
              Text(this.sosInfo.updateDatetime)
                .width('60%')
                .fontSize(14)
                .fontColor(this.sosInfo.updateDatetime !== '无数据' ? Color.Black : Color.Gray);
            }
            .padding(5);
          }
        }
        .width('90%')
        .backgroundColor('#F5F5F5')
        .borderRadius(10)
        .padding(10)
        .margin({ bottom: 10 });
      }

      // 历史记录展示
      if (this.historyList.length > 0) {
        Text('SOS历史记录')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 10, top: 10 });

        List() {
          ForEach(
            this.historyList,
            (item: HistoryItem) => {
              ListItem() {
                Column() {
                  Row() {
                    Text(`时间: ${item.update_datetime}`)
                      .fontSize(14)
                      .fontWeight(FontWeight.Bold);
                  }
                  .width('100%');

                  Row() {
                    Text(`状态: ${item.value === '1' ? '触发SOS' : '正常'}`)
                      .fontSize(12)
                      .fontColor(item.value === '1' ? Color.Red : Color.Green);
                    Text(`已过去: ${item.past}秒`)
                      .fontSize(12);
                  }
                  .width('100%');
                }
                .padding(10)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .margin(5);
              };
            },
            (item: HistoryItem) => `${item.update_datetime}-${item.time}`
          );
        }
        .width('90%')
        .height('40%');
      } else if (!this.isLoading && !this.isCalling && this.historyList.length === 0) {
        Text('暂无历史数据')
          .fontSize(14)
          .margin(20)
          .fontColor(Color.Gray);
      }
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .padding(10);
  }
}