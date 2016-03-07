<?php
/**
 * Created by PhpStorm.
 * User: lbbniu
 * Date: 16/3/7
 * Time: 下午5:01
 */
$config = require "config.php";
//var_dump($config);
$page = new \LbbPHP\Page($config);
$page ->setWebpath(dirname(__FILE__)."/");
$page -> run();