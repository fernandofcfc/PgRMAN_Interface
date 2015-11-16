#!/usr/bin/perl

=for comment

 Script:	rman_restore.pl
 Autor:		Vinicius Porto Lima
 Data:		26/04/2013

 Descrição:
 
 Realiza o restore do servidor.

=cut

use Util;
use strict;

#
# constants
#
use constant INI_FIELDS	=> [ "prefix", "backup_dir", "cluster_dir", "backup_keep", "wal_keep" ];

use constant TBLSPC_DIR	=> "pg_tblspc";
use constant XLOG_DIR	=> "pg_xlog";
use constant BASE_DIR	=> "base";

#
# params
#
my $confPath	= shift;
my $section		= shift;
my $timeStamp	= shift;

if(($confPath eq "-h") || ($confPath eq "--help"))
{
	help();
}

# 
# vars
#
my $iniHash	= Util::readIniFileSection($confPath,$section,INI_FIELDS);

#
# exec
#

# limpeza dos diretórios
my $exit	= 0;

while (!$exit)
{
	my $input	= Util::readInput("Deseja fazer a limpeza dos diretorios do cluster (s/n)");
	
	if($input eq "s")
	{
		# limpa base
		Util::cleanDir($$iniHash{cluster_dir}."/".BASE_DIR); 
		
		# limpa pg_xlog
		Util::cleanDir($$iniHash{cluster_dir}."/".XLOG_DIR);
		
		# limpa pg_tblspc
		Util::cleanDir($$iniHash{cluster_dir}."/".TBLSPC_DIR);
		
		$exit	= 1;
	}
	elsif($input eq "n")
	{
		$exit	= 1;	
	}
}

# restore
my $restoreCmd	= $$iniHash{prefix}."/bin/pg_rman -U postgres -d postgres -B ".$$iniHash{backup_dir}." -D ".$$iniHash{cluster_dir}." restore";
$restoreCmd    .= " --recovery-target-time \"$timeStamp\"" if(defined $timeStamp);

print `$restoreCmd`;

#
# functions
#

##
#
##
sub help
{
	my $message	= shift;
	
	print "
	Script $0 - Realiza o restore do servidor completo ou para timestamp informado
	
	Params:
		- path do arquivo .ini
		- section (nome do servidor)
		- timestamp (opcional)\n\n";
	
	exit(0);
}