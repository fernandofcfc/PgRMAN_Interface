#!/usr/bin/perl

=for comment
	
 Script:	rman_backup.pl
 Autor:		Vinicius Porto Lima
 Data:		26/04/2013

 Descrição:
 
 Executa o backup do servidor informado e armazena os logs dentro da pasta do repositório 
 de backups.
	
=cut

use Util;
use strict;

#
# constants
#
my %_bkpTypes	= (	"full"			=> 1,
					"incremental"	=> 1,
					"archive"		=> 1);
					
use constant INI_FIELDS		=> [ "prefix", "backup_dir", "cluster_dir", "backup_keep", "wal_keep" ];
use constant EXEC_LOG		=> "execution.log";

use constant DEFAULT_CONF	=> "/etc/rman.ini";

#
# params
#
my $section		= shift;
my $type		= shift;
my $confPath	= shift;

if(($section eq "-h") || ($section eq "--help"))
{
	help();
}
elsif(not exists $_bkpTypes{$type})
{
	help("Invalid pg_rman backup type");
}

$confPath	= DEFAULT_CONF if(not defined $confPath);

# 
# vars
#
my $iniHash	= Util::readIniFileSection($confPath,$section,INI_FIELDS);

#
# exec
#

# backup
my $hostString	= "";
$hostString	.= " -h ".$$iniHash{host} if(exists $$iniHash{host});
$hostString .= " -p ".$$iniHash{port} if(exists $$iniHash{port});

system(	$$iniHash{prefix}."/bin/pg_rman -U postgres -d postgres $hostString -B ".$$iniHash{backup_dir}
	.	" -D ".$$iniHash{cluster_dir}." -b $type backup >> ".$$iniHash{backup_dir}."/".EXEC_LOG." 2>&1");

# validação
system(	$$iniHash{prefix}."/bin/pg_rman -B ".$$iniHash{backup_dir}." -D ".$$iniHash{cluster_dir}." validate >> "
	.	$$iniHash{backup_dir}."/".EXEC_LOG." 2>&1");

#
# functions
#

sub help
{
	my $message	= shift;
	
	$message	= "" if(not defined $message);
	
	print "
	$message
	Script $0 - backup do servidor informado
	
	Params:
		- section existente no arquivo .ini
		- tipo de backup (full, incremental, archive)
		- path do arquivo .ini (default /etc/rman.ini)\n\n";
	
	exit(0);
}