import  axios, { AxiosError, AxiosResponse } from '@ohos/axios';
@Entry
@Component
struct NetPage {
  @State message: string = 'N/A';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('NetPageHelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          //网络访问
          let url ='https://weather.cma.cn/api/now/54857';//数字为城市编号
          //GET：浏览器直接访问
          axios.get(url,{timeout:1000})
            .then((resp:AxiosResponse)=>{//响应的结果
              console.log(JSON.stringify(resp));
            if(resp.status == 200){//正常返回结果
              this.message=resp.data.data.location+' '+resp.data.data.now.temperature+'℃';
            }
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