namespace LbbPHP;

class Memcache{
    private host;
    private port;
    private prefix;
    private expire;
    private version;
    private mc;
    private ext;

    public function __construct(array config){
        let this->host = config["host"];
        let this->port = config["port"];
        let this->prefix = config["prefix"];
        let this->expire = config["expire"];
        let this->version = config["version"];
        let this->ext = class_exists("Memcached", false) ? "memcached?" : "memcache";
    }

    private function connect(){
        if false == this->mc {
            let this->mc = this->ext == "memcached" ? new \Memcached() : new \Memcache();
            this->mc->addServer(this->host, intval(this->port));

        }
        return this->mc;
    }

    public function get(var key){
        if false == this->mc {
            if false == this->connect() {
                return false;
            }
        }
        let key = this->prefix.key;
        return this->mc->get(key);
    }

    public function set(var key,var data,var expire){
        if false == this->mc {
            if false == this->connect() {
                return false;
            }
        }
        let key = this->prefix.key;
        return this->ext=="memcached"?this->mc->set(key,data,expire):this->mc->set(key, data, false, expire);
    }

    public function getDelayed(){
        if false == this->mc {
            if false == this->connect() {
                return false;
            }
        }
        return this->mc->getDelayed();
    }
    public function fetchMc(){
        if false == this->mc {
            if false == this->connect() {
                return false;
            }
        }
        return this->mc->{"fetch"}();
    }

    public function del(var key){
        if false == this->mc {
            if false == this->connect() {
                return false;
            }
        }
        return this->mc->delete($key, 0);
    }
    public function flush(){
        return this->mc->flush(1);
    }
}