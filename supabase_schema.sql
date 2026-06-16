-- ============================================================
-- STAND ESTIMATOR v2 — Schema Supabase
-- Ejecutar COMPLETO en SQL Editor de Supabase
-- ============================================================

create extension if not exists "uuid-ossp";

-- PERFILES
create table if not exists profiles (
  id uuid references auth.users on delete cascade primary key,
  email text,
  full_name text,
  role text default 'member' check (role in ('admin','member')),
  created_at timestamptz default now()
);

create or replace function handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name)
  values (new.id, new.email, coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email,'@',1)));
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure handle_new_user();

-- CONFIG (parámetros + catálogo, guardados como JSON)
create table if not exists config (
  key text primary key,
  value text not null,
  updated_by uuid references profiles(id),
  updated_at timestamptz default now()
);

-- PROYECTOS
create table if not exists proyectos (
  id uuid default uuid_generate_v4() primary key,
  nombre text not null,
  cliente text default '',
  brief_texto text default '',
  superficie_m2 numeric(10,2),
  resultado jsonb,
  estado text default 'borrador' check (estado in ('borrador','enviado','aprobado','rechazado')),
  created_by uuid references profiles(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- HISTORIAL (para tracking de cambios de precios)
create table if not exists rubros_historial (
  id uuid default uuid_generate_v4() primary key,
  rubro_id uuid,
  usd_m2_anterior numeric(10,2),
  usd_m2_nuevo numeric(10,2),
  motivo text default '',
  changed_by uuid references profiles(id),
  changed_at timestamptz default now()
);

-- RLS
alter table profiles enable row level security;
alter table config enable row level security;
alter table proyectos enable row level security;
alter table rubros_historial enable row level security;

-- Profiles
drop policy if exists "profiles_select" on profiles;
drop policy if exists "profiles_update" on profiles;
create policy "profiles_select" on profiles for select to authenticated using (true);
create policy "profiles_update" on profiles for update using (auth.uid() = id);

-- Config: todos los autenticados leen y escriben
drop policy if exists "config_select" on config;
drop policy if exists "config_upsert" on config;
create policy "config_select" on config for select to authenticated using (true);
create policy "config_upsert" on config for all to authenticated using (true) with check (true);

-- Proyectos: todos leen, crean, actualizan los propios
drop policy if exists "proyectos_select" on proyectos;
drop policy if exists "proyectos_insert" on proyectos;
drop policy if exists "proyectos_update" on proyectos;
create policy "proyectos_select" on proyectos for select to authenticated using (true);
create policy "proyectos_insert" on proyectos for insert to authenticated with check (true);
create policy "proyectos_update" on proyectos for update to authenticated using (true);

-- Historial
drop policy if exists "historial_select" on rubros_historial;
drop policy if exists "historial_insert" on rubros_historial;
create policy "historial_select" on rubros_historial for select to authenticated using (true);
create policy "historial_insert" on rubros_historial for insert to authenticated with check (true);
