#!/usr/bin/perl

=for comment

 Script:	rman_report.pl
 Autor:		Vinicius Porto Lima
 Data:		26/04/2013

 Descri��o:
 
 Cria relat�rio de backups realizados no dia passado como par�metro. O relat�rio � enviado
 por email.
	
=cut

use Util;
use Mail::Text;
use strict;

#
# constants
#
use constant EMAIL_SECTION	=> "EMAIL";
use constant EMAIL_FIELDS	=> [ "smtp", "from", "list" ];
use constant EMAIL_SUBJECT	=> "RMAN backup list";
use constant INI_FIELDS		=> [ "prefix", "backup_dir", "cluster_dir", "backup_keep", "wal_keep" ];

use constant DEFAULT_RETRO	=> 1;

#
# params
#
my $confPath	= shift;
my $retro		= shift;

if((not defined $confPath)||($confPath eq "-h") || ($confPath eq "--help"))
{
	help();
}

$retro	= DEFAULT_RETRO	if(not defined $retro);

# 
# vars
#
my $emailHash	= Util::readIniFileSection($confPath,EMAIL_SECTION,EMAIL_FIELDS);
my $output		= "";
my $timestamp	= Util::timestampFormattedString(time()-(86400*$retro),"\%Y-\%m-\%d");

#
# exec
#

# gera relat�rio
foreach my $section (@{Util::getIniSections($confPath)})
{
	next if($section eq EMAIL_SECTION);	
	
	my $iniHash	= Util::readIniFileSection($confPath,$section,INI_FIELDS);
	
	$output	.= "Backup $section:\n";
	$output	.= `$$iniHash{prefix}/bin/pg_rman -B $$iniHash{backup_dir} show $timestamp`;
	$output	.= "\n";	
}

my $mailText	= Mail::Text->new();
$mailText->setSubject(EMAIL_SUBJECT." - $timestamp");
$mailText->setData("$output");
$mailText->setFrom($$emailHash{from});
	
if($$emailHash{list} =~ /ARRAY/)
{
	foreach my $to (@{$$emailHash{list}})
	{
		$mailText->addTo($to);
	}
}
else
{
	$mailText->addTo($$emailHash{list});
}     								
	
$mailText->send($$emailHash{smtp});

#
# functions
#

sub help
{
	my $message	= shift;
	
	print "
	Script $0 - Cria resumo dos backups realizados em todos os servidores do arquivo de configuracao e envia por email
	
	Params:
		- path do arquivo .ini
		- dia retroativo\n\n";
		
	exit(0);
}