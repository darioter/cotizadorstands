export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const { messages, mode } = req.body;
  if (!messages) return res.status(400).json({ error: 'Invalid request' });

  if (!process.env.ANTHROPIC_API_KEY) {
    return res.status(500).json({ error: 'ANTHROPIC_API_KEY no configurada. Ir a Vercel → Settings → Environment Variables y agregar la key.' });
  }

  const systemPrompts = {
    autofill: 'Sos un experto en producción de stands para ferias en Argentina. Sugerís cantidades realistas. Respondés ÚNICAMENTE con JSON válido, sin markdown.',
    design: 'Sos un arquitecto y diseñador de stands con 15 años de experiencia en Argentina. Generás propuestas conceptuales creativas. Respondés ÚNICAMENTE con JSON válido, sin markdown.',
    default: 'Sos un arquitecto y diseñador de stands experto. Respondés ÚNICAMENTE con JSON válido, sin markdown.',
  };

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
        system: systemPrompts[mode] || systemPrompts.default,
        messages,
      }),
    });

    if (!response.ok) {
      const err = await response.text();
      return res.status(response.status).json({ error: `Anthropic API error ${response.status}: ${err}` });
    }

    const data = await response.json();
    const text = data.content.filter(b => b.type === 'text').map(b => b.text).join('');
    return res.status(200).json({ text });
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
}
