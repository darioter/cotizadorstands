-- ============================================================
-- CATÁLOGO DE PRECIOS — Schema nuevo
-- Ejecutar en SQL Editor de Supabase
-- ============================================================

create table if not exists catalogo (
  id text primary key,           -- ej: 'pisos_p1', 'equipamiento_s1'
  rubro text not null,           -- 'pisos', 'constructor', 'equipamiento', etc.
  label text not null,
  unit text default 'u',
  precio numeric(12,2) default 0,
  activo boolean default true,
  orden integer default 0,
  updated_by uuid references profiles(id),
  updated_at timestamptz default now(),
  created_at timestamptz default now()
);

alter table catalogo enable row level security;

drop policy if exists "catalogo_select" on catalogo;
drop policy if exists "catalogo_all" on catalogo;
create policy "catalogo_select" on catalogo for select to authenticated using (true);
create policy "catalogo_all" on catalogo for all to authenticated using (true) with check (true);

-- Índice por rubro para queries rápidas
create index if not exists catalogo_rubro_idx on catalogo(rubro, orden);

-- ── LIMPIEZA: borrar filas con IDs duplicados (pisos_pisos_xxx) ──
-- Ejecutar si los precios no aparecen después del primer guardado
DELETE FROM catalogo
WHERE id LIKE '%\_%\_%'  -- tiene más de un underscore en el prefijo
  AND (
    id LIKE 'pisos_pisos_%'
    OR id LIKE 'constructor_constructor_%'
    OR id LIKE 'vidrios_vidrios_%'
    OR id LIKE 'electricidad_electricidad_%'
    OR id LIKE 'grafica_grafica_%'
    OR id LIKE 'equipamiento_equipamiento_%'
    OR id LIKE 'audiovisual_audiovisual_%'
    OR id LIKE 'otros_otros_%'
    OR id LIKE 'indirectos_indirectos_%'
  );

-- Verificar qué quedó
SELECT rubro, count(*) as items FROM catalogo WHERE activo=true GROUP BY rubro ORDER BY rubro;
