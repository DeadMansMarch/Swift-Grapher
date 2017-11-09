let apihash = "******thanksbutthisismyhash******"

let graph1 = Graph(header:"API UPDATE TEST",yHeader:"Y",xHeader:"X",apiHash:apihash)!;
let graph2 = Graph(header:"API UPDATE TEST",yHeader:"Y",xHeader:"X",apiHash:apihash)!;
let graph3 = Graph(header:"API UPDATE TEST",yHeader:"Y",xHeader:"X",apiHash:apihash)!;

graph1.data_headers(headers: ["y=x^2","y=x^3"]);
graph2.data_headers(headers: ["sqrt(y=x^2)","sqrt(y=x^3)"]);
graph3.data_headers(headers: ["y=log10(x)","y=log10(x^3)"]);

print("G1: \(graph1), G2: \(graph2), G3: \(graph3)");

for i in 0...10000{
    usleep(10000);
    
    graph1.add_data(x:i,data:[i*i,i*i*i]);
    graph2.add_data(x:i,data:[i*i,i*i*i],modifier:{sqrt(Double($1 as! Int))});
    graph3.add_data(x:i,data:[i,i*i*i],modifier:{log10(Double($1 as! Int))});
}
