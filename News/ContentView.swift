//  ContentView.swift
//  News
//
//  Created by PCW on 2021/04/30.
//

import SwiftUI
import SwiftyJSON
import SDWebImageSwiftUI
import WebKit

struct ContentView: View {
    
    @ObservedObject var list = getData()
    
    var body: some View {
        
        NavigationView{
            
            List(list.datas){i in
                
                NavigationLink(destination: webView(url: i.url)
                    .navigationBarTitle("", displayMode: .inline)) {
                    
                    HStack(spacing: 15){ //horizontal
                        
                        VStack(alignment: .leading, spacing: 10){ //vertiacl
                            
                            Text(i.title).fontWeight(.heavy)
                            Text(i.desc).lineLimit(2)
                        }
                        
                        if i.image != ""{
                            WebImage(url: URL(string: i.image), options: .highPriority,
                                     context: nil)
                                     .resizable()
                                     .frame(width: 110, height:135).cornerRadius(20)
                        }
                        
                    }.padding(.vertical, 15) //적당한 간격을 주기위함, 인자값을 전달하지않으면 기본값이 적용
                }
                
                
            }.navigationBarTitle("Headlines")
        }
    }
}

struct dataType : Identifiable { //식별가능하게 하는 프로토콜
    
    var id : String
    var title : String
    var desc : String
    var url : String
    var image : String
}

class getData : ObservableObject{ //사용저 인터페이스 밖에 있으며 앱 내의 스우뷰 구조체의 하위 뷰에만 필요한 데이터는 observable 오브젝트 활용
    
    @Published var datas = [dataType]()
    
    init() {
        
        let source = "https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=cc1a5adb1cf04bd6bbf6e1adfd3f68e8"
        
        let url = URL(string: source)!
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: url) { (data, _, err) in
            
            if err != nil{
                
                print((err?.localizedDescription)!)
                return
            }
            
            let json = try! JSON(data: data!)
            
            for i in json["articles"] {
                
                let title = i.1["title"].stringValue
                let description = i.1["description"].stringValue
                let url = i.1["url"].stringValue
                let image = i.1["urlToImage"].stringValue
                let id = i.1["publishedAt"].stringValue
                
                DispatchQueue.main.async { //serial, concurrent, thread 관련 작업 GCD, async 동시, uikit의 모든 요소는 main에서 수행
                    self.datas.append(dataType(id: id, title: title, desc: description, url: url, image: image))
                }
            }
        }.resume()
    }
    
}

struct webView : UIViewRepresentable { //swift에서 uivew를 추가해야할 경우 이 protocol을 활용, makeUIView, updateView를 무조건 구현해야함
    
    var url: String
    
    func makeUIView(context: UIViewRepresentableContext<webView>) -> WKWebView{
        
        let view = WKWebView()
        view.load(URLRequest(url: URL(string: url)!))
        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context:
    UIViewRepresentableContext<webView>) {
        
    }
}

struct ContentView_Previews: PreviewProvider { //미리보기
    static var previews: some View {
        ContentView()
    }
}

//generate an API Key in News API

