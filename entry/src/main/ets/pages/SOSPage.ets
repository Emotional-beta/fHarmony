import axios, { AxiosError, AxiosResponse } from '@ohos/axios';
import { preferences } from '@kit.ArkData';
import promptAction from '@ohos.promptAction';

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
@Entry
@Component
struct SOSPage {
  @State message: string = 'Hello World';
  @State historyList: HistoryItem[] = [];
  @State isLoading: boolean = false;

  getSOSHistory() {
    let url = 'http://192.168.100.1/api/terminal/history/get';
    try {
      let pref=preferences.getPreferencesSync(getContext(),{name:'zbox.xml'});
      let cookie = pref.getSync('cookie', '').toString();
      let ieee = 'cc86ecfffe5ac492';
      let terminalDefId = '10516';

      axios.post(
        url,
        { ieee: ieee, terminalDefId: terminalDefId } as HistoryRequest,
        {
          timeout: 1000,
          headers: {
            "Content-Type": 'application/json',
            'cookie': cookie
          }
        }
      )
        .then((resp: AxiosResponse<HistoryResponse>) => {
          console.log('SOS历史信息请求成功: ' + JSON.stringify(resp.data));
          if (resp.data.code === '0000000') {
            this.historyList = resp.data.data;
            promptAction.showToast({ message: `获取成功，共${resp.data.data.length}条记录` });
          } else {
            promptAction.showToast({ message: '获取数据失败: 接口返回错误' });
          }
          this.isLoading = false;
        })
        .catch((err: AxiosError) => {
          let errorMsg = '请求失败: ';
          if (err.response) {
            errorMsg += `状态码: ${err.response.status}, 信息: ${err.message}`;
          } else {
            errorMsg += err.message || '未知错误';
          }
          console.error(errorMsg);
          promptAction.showToast({ message: errorMsg });
          this.isLoading = false;
        })
    } catch (innerErr) {
      let errorMsg = `获取配置失败: ${JSON.stringify(innerErr)}`;
      console.error(errorMsg);
      promptAction.showToast({ message: errorMsg });
    }
  }

  build() {
    Column() {
      Button('查看SOS历史信息')
        .onClick(() => {
          this.isLoading = true;
          this.getSOSHistory();
        })

      // 加载状态显示
      if (this.isLoading) {
        Progress({ value: 0, total: 100 })
          .width('80%')
          .margin(10)
      }

      // 数据列表展示
      if (this.historyList.length > 0) {
        List() {
          ForEach(this.historyList, (item: HistoryItem) => {
            ListItem() {
              Column() {
                Row() {
                  Text(`时间: ${item.update_datetime}`)
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                }
                .width('100%')

                Row() {
                  Text(`状态: ${item.value === '1' ? '触发SOS' : '正常'}`)
                    .fontSize(12)
                    .fontColor(item.value === '1' ? Color.Red : Color.Green)
                  Text(`已过去: ${item.past}秒`)
                    .fontSize(12)
                }
                .width('100%')
              }
              .padding(10)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .margin(5)
            }
          }, (item: HistoryItem) => item.update_datetime + item.time)
        }
        .width('90%')
        .height('70%')
      } else if (!this.isLoading && this.historyList.length === 0) {
        Text('暂无历史数据')
          .fontSize(14)
          .margin(20)
      }
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .padding(10)
  }
}
