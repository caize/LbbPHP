<?php
/**
 * Created by PhpStorm.
 * User: lbbniu
 * Date: 16/3/7
 * Time: 下午5:06
 */
return [
    "site_title"=>"LbbPHP",
    "debug_mode"=>true,//是否开启调试模式
    "domain"=>"localhost",
    "site_url"=>"http://localhost/",
    "static_url"=>"http://localhost/",
    "themes"=>"default",
    "database"=>[
        "write"=>"",
        "read"=>"",
        "dbname"=>"",
        "dbuser"=>"",
        "dbpass"=>"",
        "dbext"=>"",
    ],
    "memcache"=>[

    ],
    "wechat"=>[

    ],
    "slog"=>[
        "use"=>false,
        "host"=>false,
        "force_client_id"=>false,
    ],
    "qq"=>[

    ],
    "sina"=>[

    ],
    "youpai"=>[
        "id"=>"vliang",
        "pw"=>"vliang123456",
        "name"=>"app235-t",
        "up_url"=>"http://app235-t.b0.upaiyun.com",
    ],
    "smtp"=>[
        "smtp_server"=>"smtp.126.com",
        "smtp_port"=>25,
        "smtp_user_email"=>"pengyong881215@126.com",
        "smtp_user"=>"pengyong881215@126.com",
        "smtp_pwd"=>"pengyong881215@126.com",
        "smtp_mail_type"=>"HTML",
        "smtp_tim_out"=>30,
        "smtp_auth"=>1,
    ],
];