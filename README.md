# Pg RMAN Interface
# Autor: Vinicius Porto Lima (viniciusmaximus@gmail.com)

1. Descrição
 
 Scripts que servem como uma interface simplificada do Pg RMAN, ferramenta de backup PITR do PostgreSQL.
 
2. Objetivo
 
 Simplificar a vida do dba, que poderá fazer uso dos scripts para trabalhar com o Pg RMAN.
 
3. Utilização

 Todos os script lêem o arquivo de configurações, rman.ini, que deve ser disponibilizado no diretório /etc.
 Neste arquivo, são colocadas as configurações do servidor que será gerenciado pelos scripts do Pg RMAN
 Interface, sendo que o servidor se torna uma seção do .ini . Com o arquivo corretamente configurado, 
 basta executar os scripts passando o nome da seção do servidor.
 
 Cada script realiza uma determinada tarefa:
 - rman_backup.pl -> realiza os backups full, incremental ou archive
 - rman_house_keeping.pl -> faz a limpeza de diretórios e manutenção do histórico
 - rman_report.pl -> recupera os status do backup para o dia informado e envia email para os DBAs
 - rman_restore.pl -> realiza a restauração do servidor de banco de dados para determinado timestamp
 - rman_show.pl -> printa na tela todos os backups realizados até o momento para determinado servidor
