create table public.evenings (
  code text primary key check (code ~ '^[A-HJKMNP-Z2-9]{8}$'),
  host_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  data jsonb not null check (pg_column_size(data) < 16384),
  rsvps jsonb not null default '[]'::jsonb check (jsonb_typeof(rsvps) = 'array' and jsonb_array_length(rsvps) <= 200),
  updated_at timestamptz not null default now()
);

alter table public.evenings enable row level security;

create policy "hosts read their evenings" on public.evenings
  for select to authenticated using (host_id = auth.uid());

create policy "hosts delete their evenings" on public.evenings
  for delete to authenticated using (host_id = auth.uid());

create or replace function public.evening_row(e public.evenings)
returns jsonb language sql stable as $$
  select jsonb_build_object('data', e.data, 'rsvps', e.rsvps);
$$;

create or replace function public.publish_evening(p_code text, p_data jsonb, p_rsvps jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  found public.evenings;
begin
  if auth.uid() is null then
    raise exception 'not signed in' using errcode = '28000';
  end if;
  select * into found from public.evenings where code = p_code for update;
  if found.code is null then
    insert into public.evenings (code, host_id, data, rsvps)
    values (p_code, auth.uid(), p_data, coalesce(p_rsvps, '[]'::jsonb))
    returning * into found;
  elsif found.host_id <> auth.uid() then
    raise exception 'not the host' using errcode = '42501';
  else
    update public.evenings
    set data = p_data,
        rsvps = (
          select coalesce(jsonb_agg(r), '[]'::jsonb) from (
            select r from jsonb_array_elements(found.rsvps) r
            where not exists (
              select 1 from jsonb_array_elements(coalesce(p_rsvps, '[]'::jsonb)) h
              where h->>'id' = r->>'id'
            )
            union all
            select h from jsonb_array_elements(coalesce(p_rsvps, '[]'::jsonb)) h
          ) merged(r)
        ),
        updated_at = now()
    where code = p_code
    returning * into found;
  end if;
  return public.evening_row(found);
end;
$$;

create or replace function public.get_evening(p_code text)
returns jsonb language sql stable security definer set search_path = public as $$
  select public.evening_row(e) from public.evenings e
  where e.code = upper(p_code) and auth.uid() is not null;
$$;

create or replace function public.answer_evening(p_code text, p_rsvp jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  found public.evenings;
  rsvp jsonb;
begin
  if auth.uid() is null then
    raise exception 'not signed in' using errcode = '28000';
  end if;
  if coalesce(p_rsvp->>'answer', '') not in ('yes', 'maybe', 'no')
     or char_length(coalesce(p_rsvp->>'name', '')) not between 1 and 40 then
    raise exception 'invalid answer' using errcode = '22023';
  end if;
  select * into found from public.evenings where code = upper(p_code) for update;
  if found.code is null then
    raise exception 'unknown evening' using errcode = 'P0002';
  end if;
  rsvp := jsonb_build_object(
    'id', case when found.host_id = auth.uid() then coalesce(p_rsvp->>'id', auth.uid()::text) else auth.uid()::text end,
    'name', p_rsvp->>'name',
    'answer', p_rsvp->>'answer',
    'at', coalesce(
      (select r->>'at' from jsonb_array_elements(found.rsvps) r
       where r->>'id' = case when found.host_id = auth.uid() then p_rsvp->>'id' else auth.uid()::text end
         and r->>'answer' = p_rsvp->>'answer'),
      to_char(now() at time zone 'utc', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')
    )
  );
  update public.evenings
  set rsvps = (
        select coalesce(jsonb_agg(r), '[]'::jsonb)
        from jsonb_array_elements(found.rsvps) r
        where r->>'id' <> rsvp->>'id'
      ) || jsonb_build_array(rsvp),
      updated_at = now()
  where code = found.code
  returning * into found;
  return public.evening_row(found);
end;
$$;

revoke all on function public.publish_evening(text, jsonb, jsonb) from public, anon;
revoke all on function public.get_evening(text) from public, anon;
revoke all on function public.answer_evening(text, jsonb) from public, anon;
grant execute on function public.publish_evening(text, jsonb, jsonb) to authenticated;
grant execute on function public.get_evening(text) to authenticated;
grant execute on function public.answer_evening(text, jsonb) to authenticated;
