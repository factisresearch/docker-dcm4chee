create database pacsdb;
grant all on pacsdb.* to 'pacs'@'%' identified by 'pacs';

create database arrdb;
grant all on arrdb.* to 'arr'@'%' identified by 'arr';
