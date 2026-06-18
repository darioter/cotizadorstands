-- ============================================================
-- RECARGOS ENTELADOS — Agregar a Supabase SQL Editor
-- ============================================================

-- Obtener el orden máximo actual de entelados
-- Los recargos se agregan como ítems seleccionables al armar el PIP

INSERT INTO catalogo (id, rubro, label, unit, precio, activo, orden) VALUES
  ('entelados_020', 'entelados', 'Recargo domingos y feriados (30%)', 'global', 0, true, 20),
  ('entelados_021', 'entelados', 'Recargo altura mayor a 3m (50%) — excl. cielorrasos', 'global', 0, true, 21),
  ('entelados_022', 'entelados', 'Recargo menos de 5 días de anticipación (30%)', 'global', 0, true, 22)
ON CONFLICT (id) DO UPDATE SET label=EXCLUDED.label, orden=EXCLUDED.orden;

-- Verificar
SELECT id, label, unit, precio FROM catalogo WHERE rubro='entelados' ORDER BY orden;
