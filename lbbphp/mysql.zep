namespace LbbPHP;

class Mysql{
    private conn = false;
    private dbhost;
    private dbuser;
    private dbpass;
    private dbname;
    private debug_mode = false;
    private last_result;
    public  fatal_error;
    private ext;
    public  disconnect_on_descruct;
    private transTimes = 0;

    public function __construct(host,user,pass,db,debug){
        let this->dbhost = host;
        let this->dbuser = user;
        let this->dbpass = pass;
        let this->dbname = db;
        let this->debug_mode = debug;
        let this->ext = "mysql";
        if function_exists("mysqli_connect") {
         let this->ext = "mysqli";
        }
        let this->disconnect_on_descruct	= true;
    }
    public function __destruct(){
        var ret;
        if this->disconnect_on_descruct {
            if this->conn {
                let ret = this->ext == "mysqli" ?mysqli_close(this->conn):mysql_close(this->conn);
                let this->conn = false;
            }
        }
    }

    public function connect(){
        var db;
        let this->conn = this->ext == "mysqli" ?mysqli_connect(this->dbhost, this->dbuser, this->dbpass):mysql_connect(this->dbhost, this->dbuser, this->dbpass);
        if false == this->conn {
            this->fatal_error("Connect");
        }
        let db = this->ext == "mysqli" ?mysqli_select_db(this->conn,this->dbname):mysql_select_db(this->dbname,this->conn);
        if db == false {
            this->fatal_error("Select DB");
        }
        let db = this->ext == "mysqli" ?mysqli_query(this->conn,"SET NAMES utf8mb4"):mysql_query("SET NAMES utf8mb4",this->conn);
        return this->conn;
    }

    public function query(string query,boolean remember_result=true){
        var result;
        if false == this->conn{
            this->connect();
        }
        let result = this->ext=="mysqli" ? mysqli_query(this->conn, query) : mysql_query(query, this->conn);
        if false == result {
            this->fatal_error($query);
        }
        if remember_result {
            let this->last_result=result;
        }
        return result;
    }
    public function fetch_object(var res=false) {
        let res	= false!==res ? res : this->last_result;
        if false == res {
            return false;
        }
        return this->ext=="mysqli" ? mysqli_fetch_object(res) : mysql_fetch_object(res);
    }

    public function fetch_first(string query) {
        var res;
        let res	= this->query(query, false);
        if false == res {
            return false;
        }
        return this->fetch_object(res);
    }

    public function fetch_all(string query){
        var res,data,obj;
        let res = this->query(query,false);
        if res == false {
            return false;
        }
        let data = [];
        let obj = this->fetch_object(res);
        while obj {
            let data[]=obj;
            let obj =  this->fetch_object(res);
        }
        this->free_result(res);
        return data;
    }
    //获取一条数据一个字段的值,用户统计
    public function fetch_field(string query){
        var res,row;
        let res = this->query(query);
        if false == res {
            return false;
        }
        let row = this->ext=="mysqli"?mysqli_fetch_row(res):mysql_fetch_row(res);
        if !row {
            return false;
        }
        this->free_result(res);
        return row[0];
    }
    //sql查询的行数
    public function num_rows(var res=false){
        let res = res !== false?res:this->last_result;
        if false == res {
            return false;
        }
        return this->ext == "mysqli"?mysqli_num_rows(res):mysql_num_rows(res);
    }

    //最近插入返回的id
    public function insert_id(){
        if false == this->conn{
            this->connect();
        }
        return intval(this->ext=="mysqli" ? mysqli_insert_id(this->conn) : mysql_insert_id(this->conn));
    }
    //修改和删除影响的行数
    public function affected_rows(){
        if false == this->conn {
            this->connect();
        }
        return this->ext=="mysqli"?mysqli_affected_rows(this->conn):mysql_affected_rows(this->conn);
    }

    public function data_seek(var row=0,var res =false){
        let res = res ==false?res:this->last_result;
        if false == res {
            return false;
        }
        return this->ext == "mysqli" ?mysqli_data_seek(res,row):mysql_data_seek(res,row);
    }

    //释放资源
    public function free_result(var res=false){
        let res = res!==false?res:this->last_result;
        if res == false {
            return false;
        }
        return this->ext=="mysqli" ? mysqli_free_result(res) : mysql_free_result(res);
    }

    //转义
    public function escape(var str){
        if false == this->conn {
            this->connect();
        }
        return this->ext=="mysqli" ? mysqli_real_escape_string(this->conn, str) : mysql_real_escape_string(str, this->conn);
    }
    //转义快捷方法
    public function e(var str){
        return this->escape(str);
    }

    //sql执行出错处理
    public function fatal_error(var query){
        var error;
        let this->fatal_error = true;
        let error = this->ext=="mysqli" ? mysqli_error(this->conn) : mysql_error(this->conn);
        if this->debug_mode {
            echo "LbbPHP MySQL Query: ".query."<br />";
        	echo "LbbPHP MySQL Error: ".error."<br />";
        }
        exit("");
    }
}