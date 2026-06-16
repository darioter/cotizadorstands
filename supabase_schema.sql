-- ============================================================
-- STAND ESTIMATOR — Schema Supabase
-- Ejecutar en SQL Editor de Supabase
-- ============================================================

-- Habilitar extensión UUID
create extension if not exists "uuid-ossp";

-- ─── PERFILES DE USUARIO ─────────────────────────────────────
create table if not exists profiles (
  id uuid references auth.users on delete cascade primary key,
  email text,
  full_name text,
  role text default 'member' check (role in ('admin', 'member')),
  avatar_url text,
  created_at timestamptz default now()
);

-- Auto-crear perfil al registrar usuario
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name)
  values (new.id, new.email, coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)));
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure handle_new_user();

-- ─── BASE DE COSTOS (compartida por el equipo) ───────────────
create table if not exists rubros (
  id uuid default uuid_generate_v4() primary key,
  label text not null,
  icon text default '📦',
  proveedor text default '',
  usd_m2 numeric(10,2) not null default 0,
  notas text default '',
  orden integer default 0,
  activo boolean default true,
  updated_by uuid references profiles(id),
  updated_at timestamptz default now(),
  created_at timestamptz default now()
);

-- ─── PROYECTOS ────────────────────────────────────────────────
create table if not exists proyectos (
  id uuid default uuid_generate_v4() primary key,
  nombre text not null,
  cliente text default '',
  brief_texto text default '',
  superficie_m2 numeric(10,2),
  resultado jsonb,               -- respuesta completa de Claude
  estado text default 'borrador' check (estado in ('borrador', 'enviado', 'aprobado', 'rechazado')),
  created_by uuid references profiles(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ─── HISTORIAL DE CAMBIOS EN RUBROS ─────────────────────────
create table if not exists rubros_historial (
  id uuid default uuid_generate_v4() primary key,
  rubro_id uuid references rubros(id) on delete cascade,
  usd_m2_anterior numeric(10,2),
  usd_m2_nuevo numeric(10,2),
  motivo text default '',       -- ej: "Actualización inflación 8%"
  changed_by uuid references profiles(id),
  changed_at timestamptz default now()
);

-- ─── RLS (Row Level Security) ─────────────────────────────────
alter table profiles enable row level security;
alter table rubros enable row level security;
alter table proyectos enable row level security;
alter table rubros_historial enable row level security;

-- Profiles: cada uno ve el suyo, admins ven todos
create policy "profiles_select" on profiles for select using (auth.uid() = id);
create policy "profiles_update" on profiles for update using (auth.uid() = id);

-- Rubros: todos los autenticados pueden leer y escribir
create policy "rubros_select" on rubros for select to authenticated using (true);
create policy "rubros_insert" on rubros for insert to authenticated with check (true);
create policy "rubros_update" on rubros for update to authenticated using (true);
create policy "rubros_delete" on rubros for delete to authenticated using (true);

-- Historial: todos leen, solo se inserta automáticamente
create policy "historial_select" on rubros_historial for select to authenticated using (true);
create policy "historial_insert" on rubros_historial for insert to authenticated with check (true);

-- Proyectos: todos los autenticados ven y crean
create policy "proyectos_select" on proyectos for select to authenticated using (true);
create policy "proyectos_insert" on proyectos for insert to authenticated with check (true);
create policy "proyectos_update" on proyectos for update to authenticated using (true);
create policy "proyectos_delete" on proyectos for delete to authenticated using (created_by = auth.uid());

-- ─── DATOS INICIALES (rubros por defecto) ────────────────────
insert into rubros (label, icon, proveedor, usd_m2, notas, orden) values
  ('Estructura / Sistema constructivo', '🏗', '', 180, 'Aluminio modular, madera, steel frame', 1),
  ('Revestimientos y terminaciones',    '🪵', '', 90,  'MDF laqueado, melamina, vinílico', 2),
  ('Gráfica y señalética',              '🖨', '', 45,  'Impresión gran formato, lonas, vinilos', 3),
  ('Iluminación',                       '💡', '', 55,  'LED, spots, iluminación ambiental', 4),
  ('Mobiliario',                        '🪑', '', 70,  'Mesas, sillas, mostradores, vitrinas', 5),
  ('Instalación eléctrica',             '⚡', '', 30,  'Tablero, cableado, tomas, potencia', 6),
  ('Mano de obra / Montaje',            '👷', '', 60,  'Armado, desmontaje, transporte', 7),
  ('Flores / Decoración',               '🌿', '', 20,  'Plantas, ambientación, props', 8),
  ('Audiovisual / Tecnología',          '📺', '', 40,  'Pantallas, monitores, sonido', 9),
  ('Honorarios de diseño',              '✏️', 'DALI Arquitectura 360°', 35, 'Diseño, proyecto ejecutivo, dirección', 10)
on conflict do nothing;
