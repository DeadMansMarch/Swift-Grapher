
enum REQUEST_ERROR{
    case NORP,EMPTY,SPEC;
}

func webrequest(_ url:String,_ querydata:[String:String])->String?{
    var request_end = false;
    var request_error:REQUEST_ERROR? = nil;
    var spec_error = "";
    
    var request_response = "";
    
    let querystring = querydata.reduce("",{$0 + "\($1.0)=\($1.1)&"});
    
    var request = URLRequest(url: URL(string: url)!);
    request.httpMethod = "post"
    request.httpBody = querystring.data(using: String.Encoding.utf8);
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            request_error = .SPEC;
            spec_error = error!.localizedDescription
            return
        }
        guard let data = data else {
            request_error = .EMPTY;
            return
        }
        
        request_response = String(data: data, encoding: String.Encoding.utf8)!;
        request_end = true;
    }
    
    task.resume()
    var tick = 0;
    while !request_end{
        
        guard request_error == nil else{
            print("REQUEST ERROR");
            print(spec_error);
            return nil;
        }
        
        usleep(10000);
        tick += 1;
        guard tick < 100 else{
            print("Slow response from server... aborting.");
            return nil
        }
        
        
    }
    
    return request_response;
}

struct Graph: CustomStringConvertible{
    
    static let mainserver = "http://mainhopper.hopto.org:8888/AS1/ugraph.php";
    
    enum GraphType : String{
        case Line = "line",Pie = "pie";
    }

    
    private let tid:String;
    private let  id:Int;
    
    init?(header:String,type:GraphType,apiHash:String=""){
        let initRaw = webrequest(Graph.mainserver,[
            "reactor":"init",
            "name":header,
            "type":type.rawValue,
            "apik":apiHash
        ]);
        
        guard let initData = initRaw else{
            print("Error initializing graph.");
            return nil;
        }
        
        let response = initData.characters.split(separator:":").map({String($0)});
        guard response.count > 1 else{
            print("Graph initialization limit reached. Delete old graphs or wait to continue.");
            return nil;
        }
        self.tid = response[0];
        self.id  = Int(response[1])!;
    }
    
    func axis_headers(y:String,x:String)->Bool{
        let success = webrequest(Graph.mainserver,[
            "reactor":"name_axis",
            "names":"\(x)|\(y)",
            "id":"\(self.id)",
            "tid":self.tid
        ]);
        
        if (success != nil){
            return true;
        }
        print("Axis headers failed to write.");
        return false;
    }
    
    func data_headers(headers:[String])->Bool{
        let success = webrequest(Graph.mainserver,[
            "reactor":"name_data",
            "names":String(headers.reduce("",{$0 + $1 + "|"}).characters.dropLast()),
            "id":"\(self.id)",
            "tid":self.tid
        ]);
        
        if (success != nil){
            return true;
        }
        print("Data headers failed to write.");
        return false;
    }
    
    func add_data(x:Any,data:[Any])->Bool{
        
        let compress = String(data.reduce("\(x)|",{$0 + String(describing: $1) + "|"}).characters.dropLast());
        
        let success = webrequest(Graph.mainserver,[
            "reactor":"data",
            "points":compress,
            "id":"\(id)",
            "tid":self.tid
        ]);
        
        if (success != nil){
            return true;
        }
        
        print("Data addition failed.");
        return false;
    }
    
    func add_data(x:Any,data:[Any],modifier:(Any,Any)->Any)->Bool{
        return add_data(x: x, data: data.map({modifier(x,$0)}));
    }
    
    var description: String{
        return "http://mainhopper.hopto.org:8888/AS1/ugraph.php?reactor=display&id=\(self.id)";
    }
}

extension Graph{
    
    init?(header:String,yHeader:String,xHeader:String,apiHash:String=""){
        self.init(header:header,type:.Line,apiHash:apiHash);
        self.axis_headers(y: yHeader, x: xHeader);
    }
    
}
