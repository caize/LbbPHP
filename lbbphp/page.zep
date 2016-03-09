namespace LbbPHP;

class Page{

    protected cache{
        get
    };//mc缓存
    protected dbm{
        get
    };//增删改数据库
    protected dbs{
        get
    };//查数据库
    protected params = [];//请求url参数
    protected title;
    protected html;
    protected webpath="./"{
        set,get
    };
    protected controllerDir = "./system/controllers/"{
        set,get
    };

    protected config=[];

    protected request = [];
    protected data = null;

    //势力环
    public function __construct(array config){
        var debug_mode = false,dir,dbconfig,mcconfig;
        if fetch debug_mode,config["debug_mode"] {
            if debug_mode {
                ini_set("error_reporting", E_ALL | E_STRICT);
                ini_set("display_errors", 1);
            }
        }
        //初始化各种资源
        let this->config = config;
        if fetch dir,this->config["controllerDir"] {
            let this->controllerDir = dir;
        }
        //连接数据
        if fetch dbconfig ,config["database"]{
            let this->dbm = new Mysql(dbconfig["write"],dbconfig["dbuser"],dbconfig["dbpass"],dbconfig["dbname"],debug_mode);
            let this->dbs = new Mysql(dbconfig["read"],dbconfig["dbuser"],dbconfig["dbpass"],dbconfig["dbname"],debug_mode);
        }else{
            exit("LbbPHP error:缺少数据库配置database");
        }
        //缓存系统等等
        if fetch mcconfig ,config["memcache"]{
            let this->cache = new Memcache(mcconfig);
        }
    }

    //运行应用
    public function run(){
        session_start();//开启session
        ob_start("ob_gzhandler", 6);
        this->_parse_input();
        this->_send_headers();
        this->_load_controller();
    }

    private function _parse_input(){
        var request,pos,tmp,key,one,m,first,t;
        let request = _SERVER["REQUEST_URI"];
        let pos = strpos(request,"?");
        if false !== pos {
            let request = substr(request,0,pos);
        }
        if false !== strpos(request,"\/\/") {
            let request = preg_replace("/\/+/iu","\/",request);
        }
        let tmp = str_replace(["http:\/\/","https:\/\/"],"",this->config["site_url"]);
        if false !== strpos(tmp,"\/\/") {
            let tmp = preg_replace("/\/+/iu", "\/", tmp);
        }

        let tmp = substr(tmp,strpos(tmp,"\/"));
        if substr(request,0,strlen(tmp)) == tmp {
            let request = substr(request, strlen(tmp));
        }
        if _SERVER["HTTP_HOST"] != this->config["domain"] && false !== strpos(_SERVER["HTTP_HOST"], "." . this->config["domain"]){
            let tmp = str_replace("." . this->config["domain"], "", _SERVER["HTTP_HOST"]);
            let tmp = preg_replace("/^www\./", "", tmp);
            let tmp = trim(tmp);
            if !empty(tmp) {
                let request = tmp . "/" . request;
            }
        }
        let request = trim(request, "\/");
        if empty(request) {
            let this->request[] = "home";
            return ;
        }
        let request = explode("\/",request);
        for key,one in request {
            if false !== strpos(one,":") && preg_match("/^([a-z0-9\-_]+)\:(.*)$/iu", one, m) {
                 let this->params[m[1]] = m[2];
                 unset(request[key]);
                 continue;
            }

            if !preg_match("/^([a-z0-9\-\._]+)$/iu", one){
                unset(request[key]);
                continue;
            }
        }
        let request = array_values(request);
        if 0 == count(request) {
            let this->request[] = "home";
            return ;
        }
        let first = request[0];
        if file_exists(this->controllerDir.first.".php") {
            let this->request[] = first;
        }else{
            let this->request[] = "home";
            return ;
        }
        unset(request[0]);

        for one in request {
            let t = this->request;
            let t[] = one;
            if file_exists(this->controllerDir . implode("_", t) . ".php"){
                let this->request[] = one;
                continue;
            }
            break;
        }
        if 0 == count(this->request) {
            let this->request[] = "home";
            return ;
        }
    }

    private function _send_headers(){
        header("framework:lbbphp v1.0");
        header("website:www.lbbniu.cn,www.lbbniu.com,www.lbbniu.net");
        if(this->request[0]!="test"){
            header("P3P: CP=CURa ADMa DEVa PSAo PSDo OUR BUS UNI PUR INT DEM STA PRE COM NAV OTC NOI DSP COR");
            header("Cache-Control: no-store, no-cache, must-revalidate");
            header("Cache-Control: post-check=0, pre-check=0", false);
            header("Pragma: no-cache");
            header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
            if this->request[0] == "ajax" {
                if (this->param("ajaxtp") == "xml")
                {
                    header("Content-type: application/xml; charset=utf-8");
                } else
                {
                    header("Content-type: text/plain; charset=utf-8");
                }
            }elseif isset this->params["format"] {
                switch (this->params["format"]){
                    case "xml":
                        header("Content-type: application/xml");
                        break;
                    case "json":
                        header("Content-type: application/json");
                        break;
                    case "rss":
                        header("Content-type: application/rss+xml");
                        break;
                    case "atom":
                        header("Content-type: application/atom+xml");
                        break;
                    default:
                        header("Content-type: application/xml");
                        break;
                }
            }else{
                header("Content-type: text/html; charset=utf-8");
            }
        }
    }

    private function _load_controller(){
        let this->data = [];
        let this->data["page_title"] = this->config["site_title"];
        var controllerName;
        let controllerName = this->controllerDir . implode("_", this->request) . ".php";
        if file_exists(controllerName) {
            require(controllerName);
        }else{
            echo "默认home控制器不存在";
            die();
        }
    }

    //等待改写,对模板返回,进行特殊处理,加入特殊信息
    public function display(string filename,boolean output_content =true){
        let filename = this->webpath."template/" . this->config["themes"] . "/html/" . filename;
        if output_content {
            require(filename);
            return true;
        }else{
            var cnt;
            ob_start();
            require(filename);
            let cnt = ob_get_contents();
            ob_end_clean();
            return cnt;
        }
    }

    public function redirect(string url, boolean abs = false){
        if !abs && preg_match("/^http(s)?\:\/\//", url){
            let abs = true;
        }
        if !abs{
            if url[0] != '/' {
               let url = this->config["site_url"]. url;
            }
        }
        if !headers_sent() {
            header("Location: " . url);
        }
        echo "<meta http-equiv=\"refresh\" content=\"0;url='" . url . "'\" />";
        echo "<script type=\"text/javascript\"> self.location = \"'" . url . "'\"; </script>";
        exit("");
    }

    public function param(key){
        var value;
        if fetch value,this->params[key] {
            if is_numeric(value){
                return floatval(value);
            }
            if value == "true" || value == "TRUE" {
                return true;
            }
            if value == "false" || value == "FALSE" {
                return false;
            }
            return value;
        }else{
            return false;
        }
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
        echo str;
        die("");
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