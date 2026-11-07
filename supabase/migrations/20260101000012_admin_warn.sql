-- =============================================================================
-- SAIQI — 12 : avertissement envoyé à un utilisateur (traitement des plaintes)
-- =============================================================================

create or replace function public.admin_warn_user(p_profile_id uuid, p_message text)
returns void
language plpgsql security definer
set search_path = public
as $$
declare
  v_title text;
  v_lang  text;
begin
  perform public.require_admin_role('super_admin', 'support');
  if nullif(btrim(p_message), '') is null then
    perform public.raise_error('text_required');
  end if;
  select language into v_lang from public.profiles where id = p_profile_id;
  if not found then
    perform public.raise_error('profile_not_found');
  end if;

  v_title := case when v_lang = 'fr' then 'Avertissement de l''administration' else 'تنبيه من الإدارة' end;
  perform public.notify_raw(p_profile_id, v_title, btrim(p_message), jsonb_build_object('key', 'warning', 'screen', 'inbox'));
  perform public.log_audit('warn_user', 'profiles', p_profile_id, jsonb_build_object('message', btrim(p_message)));
end $$;

revoke all on function public.admin_warn_user(uuid, text) from public, anon, authenticated;
grant execute on function public.admin_warn_user(uuid, text) to authenticated;
