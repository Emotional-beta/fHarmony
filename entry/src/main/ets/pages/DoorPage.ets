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

struct DoorPage {

  @State rname: string = 'N/A';
  @State battery: string = 'N/A';
  @State rssi: string = 'N/A';
  @State value: string = 'N/A';
  @State updateTime: string = 'N/A';
  @State out_of_date: string = 'N/A';
  @State door_propertie_name1:string ='N/A'
  @State door_propertie_name2:string ='N/A'
  @State door_propertie_value1:string ='N/A'
  @State door_propertie_value2:string ='N/A'

  @State htime: string = 'N/A';
  @State hpast: string = 'N/A';
  @State hdate: string = 'N/A';
  @State hvalue: string = 'N/A';
  @State hupdateTime?: string = 'N/A';
  @State hout_of_date: string = 'N/A';
  index:number = 0;
  @State respdata :string[]=[];
  aboutToAppear(): void {
    let url = 'http://192.168.100.1/api/room/allDevAndProcess';
    let pref=preferences.getPreferencesSync(getContext(),{name:'zbox.xml'});
    let cookie = pref.getSync('cookie','') as string;
    // 省略4个参数 获取所有设备信息
    //传入IEEE 获取指定设备信息
    axios.post(url, {ieee:'a46dd4fffeed971a'} as IEEE,{timeout:1000,headers:{'Content-Type':'application/json','cookie':cookie}})
      .then((resp:AxiosResponse)=>{
        console.log(JSON.stringify(resp));
        this.rname=resp.data.data.deviceInfos.envs[0].rname;
        //this.getUIContext().getPromptAction().showToast({ message: JSON.stringify(resp)});
        this.battery=resp.data.data.deviceInfos.envs[0].battery;
        this.rssi=resp.data.data.deviceInfos.envs[0].rssi;
        this.value=resp.data.data.deviceInfos.envs[0].properties[0].value;
        this.updateTime=resp.data.data.deviceInfos.envs[0].updateTime;
        this.out_of_date=resp.data.data.deviceInfos.envs[0].out_of_date;
      })
      .catch((err:AxiosError)=>{
        this.getUIContext().getPromptAction().showToast({ message: err.message })
      })

  }
  build() {
    Column({space:20}){
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
          Text('活动状态：' + this.value)
            .fontSize(24)
        }

        ListItem() {
          Text('更新时间：' + this.updateTime)
            .fontSize(24)
        }
      }.divider({strokeWidth:1})

      Button('更新当前设备信息')
        .width('61.8%')
        .onClick(()=>{
          this.respdata=[];
          let url = 'http://192.168.100.1/api/room/allDevAndProcess';
          let pref=preferences.getPreferencesSync(getContext(),{name:'zbox.xml'});
          let cookie = pref.getSync('cookie','') as string;
          // 省略4个参数 获取所有设备信息
          //传入IEEE 获取指定设备信息
          axios.post(url, {ieee:'a46dd4fffeed971a'} as IEEE,{timeout:1000,headers:{'Content-Type':'application/json','cookie':cookie}})
            .then((resp:AxiosResponse)=>{
              console.log(JSON.stringify(resp));
              this.rname=resp.data.data.deviceInfos.envs[0].rname;

              this.battery=resp.data.data.deviceInfos.envs[0].battery;
              this.rssi=resp.data.data.deviceInfos.envs[0].rssi;
              this.value=resp.data.data.deviceInfos.envs[0].properties[0].value;
              this.updateTime=resp.data.data.deviceInfos.envs[0].updateTime;
              this.out_of_date=resp.data.data.deviceInfos.envs[0].out_of_date;
              this.getUIContext().getPromptAction().showToast({ message: '更新成功'});

            })
            .catch((err:AxiosError)=>{
              this.getUIContext().getPromptAction().showToast({ message: err.message })
            })
        })
      Button('获取历史信息')
        .width('61.8%')
        .onClick(()=>{
          this.respdata=[]
          let url = 'http://192.168.100.1/api/terminal/history/get';
          let pref=preferences.getPreferencesSync(getContext(),{name:'zbox.xml'});
          let cookie = pref.getSync('cookie','') as string;
          // 省略4个参数 获取所有设备信息
          //传入IEEE 获取指定设备信息
          axios.post(url, {ieee:'a46dd4fffeed971a',terminalDefId:'17681'} as terminalDefId,{timeout:1000,headers:{'Content-Type':'application/json','cookie':cookie}})
            .then((resp:AxiosResponse)=>{
              console.log(JSON.stringify(resp.data.data));
              //console.log(resp.data.data.length);
              for(let i =1;i<=resp.data.data.length;i++){
                this.hupdateTime=resp.data.data[i-1].update_datetime;
                this.hpast=resp.data.data[i-1].past;
                this.hvalue=resp.data.data[i-1].value;
                //this.hdate=resp.data.data[0].date;
                //this.htime=resp.data.data[0].time;
                this.hout_of_date=resp.headers.keepalive;
                //console.log('赋值');
                this.respdata.push(i.toString());
                this.respdata.push('更新时间：' + this.hupdateTime);
                //console.log('更新时间：' + this.hupdateTime);
                this.respdata.push('past：' + this.hpast);
                //console.log('past：' + this.hpast);;
                this.respdata.push('活动状态：' + this.hvalue);
                //console.log('活动状态：' + this.hvalue);
                this.respdata.push('在线状态：' + this.hout_of_date);
                //console.log('在线状态：' + this.hout_of_date);
                console.log(this.respdata[1]);
              }
              this.getUIContext().getPromptAction().showToast({ message: '获取历史信息成功'});

            })
            .catch((err:AxiosError)=>{
              this.getUIContext().getPromptAction().showToast({ message: err.message })
            })
        })
      Text('历史信息：')
        .fontSize('24');

      List() {
        //参数1 循环对象 参数2 循环体 e表示数组中每一个元素
        ForEach(this.respdata,(e:string)=>{
          ListItem() {
            Text(e)
              .fontSize(18)
          }

        })



      }.divider({strokeWidth:1})

    }
    .height('100%')
    .width('100%')
    .margin({top:50,bottom:30})
    .padding({left:18,right:18,bottom:30})//内边距

  }
}