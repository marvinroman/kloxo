<?php

class Service__Linux extends Lxlclass
{
	static function getServiceList()
	{
		global $gbl, $sgbl, $login, $ghtml;
		
		$val = lscandir_without_dot("{$sgbl->__path_real_etc_root}/init.d");
	/*
		$val = array_remove($val, $sgbl->__var_programname_web);
		$val = array_remove($val, $sgbl->__var_programname_dns);
		$val = array_remove($val, $sgbl->__var_programname_imap);
		$val = array_remove($val, $sgbl->__var_programname_mmail);
	*/
		$nval = self::getMainServiceList();
		$nval = lx_array_merge(array($nval, $val));
		
		return $nval;
	}

	static function getMainServiceList()
	{
		global $gbl, $sgbl, $login, $ghtml;

		$nval['httpd'] = 'httpd';
		$nval['nginx'] = 'nginx';
		$nval['lighttpd'] = 'lighttpd';

		$nval['php-fpm'] = 'php-fpm';

		$nval['named'] = 'named';
	//	$nval['djbdns'] = "tinydns";
		$nval['djbdns'] = "djbdns";

		$nval['qmail'] = 'qmail';
	//	$nval['courier-imap'] = 'courier';
	//	$nval['spamassassin'] = 'spamassassin';

		$nval['iptables'] = "iptables";

		return $nval;
	}

	static function checkService($name)
	{
		global $gbl, $sgbl, $login, $ghtml;

		$ret = lxshell_return("{$sgbl->__path_real_etc_root}/init.d/{$name}", "status");
		$state = ($ret) ? "off" : "on";

		return $state;
	}

	static function getRunLevel()
	{
		$v = trim(lxshell_output("runlevel"));
		$v = explode(" ", $v);
		
		return $v[1];
	}
}