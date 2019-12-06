declare @winlogins table
(acct_name sysname,
acct_type varchar(10),
act_priv varchar(10),
login_name sysname,
perm_path sysname)

declare @group sysname

declare recscan cursor for
select name from sys.server_principals
where type = 'G' and name not like 'NT%'

open recscan
fetch next from recscan into @group

while @@FETCH_STATUS = 0
begin
insert into @winlogins
exec xp_logininfo @group,'members'
fetch next from recscan into @group
end
close recscan
deallocate recscan


select DISTINCT

  CASE 
	when u.type = 'G' then wl.login_name
	when u.type != 'G' then u.name	
END  as 'testUsername',

u.is_disabled

from (select * from sys.server_principals where type = 'R') r
join sys.server_role_members rm on (r.principal_id = rm.role_principal_id) 
join (select * from sys.server_principals where type != 'R') u on rm.member_principal_id = u.principal_id and u.name not like 'NT SERVICE%' and u.name not like 'NT AUTH%'
left join @winlogins wl on u.name = wl.perm_path 
order by u.is_disabled


