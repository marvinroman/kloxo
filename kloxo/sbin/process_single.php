<?php 

ob_start();
include_once "lib/include.php";

process_main();

function process_main()
{
	global $gbl, $sgbl, $login, $ghtml; 

	global $argv;

	$list = parse_opt($argv);

	$exitchar = $sgbl->__var_exit_char;

	$res = new Remote();
	$res->exception = null;
	$res->ddata = "hello";
	$res->message = "hello";
	$total = file_get_contents($list['temp-input-file']);
	$string = explode("\n", $total);
	if (csb($total, "__file::")) {
		file_server(null, $string);
	} else {
		$reply = process_server_input(null, $total);
		//fprint(unserialize(base64_decode($reply)));
		ob_end_clean();
		print("$reply\n$exitchar\n");
		flush();
	}
	exit;
}

