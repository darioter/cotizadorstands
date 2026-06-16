// api/estimate.js — Vercel Serverless Function
// Proxy para Claude API (evita exponer la API key en el cliente)

export default async function handler(req, res) {
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  const { messages, rubros, sqm } = req.body;

  if (!messages || !Array.isArray(messages)) {
    return res.status(400).json({ error: "Invalid messages" });
  }

  // Construir contexto de rubros
  const rubrosActivos = (rubros || []).filter((r) => parseFloat(r.usd_m2) > 0);
  const totalBase = rubrosActivos.reduce((s, r) => s + parseFloat(r.usd_m2), 0);
  const rubrosCtx = rubrosActivos
    .map(
      (r) =>
        `- ${r.label}${r.proveedor ? ` (proveedor: ${r.proveedor})` : ""}: USD ${r.usd_m2}/m²${r.notas ? ` — ${r.notas}` : ""}`
    )
    .join("\n");

  const sqmNote = sqm ? `\nSuperficie indicada: ${sqm} m²` : "";

  const systemPrompt = `Sos un arquitecto y diseñador de stands con 15 años de experiencia en el mercado argentino. El estudio ya tiene una base de costos con valores reales de sus proveedores. Usá esos valores como base exacta de cálculo. Respondés ÚNICAMENTE con JSON válido, sin ningún texto adicional ni markdown.`;

  const costContext = {
    role: "user",
    content: `${sqmNote}

BASE DE COSTOS DE REFERENCIA DEL ESTUDIO (valores reales actualizados, usar EXACTAMENTE estos como base):
${rubrosCtx}
Total acumulado base: USD ${totalBase.toFixed(0)}/m²

INSTRUCCIONES:
- Usá los valores de la base de costos como punto de partida real y preciso.
- Podés ajustar cada rubro ±20% según la complejidad específica del proyecto y el brief.
- Si algún rubro no aplica, excluilo o reducilo y explicalo.
- Si el proyecto requiere algo no listado, podés agregar rubros adicionales.

Devolvé ÚNICAMENTE un JSON válido:
{
  "resumen_proyecto": "descripción breve",
  "superficie_m2": número o null,
  "categoria": "básico|intermedio|premium|alta gama",
  "costo_estimado": {
    "por_m2_min": número USD,
    "por_m2_max": número USD,
    "total_min": número USD,
    "total_max": número USD,
    "moneda": "USD"
  },
  "desglose_costos": [
    { "rubro": "nombre", "descripcion": "detalle", "costo_m2_usd": número, "porcentaje": número, "ajuste": "igual|aumentado|reducido|agregado" }
  ],
  "materialidades": [
    { "elemento": "nombre", "material_sugerido": "descripción", "observacion": "nota técnica" }
  ],
  "condicionantes": ["factor 1", "factor 2"],
  "propuestas": [
    {
      "name": "nombre creativo",
      "concept": "concepto en 5 palabras",
      "palette": [{ "hex": "#XXXXXX", "name": "nombre" }],
      "materials": ["material 1", "material 2", "material 3"],
      "spatial": "descripción espacial 2-3 oraciones",
      "features": ["elemento 1", "elemento 2", "elemento 3", "elemento 4"],
      "references": ["referencia 1", "referencia 2", "referencia 3"],
      "mood": "frase del espíritu de la propuesta"
    },
    { "name": "...", "concept": "...", "palette": [], "materials": [], "spatial": "...", "features": [], "references": [], "mood": "..." }
  ],
  "notas_finales": "consideraciones adicionales"
}`,
  };

  try {
    const response = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": process.env.ANTHROPIC_API_KEY,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({
        model: "claude-sonnet-4-6",
        max_tokens: 4000,
        system: systemPrompt,
        messages: [...messages, costContext],
      }),
    });

    if (!response.ok) {
      const err = await response.text();
      return res.status(response.status).json({ error: err });
    }

    const data = await response.json();
    const text = data.content
      .filter((b) => b.type === "text")
      .map((b) => b.text)
      .join("");

    const clean = text.replace(/```json\n?/g, "").replace(/```\n?/g, "").trim();
    const parsed = JSON.parse(clean);

    return res.status(200).json(parsed);
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
}
