create or replace function public.evening_row(e public.evenings)
returns jsonb language sql stable set search_path = '' as $$
  select pg_catalog.jsonb_build_object(
    'data', e.data,
    'rsvps', case
      when e.host_id = auth.uid() then e.rsvps
      else coalesce((
        select pg_catalog.jsonb_agg(
          case
            when elements.r->>'id' = auth.uid()::text then elements.r
            else elements.r || pg_catalog.jsonb_build_object(
              'id', 'guest:' || pg_catalog.left(pg_catalog.md5(e.code || ':' || (elements.r->>'id')), 16)
            )
          end
          order by elements.position
        )
        from pg_catalog.jsonb_array_elements(e.rsvps) with ordinality as elements(r, position)
      ), '[]'::jsonb)
    end
  );
$$;

create or replace function public.publish_evening(p_code text, p_data jsonb, p_rsvps jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  found public.evenings;
begin
  if auth.uid() is null then
    raise exception 'not signed in' using errcode = '28000';
  end if;
  select * into found from public.evenings where code = p_code for update;
  if found.code is null then
    insert into public.evenings (code, host_id, data, rsvps)
    values (p_code, auth.uid(), p_data, '[]'::jsonb)
    returning * into found;
  elsif found.host_id <> auth.uid() then
    raise exception 'not the host' using errcode = '42501';
  end if;
  update public.evenings
  set data = p_data,
      rsvps = (
        select coalesce(pg_catalog.jsonb_agg(merged.r), '[]'::jsonb) from (
          select r from pg_catalog.jsonb_array_elements(found.rsvps) r
          where exists (
            select 1 from auth.users u
            where u.id::text = r->>'id' and u.id <> found.host_id
          )
          or not exists (
            select 1 from pg_catalog.jsonb_array_elements(coalesce(p_rsvps, '[]'::jsonb)) h
            where h->>'id' = r->>'id'
          )
          union all
          select h from pg_catalog.jsonb_array_elements(coalesce(p_rsvps, '[]'::jsonb)) h
          where not exists (
            select 1 from auth.users u
            where u.id::text = h->>'id' and u.id <> found.host_id
          )
        ) merged(r)
      ),
      updated_at = pg_catalog.now()
  where code = found.code
  returning * into found;
  return public.evening_row(found);
end;
$$;

create or replace function public.get_evening(p_code text)
returns jsonb language sql stable security definer set search_path = '' as $$
  select public.evening_row(e) from public.evenings e
  where e.code = pg_catalog.upper(p_code) and auth.uid() is not null;
$$;

create or replace function public.answer_evening(p_code text, p_rsvp jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  found public.evenings;
  rsvp jsonb;
  target text;
begin
  if auth.uid() is null then
    raise exception 'not signed in' using errcode = '28000';
  end if;
  if coalesce(p_rsvp->>'answer', '') not in ('yes', 'maybe', 'no')
     or pg_catalog.char_length(coalesce(p_rsvp->>'name', '')) not between 1 and 40 then
    raise exception 'invalid answer' using errcode = '22023';
  end if;
  select * into found from public.evenings where code = pg_catalog.upper(p_code) for update;
  if found.code is null then
    raise exception 'unknown evening' using errcode = 'P0002';
  end if;
  target := case
    when found.host_id = auth.uid() then coalesce(p_rsvp->>'id', auth.uid()::text)
    else auth.uid()::text
  end;
  rsvp := pg_catalog.jsonb_build_object(
    'id', target,
    'name', p_rsvp->>'name',
    'answer', p_rsvp->>'answer',
    'at', coalesce(
      (select r->>'at' from pg_catalog.jsonb_array_elements(found.rsvps) r
       where r->>'id' = target and r->>'answer' = p_rsvp->>'answer'),
      pg_catalog.to_char(pg_catalog.now() at time zone 'utc', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')
    )
  );
  update public.evenings
  set rsvps = (
        select coalesce(pg_catalog.jsonb_agg(r), '[]'::jsonb)
        from pg_catalog.jsonb_array_elements(found.rsvps) r
        where r->>'id' <> target
      ) || pg_catalog.jsonb_build_array(rsvp),
      updated_at = pg_catalog.now()
  where code = found.code
  returning * into found;
  return public.evening_row(found);
end;
$$;

revoke all on function public.evening_row(public.evenings) from public, anon, authenticated;
revoke all on function public.publish_evening(text, jsonb, jsonb) from public, anon;
revoke all on function public.get_evening(text) from public, anon;
revoke all on function public.answer_evening(text, jsonb) from public, anon;
grant execute on function public.publish_evening(text, jsonb, jsonb) to authenticated;
grant execute on function public.get_evening(text) to authenticated;
grant execute on function public.answer_evening(text, jsonb) to authenticated;
