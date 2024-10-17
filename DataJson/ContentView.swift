//
//  ContentView.swift
//  DataJson
//
//  Created by Denidu Gamage on 2024-10-17.
//

import SwiftUI

struct UserDTO : Codable, Hashable{
    let id: Int
    let username :String
    let fullName : String
}

struct DataDTO : Codable, Hashable{
    let commentId: Int
    let body: String
    let postId: Int
    let likes: Int
    let user : UserDTO
    
    enum CodingKeys: String, CodingKey{
        case commentId = "id"
        case body
        case postId
        case likes
        case user
    }
}

struct ContentView: View {
    
    @State var isLoading: Bool = true
    @State var commentData : DataDTO?
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading){
                if isLoading {
                    ProgressView()
                }else{
                    VStack(alignment: .leading){
                        Text("\(commentData?.user.username ?? "")")
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        
                        Text("\(commentData?.body ?? "")")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    
                }
                
            }.navigationTitle("Comment")
        }
        .onAppear{
            Task{
                await fetchComments()
            }
        }
        .refreshable {
            Task{
                await fetchComments()
            }
        }
    }
    
    func fetchComments() async{
        let url = URL(string: "https://dummyjson.com/comments/1")
        
        guard let unwrappedUrl =  url else {return}
        
        do{
            let (data, response) = try await URLSession.shared.data(from: unwrappedUrl)
            
            guard let response = response as? HTTPURLResponse else {
                print("Something Went Wrong")
                return
            }
            
            switch response.statusCode{
                case 200...300:
                let commentData = try JSONDecoder().decode(DataDTO.self, from: data)
                 self.commentData = commentData
                case 400...500:
                    print("Server Error")
                default:
                    print("UnKnown Error")
            }
        }catch{
            print("Error fetching data: \(error)")
        }
        self.isLoading = false
    }
    
    
}

#Preview {
    ContentView()
}
