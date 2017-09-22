

class Grapher : CustomStringConvertible{
    private(set) var tid:String = "";
    private(set) var lid:Int?   = nil;
    
    enum GraphType : String{
        case Line = "line",Pie = "pie";
    }
    
    enum LabelType {
        case Axis, Data
    }
    
    static func Request(_ url:String,_ requestBody:String)->String{
        var final = false;
        var resp  = "";
        
        var request = URLRequest(url: URL(string: url)!);
        request.httpMethod = "post"
        request.httpBody = requestBody.data(using: String.Encoding.utf8);
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            resp = String(data: data, encoding: String.Encoding.utf8)!;
            final = true;
        }
        
        task.resume()
        while !final{
            usleep(100);
        }
        return resp;
    }
    
    func make(name:String,type:GraphType){
        var response = Grapher.Request(
            "http://mainhopper.hopto.org:8888/AS1/ugraph.php",
            "reactor=init&name=\(name)&type=\(type.rawValue)"
        );
        
        var dual = response.characters.split(separator:":").map({String($0)});
        
        guard dual.count > 1 else {
            print("Too many graphs made - Init failed.");
            return;
        }
        
        guard let lid = Int(dual[1]) else{
            print("Unknown Graph Error");
            return;
        }
        
        self.tid = dual[0];
        self.lid = lid;
        
        print("Graph initialized.");
    }
    
    func label(_ type: LabelType,labels: [String]){
        guard let id = self.lid else{
            print("Graph not initiated.");
            return;
        }
        
        let Reactor:String;
        switch(type){
            case .Axis:
                Reactor = "name_axis";
            case .Data:
                Reactor = "name_data"
        }
        
        let names = String(labels.reduce("",{$0 + $1 + "|"}).characters.dropLast());
        let _ = Grapher.Request(
            "http://mainhopper.hopto.org:8888/AS1/ugraph.php",
            "reactor=\(Reactor)&names=\(names)&id=\(id)&tid=\(self.tid)"
        )
    }
    
    func add_data(data: [Any]){
        guard let id = self.lid else{
            print("Graph not initiated.");
            return;
        }
        
        let compress = String(data.reduce("",{$0 + String(describing: $1) + "|"}).characters.dropLast());
        let _ = Grapher.Request(
            "http://mainhopper.hopto.org:8888/AS1/ugraph.php",
            "reactor=data&points=\(compress)&id=\(id)&tid=\(self.tid)"
        )
    }
    
    func delete(){
        guard let id = self.lid else{
            print("Graph not initiated.");
            return;
        }
        
        let response = Grapher.Request(
            "http://mainhopper.hopto.org:8888/AS1/ugraph.php",
             "reactor=delete&id=\(id)&tid=\(self.tid)"
        );
        
        if (response != ""){
            print("Error deleting graph.")
            print(response)
        }else{
            print("Graph deleted");
        }
    }
    
    var description: String{
        return "http://mainhopper.hopto.org:8888/AS1/ugraph.php?reactor=display&id=\(self.lid!)";
    }
}
