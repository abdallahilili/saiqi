-- Mini-shim compatible avec le sous-ensemble de pgTAP utilisé par supabase/tests/*.sql.
-- Chaque assertion émet un NOTICE « TAP|ok|n|description|diag » lu par run.mjs.
-- (utilisé uniquement par scripts/db-check — sur Supabase, les vrais tests utilisent l'extension pgTAP)

create or replace function public.tap_emit(p_ok boolean, p_desc text, p_diag text default '')
returns text language plpgsql as $$
declare n int := coalesce(nullif(current_setting('tap.n', true), '')::int, 0) + 1;
begin
  perform set_config('tap.n', n::text, false);
  raise notice 'TAP|%|%|%|%', case when p_ok then 'ok' else 'not ok' end, n, coalesce(p_desc, ''), coalesce(p_diag, '');
  return (case when p_ok then 'ok ' else 'not ok ' end) || n || ' - ' || coalesce(p_desc, '');
end $$;

create or replace function public.plan(p_count int) returns text language plpgsql as $$
begin
  perform set_config('tap.n', '0', false);
  perform set_config('tap.plan', p_count::text, false);
  return '1..' || p_count;
end $$;

create or replace function public.ok(p_cond boolean, p_desc text default '') returns text language sql as $$
  select public.tap_emit(coalesce(p_cond, false), p_desc, '');
$$;

create or replace function public.is(p_have anyelement, p_want anyelement, p_desc text default '') returns text language sql as $$
  select public.tap_emit(p_have is not distinct from p_want, p_desc,
         format('have: %s / want: %s', p_have, p_want));
$$;

create or replace function public.isnt(p_have anyelement, p_want anyelement, p_desc text default '') returns text language sql as $$
  select public.tap_emit(p_have is distinct from p_want, p_desc, format('unexpected: %s', p_have));
$$;

create or replace function public.lives_ok(p_sql text, p_desc text default '') returns text language plpgsql as $$
begin
  begin
    execute p_sql;
  exception when others then
    return public.tap_emit(false, p_desc, format('threw %s: %s', sqlstate, sqlerrm));
  end;
  return public.tap_emit(true, p_desc, '');
end $$;

create or replace function public.throws_ok(p_sql text, p_errcode text, p_errmsg text, p_desc text default '')
returns text language plpgsql as $$
begin
  begin
    execute p_sql;
  exception when others then
    if (p_errcode is null or sqlstate = p_errcode) and (p_errmsg is null or sqlerrm = p_errmsg) then
      return public.tap_emit(true, p_desc, '');
    end if;
    return public.tap_emit(false, p_desc, format('threw %s: %s — expected %s: %s', sqlstate, sqlerrm, p_errcode, p_errmsg));
  end;
  return public.tap_emit(false, p_desc, 'no exception raised');
end $$;

create or replace function public.is_empty(p_sql text, p_desc text default '') returns text language plpgsql as $$
declare n int;
begin
  execute format('select count(*) from (%s) q', p_sql) into n;
  return public.tap_emit(n = 0, p_desc, format('%s row(s) returned', n));
end $$;

create or replace function public.finish() returns setof text language plpgsql as $$
declare
  n int := coalesce(nullif(current_setting('tap.n', true), '')::int, 0);
  p int := coalesce(nullif(current_setting('tap.plan', true), '')::int, 0);
begin
  if n <> p then
    raise notice 'TAP|not ok|%|plan mismatch|planned % ran %', n + 1, p, n;
  end if;
  return;
end $$;

-- Droits explicites sur les fonctions du shim uniquement (les migrations révoquent le reste)
grant execute on function
  public.tap_emit(boolean, text, text), public.plan(int), public.ok(boolean, text),
  public.is(anyelement, anyelement, text), public.isnt(anyelement, anyelement, text),
  public.lives_ok(text, text), public.throws_ok(text, text, text, text),
  public.is_empty(text, text), public.finish()
to public;
