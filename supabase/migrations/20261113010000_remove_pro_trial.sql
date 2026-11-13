-- Remove the no-card 30-day Pro trial (2026-11-13).
-- Pro now comes only from a store subscription (RevenueCat) or a partner code.
--  1) my_pro_status() no longer starts a trial on sign-in.
--  2) start_pro_trial() never creates a trial (older app builds still call it).
--  3) Every trial that is still active ends now.
-- Trial rows are kept, so trial_used stays true for those accounts.

create or replace function public.my_pro_status()
returns jsonb
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    return jsonb_build_object(
      'ok', false,
      'error', 'not_authenticated',
      'is_pro', false,
      'source', null,
      'ends_at', null,
      'days_left', 0,
      'trial_used', false,
      'partner_used', false
    );
  end if;
  return public._pro_status_payload(uid);
end;
$$;

create or replace function public.start_pro_trial()
returns jsonb
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;
  return public._pro_status_payload(uid) || jsonb_build_object(
    'ok', false,
    'error', 'trial_disabled'
  );
end;
$$;

update public.entitlement_periods
set ends_at = greatest(now(), starts_at + interval '1 second')
where source = 'trial'
  and ends_at > now();
