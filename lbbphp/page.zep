namespace LbbPHP;

class Page{

    protected cache;//mc缓存
    protected dbm;//增删改数据库
    protected dbs;//查数据库
    protected params;//请求url参数
    protected title;
    protected html;
    protected controllerDir = "./system/controllers/";

    protected config=[];

    public function __construct(array config){
        //初始化各种资源


    }

    //运行应用
    public function run(){
        session_start();//开启session
        this->_parse_input();
        this->_send_headers();
        this->_load_controller();
    }

    private function _parse_input(){


    }

    private function _send_headers(){


    }

    private function _load_controller(){

    }

    public function load_template(string filename,boolean output_content =true){

    }

    public function redirect(string url, boolean abs = false){

    }

    public function param(key){

    }

    public function response(int status=1,var info="",string url=""){
        array data = [];
        let data["status"] = status;
        let data["info"] = info;
        let data["url"] = url;
        var str;
        if isset _REQUEST["callback"]{
            let str = _REQUEST["callback"]."(".json_encode(data).")";
        }else{
            let str = json_encode(data);
        }
        exit(str);
    }

    //正确返回
    public function success(var info = "",string url = ""){
        this->response(1,info,url);
    }

    //错误放回
    public function error(var info = "",string url = ""){
        this->response(0,info,url);
    }
}