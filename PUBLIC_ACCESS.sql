-- CELL QR TEAM V4: ПУБЛИЧНЫЙ ДОСТУП. ЛЮБОЙ С КЛЮЧОМ МОЖЕТ ИЗМЕНЯТЬ ЯЧЕЙКИ.
-- Выполнять ТОЛЬКО если разрешён публичный доступ к складским номерам.
-- В таблицах прямое изменение для anon НЕ открывается. Только функции.

grant usage on schema public to anon;
grant select(code,status) on public.cells to anon;

drop policy if exists "Guests view free cells" on public.cells;
create policy "Guests view free cells" on public.cells
for select to anon using (status='free');

create or replace function public.claim_cell(p_code text)
returns boolean language plpgsql security definer set search_path = '' as $$
begin
  update public.cells set status='occupied', occupied_by=null,
    occupied_at=now(), updated_at=now()
  where code=upper(trim(p_code)) and status='free';
  if not found then return false; end if;
  insert into public.cell_history(code,action,user_id)
  values (upper(trim(p_code)),'occupied',null);
  return true;
end; $$;

create or replace function public.import_cell(p_code text)
returns text language plpgsql security definer set search_path = '' as $$
declare c text:=upper(trim(p_code)); s text;
begin
  if length(c)>24 or not (c ~ '^ANO-CON[0-9]{1,6}$' or c ~ '^K(09|10)-[0-9]{1,3}[ABC][0-9]{1,3}$') then
    raise exception 'Invalid cell code';
  end if;
  insert into public.cells(code) values(c) on conflict(code) do nothing;
  if found then
    insert into public.cell_history(code,action,user_id) values(c,'added',null);
    return 'added';
  end if;
  select status into s from public.cells where code=c;
  if s='free' then return 'free'; end if;
  return 'occupied';
end; $$;

create or replace function public.release_cell(p_code text)
returns boolean language plpgsql security definer set search_path = '' as $$
begin
  update public.cells set status='free', occupied_by=null,
    occupied_at=null, updated_at=now()
  where code=upper(trim(p_code)) and status='occupied';
  if not found then return false; end if;
  insert into public.cell_history(code,action,user_id)
  values(upper(trim(p_code)),'released',null);
  return true;
end; $$;

revoke all on function public.claim_cell(text) from public,anon;
revoke all on function public.import_cell(text) from public,anon;
revoke all on function public.release_cell(text) from public,anon;
grant execute on function public.claim_cell(text) to anon,authenticated;
grant execute on function public.import_cell(text) to anon,authenticated;
grant execute on function public.release_cell(text) to anon,authenticated;
-- Важно: сохраняем политику authenticated, существовавшую раньше.
