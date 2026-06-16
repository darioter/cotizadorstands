# Stand Estimator — DALI Arquitectura 360°
App multi-usuario para cotizar stands con IA.

## Stack
- **Frontend**: HTML estático (sin build step)
- **Backend**: Vercel Serverless Function (`/api/estimate.js`)
- **DB / Auth**: Supabase
- **IA**: Claude Sonnet (Anthropic API)

---

## Setup paso a paso

### 1. Supabase
1. Crear proyecto en https://supabase.com
2. Ir a **SQL Editor** → pegar y ejecutar `supabase_schema.sql`
3. Copiar de **Settings → API**:
   - `Project URL` → `SUPABASE_URL`
   - `anon public` key → `SUPABASE_ANON_KEY`
4. En `public/index.html` líneas ~335-336, reemplazar:
   ```js
   const SUPABASE_URL = 'https://XXXX.supabase.co';
   const SUPABASE_ANON_KEY = 'eyJ...';
   ```

### 2. Vercel
1. Subir este repo a GitHub
2. Importar en https://vercel.com → New Project
3. En **Environment Variables** agregar:
   ```
   ANTHROPIC_API_KEY = sk-ant-...
   ```
4. Deploy → listo

### 3. Primer uso
- Registrarse con email/contraseña
- Confirmar email (llega de Supabase)
- Ir a **⚙ Base de costos** → cargar los valores reales de tus proveedores
- Crear el primer proyecto

---

## Estructura de archivos
```
stand-estimator/
├── public/
│   └── index.html          ← App completa (auth + estimador + proyectos + equipo)
├── api/
│   └── estimate.js         ← Proxy serverless para Claude API
├── vercel.json             ← Routing config
├── supabase_schema.sql     ← Schema completo con RLS
└── README.md
```

## Funcionalidades
- **Auth**: registro/login con Supabase Auth
- **Estimador**: brief + archivos (PDF/imagen) → estimado de costos + 2 propuestas de diseño
- **Base de costos**: tabla editable compartida, persistida en Supabase, con actualización por % de inflación e historial de cambios
- **Proyectos**: todos los estimados guardados, visibles para el equipo, con estado (borrador/enviado/aprobado/rechazado)
- **Equipo**: lista de miembros registrados
