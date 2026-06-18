-- ============================================================
-- RUBRO ENTELADOS — Insertar en Supabase SQL Editor
-- ============================================================

-- Primero limpiar si ya existe el rubro
DELETE FROM catalogo WHERE rubro = 'entelados';

-- Insertar ítems
INSERT INTO catalogo (id, rubro, label, unit, precio, activo, orden) VALUES
  ('entelados_000', 'entelados', 'Set de poliéster — provisión y colocación', 'm lineal', 26000, true, 0),
  ('entelados_001', 'entelados', 'Set de poliéster — provisión y colocación', 'm²', 17000, true, 1),
  ('entelados_002', 'entelados', 'Set de poliéster y nylon — provisión y colocación', 'm lineal', 31000, true, 2),
  ('entelados_003', 'entelados', 'Set de poliéster y nylon — provisión y colocación', 'm²', 20000, true, 3),
  ('entelados_004', 'entelados', 'Tela impresa — solo colocación', 'm lineal', 18000, true, 4),
  ('entelados_005', 'entelados', 'Tela impresa — solo colocación', 'm²', 12000, true, 5),
  ('entelados_006', 'entelados', 'Tela impresa con nylon — solo colocación', 'm lineal', 22000, true, 6),
  ('entelados_007', 'entelados', 'Tela impresa con nylon — solo colocación', 'm²', 14000, true, 7),
  ('entelados_008', 'entelados', 'Tela impresa con nylon — solo provisión y confección', 'm lineal', 18000, true, 8),
  ('entelados_009', 'entelados', 'Tela impresa con nylon — solo provisión y confección', 'm²', 12000, true, 9),
  ('entelados_010', 'entelados', 'Tela voile', 'm lineal', 25000, true, 10),
  ('entelados_011', 'entelados', 'Tela voile', 'm²', 12000, true, 11),
  ('entelados_012', 'entelados', 'Bastidor de madera entelado (listones 1x1) — mín. 10m', 'm²', 36000, true, 12),
  ('entelados_013', 'entelados', 'Bastidor de madera entelado (listones 2x1) — mín. 10m', 'm²', 45000, true, 13),
  ('entelados_014', 'entelados', 'Cortinas de hilo', 'm²', 50000, true, 14),
  ('entelados_015', 'entelados', 'Alquiler telón hasta 3,00m de altura', 'm lineal', 45000, true, 15),
  ('entelados_016', 'entelados', 'Alquiler telón hasta 5,00m de altura', 'm lineal', 60000, true, 16),
  ('entelados_017', 'entelados', 'Alquiler telón hasta 6,50m de altura', 'm lineal', 70000, true, 17),
  ('entelados_018', 'entelados', 'Alquiler telón hasta 11,00m de altura', 'm lineal', 75000, true, 18);

-- Verificar
SELECT id, label, unit, precio FROM catalogo WHERE rubro = 'entelados' ORDER BY orden;
