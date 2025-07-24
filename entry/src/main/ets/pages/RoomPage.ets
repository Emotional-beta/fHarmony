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
interface room {
  type:type;
  name:string
  create_datetime:string
  id:string,
  isDisp:string,
  dispIndex:string
}
interface  updateName{
  roomId:string
  name:string
}
interface del{
  roomId:string
}
enum type{
  home,
  school,
  company
}
@Entry
@Component

struct RoomPage {
  @State type:string='';
  @State name:string='';
  @State newname: string = '';
  @State value: string = 'N/A';
  @State updateTime: string = 'N/A';
  @State out_of_date: string = 'N/A';

  //index:number = 0;
  @State respdata :room[]=[];
  @State typeindex:type=0;

  aboutToAppear(): void {

  }
  build() {
    Column({space:20}){
      Column({space:10}){
        TextInput({placeholder:'房间名',text:$$this.name})//默认值：text:‘内容’
          .width('61.8%')
          .backgroundColor(Color.White)
        Row({space:10}){
          TextInput({placeholder:'房间类型:',text:$$this.type})//默认值：text:‘内容’
            .width('61.8%')
            .backgroundColor(Color.White)
          Select([{value:'家'},{value:'学校'},{value:'公司'}])
            .font({size:18})
            .selected(0)
            .optionFont({size:18})
            .onSelect((index:number)=>{
              this.typeindex=index;
              this.getUIContext().getPromptAction().showToast({ message: '选择完成'+this.typeindex })
            }) }
        .width('61.8%')
        .justifyContent(FlexAlign.Start);



        Button('创建房间')
          .width('61.8%')
          .onClick(()=>{
            if(this.name){
              let url = 'http://192.168.100.1/api/room/add';
              let pref=preferences.getPreferencesSync(getContext(),{name:'zbox.xml'});
              let cookie = pref.getSync('cookie','') as string;
              axios.post(url, {type:this.typeindex,name:this.name} as room,{timeout:1000,headers:{'Content-Type':'application/json','cookie':cookie}})
                .then((resp:AxiosResponse)=>{
                  console.log(JSON.stringify(resp));
                  if(resp.data.code=='0000000'){
                    this.getUIContext().getPromptAction().showToast({ message: '创建房间成功' })
                    this.name='';
                  }else{
                    this.getUIContext().getPromptAction().showToast({ message: '创建房间失败' })
                  }
                })
                .catch((err:AxiosError)=>{
                  this.getUIContext().getPromptAction().showToast({ message: err.message })
                })
            }else{
              this.getUIContext().getPromptAction().showToast({ message: '房间名不能为空' })
            }


          })
        Button('获取所有房间信息')
          .width('61.8%')
          .onClick(()=>{
            this.respdata=[]
            let url = 'http://192.168.100.1/api/room/all';
            let pref=preferences.getPreferencesSync(getContext(),{name:'zbox.xml'});
            let cookie = pref.getSync('cookie','') as string;
            // 省略4个参数 获取所有设备信息
            //传入IEEE 获取指定设备信息
            axios.post(url,null,{timeout:1000,headers:{'Content-Type':'application/json','cookie':cookie}})
              .then((resp:AxiosResponse)=>{
                console.log(JSON.stringify(resp.data.data));
                //console.log(resp.data.data.length);

                for(let i =1;i<=resp.data.data.length;i++){
                  let roomindex:room = {
                    type: this.typeindex,  // 使用枚举值
                    name: this.name,
                    create_datetime: "2023-11-15 14:30:00",
                    id:'1',
                    isDisp:'null',
                    dispIndex:'-1'
                  };
                  roomindex.type=resp.data.data[i-1].type as type;
                  roomindex.name=resp.data.data[i-1].name;
                  roomindex.id=resp.data.data[i-1].id;
                  roomindex.dispIndex=resp.data.data[i-1].dispIndex
                  roomindex.create_datetime=resp.data.data[i-1].create_datetime;

                  this.respdata.push(roomindex);

                }


                this.getUIContext().getPromptAction().showToast({ message: '获取房间信息成功,请点击“获取房间信息”进行刷新'});

              })
              .catch((err:AxiosError)=>{
                this.getUIContext().getPromptAction().showToast({ message: err.message })
              })
          })
        Text('房间信息：')
          .fontSize('24');
        TextInput({placeholder:'修改房间名',text:$$this.newname})//默认值：text:‘内容’
          .width('61.8%')
          .backgroundColor(Color.White)
        List() {
          //参数1 循环对象 参数2 循环体 e表示数组中每一个元素
          ForEach(this.respdata,(e:room)=>{
            ListItem() {
              Scroll() {  // 添加横向滚动
                Row({space:10}){
                  Text('房间名：'+e.name)
                    .fontSize(18)
                  Text('房间id：'+e.id)
                    .fontSize(18)
                  if(e.type==0){
                    Text('房间类型：家庭')
                      .fontSize(18)
                  }else if(e.type==1){
                    Text('房间类型：学校')
                      .fontSize(18)
                  }else if(e.type==2){
                    Text('房间类型：公司')
                      .fontSize(18)
                  }else{
                    Text('房间类型错误')
                      .fontSize(18)
                  }
                  Text('创建时间：'+e.create_datetime)
                    .fontSize(18)
                  Button('修改房间名称')
                    .onClick(()=>{
                      let url = 'http://192.168.100.1/api/room/updateName';
                      let pref=preferences.getPreferencesSync(getContext(),{name:'zbox.xml'});
                      let cookie = pref.getSync('cookie','') as string;
                      axios.post(url, { roomId:e.id,name:this.newname } as updateName,{timeout:1000,headers:{'Content-Type':'application/json','cookie':cookie}})
                        .then((resp:AxiosResponse)=>{
                          console.log(JSON.stringify(resp.data.data));
                          //console.log(resp.data.data.length);
                          if(resp.data.code=='0000000')
                          {

                            this.getUIContext().getPromptAction().showToast({ message: '修改房间信息成功' });
                          }else{
                            this.getUIContext().getPromptAction().showToast({ message: '修改房间信息失败' });
                          }

                        })
                        .catch((err:AxiosError)=>{
                          this.getUIContext().getPromptAction().showToast({ message: err.message })
                        })                    })

                  Button('删除房间')
                    .onClick(()=>{
                      let url = 'http://192.168.100.1/api/room/del';
                      let pref=preferences.getPreferencesSync(getContext(),{name:'zbox.xml'});
                      let cookie = pref.getSync('cookie','') as string;
                      axios.post(url, { roomId:e.id} as del,{timeout:1000,headers:{'Content-Type':'application/json','cookie':cookie}})
                        .then((resp:AxiosResponse)=>{
                          console.log(JSON.stringify(resp.data.data));
                          //console.log(resp.data.data.length);
                          if(resp.data.code=='0000000')
                          {

                            this.getUIContext().getPromptAction().showToast({ message: '删除成功' });
                          }else{
                            this.getUIContext().getPromptAction().showToast({ message: '删除失败' });
                          }

                        })
                        .catch((err:AxiosError)=>{
                          this.getUIContext().getPromptAction().showToast({ message: err.message })
                        })                    })

                }
              }
              .scrollable(ScrollDirection.Horizontal) // 设置为横向滚动
              .scrollBar(BarState.On)               // 显示滚动条
              
            }

          })



        }.divider({strokeWidth:1})
      }



    }
    .height('100%')
    .width('100%')
    .margin({top:50,bottom:30})
    .padding({left:18,right:18,bottom:30})//内边距

  }
}