// api/estimate.js — Vercel Serverless Function

export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const { messages, mode } = req.body;
  if (!messages) return res.status(400).json({ error: 'Invalid request' });

  const systemPrompts = {
    autofill: 'Sos un experto en producción de stands para ferias y exposiciones en Argentina. Analizás briefs y sugerís cantidades realistas de ítems. Respondés ÚNICAMENTE con JSON válido, sin markdown.',
    design: 'Sos un arquitecto y diseñador de stands con 15 años de experiencia en el mercado argentino. Generás propuestas de diseño conceptual creativas y alineadas con la marca del cliente. Respondés ÚNICAMENTE con JSON válido, sin markdown.',
    default: 'Sos un arquitecto y diseñador de stands experto. Respondés ÚNICAMENTE con JSON válido, sin markdown.',
  };

  const system = systemPrompts[mode] || systemPrompts.default;

  try {
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': process.env.ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model: 'claude-sonnet-4-6',
        max_tokens: 3000,
        system,
        messages,
      }),
    });

    if (!response.ok) {
      const err = await response.text();
      return res.status(response.status).json({ error: err });
    }

    const data = await response.json();
    const text = data.content.filter(b => b.type === 'text').map(b => b.text).join('');
    return res.status(200).json({ text });
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
}
