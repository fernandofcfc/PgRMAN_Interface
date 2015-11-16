#!/usr/bin/perl

=for comment

 Script:	rman_show.pl
 Autor:		Vinicius Porto Lima
 Data:		26/04/2013

 Descrição:
 
 Print na tela do terminal os backups disponíveis para o servidor passado como parâmetro, contido
 no arquivo .ini informado.

=cut

use Util;
use strict;

#
# constants
#
use constant INI_FIELDS	=> [ "prefix", "backup_dir", "cluster_dir", "backup_keep", "wal_keep" ];

#
# params
#
my $confPath	= shift;
my $section		= shift;
my $timeStamp	= shift;

if((not defined $confPath)|| ($confPath eq "-h") || ($confPath eq "--help"))
{
	help();
}

$timeStamp	= "" if(not defined $timeStamp);

# 
# vars
#
my $iniHash	= Util::readIniFileSection($confPath,$section,INI_FIELDS);

#
# exec
#

# show
print `$$iniHash{prefix}/bin/pg_rman -B $$iniHash{backup_dir} show $timeStamp`;

#
# functions
#

sub help
{
	my $message	= shift;
	
	print "
	Script $0 - print dos backups disponiveis no repositorio para o servidor informado
	
	Params:
		- path do arquivo .ini
		- section existente no arquivo .ini
		- timestamp definida entre \"'s ou timeline\n\n";
	
	exit(0);
}