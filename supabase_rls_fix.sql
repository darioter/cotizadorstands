-- ============================================================
-- EJECUTAR EN SUPABASE SQL EDITOR
-- Habilita todas las operaciones en la tabla catalogo
-- ============================================================

-- Eliminar policies viejas
drop policy if exists "catalogo_select" on catalogo;
drop policy if exists "catalogo_all" on catalogo;
drop policy if exists "catalogo_insert" on catalogo;
drop policy if exists "catalogo_update" on catalogo;
drop policy if exists "catalogo_delete" on catalogo;

-- Crear policies explícitas para cada operación
create policy "catalogo_select" on catalogo
  for select to authenticated using (true);

create policy "catalogo_insert" on catalogo
  for insert to authenticated with check (true);

create policy "catalogo_update" on catalogo
  for update to authenticated using (true) with check (true);

create policy "catalogo_delete" on catalogo
  for delete to authenticated using (true);

-- Verificar
select schemaname, tablename, policyname, cmd 
from pg_policies 
where tablename = 'catalogo';
