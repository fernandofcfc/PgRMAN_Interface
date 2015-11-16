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
use constant INI_FIELDS		=> [ "prefix", "backup_dir", "cluster_dir", "backup_keep", "wal_keep", "wal_remote" ];

use constant REMOTE_SECTION	=> "REMOTE_WAL";
use constant REMOTE_FIELDS	=> [ "server", "user"];

use constant TBLSPC_DIR		=> "pg_tblspc";
use constant XLOG_DIR		=> "pg_xlog";
use constant BASE_DIR		=> "base";

use constant RECOVERY_FILE	=> "recovery.conf";

use constant DEFAULT_CONF	=> "/etc/rman.ini";

#
# params
#
my $section		= shift;
my $timeStamp	= shift;
my $confPath	= shift;

if(($section eq "-h") || ($section eq "--help"))
{
	help();
}

$confPath	= DEFAULT_CONF if(not defined $confPath);

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
my $hostString	= "";
$hostString	.= " -h ".$$iniHash{host} if(exists $$iniHash{host});
$hostString .= " -p ".$$iniHash{port} if(exists $$iniHash{port});

my $restoreCmd	= $$iniHash{prefix}."/bin/pg_rman -U postgres -d postgres $hostString -B ".$$iniHash{backup_dir}
				. " -D ".$$iniHash{cluster_dir}." restore";

$restoreCmd    .= " --recovery-target-time \"$timeStamp\"" if(defined $timeStamp);

print `$restoreCmd`;

# adaptação para walfiles remotos
if($$iniHash{wal_remote})
{
	my $remoteHash			= Util::readIniFileSection($confPath,REMOTE_SECTION,REMOTE_FIELDS);
	
	my $recoveryString		= Util::fileToString($$iniHash{cluster_dir}."/".RECOVERY_FILE);
	my $recoveryNewString	= "";
	
	foreach my $line (split("\n",$recoveryString))
	{
		next 
			if($line =~ /^recovery_target_timeline/);
		
		$line	= "restore_command = 'scp $$remoteHash{user}\@$$remoteHash{server}:$$iniHash{wal_dir}/\%f \%p'"
			if($line =~ /^restore_command/);
		
		$recoveryNewString	.= $line."\n";
	}
	
	Util::stringToFile($$iniHash{cluster_dir}."/".RECOVERY_FILE,$recoveryNewString);
}

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
		- section (nome do servidor)
		- timestamp (opcional)
		- path do arquivo .ini (default /etc/rman.ini)
		
	Obs.: 	Quando o servidor com os arquivos wal nao for o mesmo servidor onde esta alocado o banco de dados, sera 
		necessario que o arquivo recovery.conf seja reescrito para a copia de arquivos wal utilizando scp entre
		o servidor com os arquivos e o servidor com o banco de dados. Para tanto, devera estar configurada
		relacao de confianca entre os dois servidores (usuario postgres do servidor de banco de dados devera
		acessar outro servidor com o usuario especificado sem o uso de senha)\n\n";
	
	exit(0);
}