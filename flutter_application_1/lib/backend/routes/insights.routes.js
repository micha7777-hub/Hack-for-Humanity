import express from "express";
import axios from "axios";

const router = express.Router();

/**
 * Expect POST body:
 * { transactions: [ { title, category, amount, isIncome, date } ] }
 *
 * date should be ISO string: "2026-03-01T01:23:45.000Z"
 */
router.post("/", async (req, res) => {
  try {
    const { transactions } = req.body;
    if (!Array.isArray(transactions)) {
      return res.status(400).json({ error: "transactions must be an array" });
    }

    // ---- 1) Normalize + filter expenses ----
    const txs = transactions.map((t) => ({
      title: String(t.title ?? ""),
      category: String(t.category ?? "General"),
      amount: Number(t.amount ?? 0),
      isIncome: Boolean(t.isIncome),
      date: new Date(t.date ?? Date.now()),
    }));

    const expenses = txs.filter((t) => !t.isIncome && t.amount > 0);

    // Helper: sum in a date range
    const sumInRange = (arr, start, end) =>
      arr
        .filter((t) => t.date >= start && t.date < end)
        .reduce((acc, t) => acc + t.amount, 0);

    const now = new Date();
    const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    // ---- 2) Windows: last 7 days vs previous 7 days ----
    const last7Start = new Date(startOfToday);
    last7Start.setDate(last7Start.getDate() - 7);

    const prev7Start = new Date(startOfToday);
    prev7Start.setDate(prev7Start.getDate() - 14);

    const prev7End = new Date(startOfToday);
    prev7End.setDate(prev7End.getDate() - 7);

    const spendLast7 = sumInRange(expenses, last7Start, startOfToday);
    const spendPrev7 = sumInRange(expenses, prev7Start, prev7End);

    const weeklyChangePct =
      spendPrev7 === 0 ? (spendLast7 === 0 ? 0 : 100) : ((spendLast7 - spendPrev7) / spendPrev7) * 100;

    // ---- 3) Rising categories (last7 vs prev7) ----
    const groupByCategory = (arr, start, end) => {
      const map = new Map();
      for (const t of arr) {
        if (t.date < start || t.date >= end) continue;
        map.set(t.category, (map.get(t.category) || 0) + t.amount);
      }
      return map;
    };

    const last7ByCat = groupByCategory(expenses, last7Start, startOfToday);
    const prev7ByCat = groupByCategory(expenses, prev7Start, prev7End);

    const allCats = new Set([...last7ByCat.keys(), ...prev7ByCat.keys()]);
    const rising = [...allCats].map((cat) => {
      const a = last7ByCat.get(cat) || 0;
      const b = prev7ByCat.get(cat) || 0;
      return {
        category: cat,
        last7: a,
        prev7: b,
        delta: a - b,
        deltaPct: b === 0 ? (a === 0 ? 0 : 100) : ((a - b) / b) * 100,
      };
    });

    rising.sort((x, y) => y.delta - x.delta);
    const topRisingCategories = rising.filter((r) => r.delta > 0).slice(0, 3);

    // ---- 4) End-of-month projection (based on current pace) ----
    const year = now.getFullYear();
    const month = now.getMonth();
    const startOfMonth = new Date(year, month, 1);
    const startOfNextMonth = new Date(year, month + 1, 1);

    const spendMonthSoFar = sumInRange(expenses, startOfMonth, now);
    const dayOfMonth = now.getDate(); // 1..31
    const daysInMonth = Math.round((startOfNextMonth - startOfMonth) / (1000 * 60 * 60 * 24));

    const projectedMonthSpend = dayOfMonth === 0 ? spendMonthSoFar : (spendMonthSoFar / dayOfMonth) * daysInMonth;

    // ---- 5) Anomaly/spike detection (simple: mean + 2*std on last 30 days) ----
    const last30Start = new Date(startOfToday);
    last30Start.setDate(last30Start.getDate() - 30);

    const last30 = expenses.filter((t) => t.date >= last30Start && t.date < startOfToday);
    const amounts = last30.map((t) => t.amount);

    const mean = amounts.length ? amounts.reduce((a, b) => a + b, 0) / amounts.length : 0;
    const variance =
      amounts.length ? amounts.reduce((acc, x) => acc + (x - mean) ** 2, 0) / amounts.length : 0;
    const std = Math.sqrt(variance);
    const threshold = mean + 2 * std;

    const anomalies = last30
      .filter((t) => t.amount > threshold)
      .sort((a, b) => b.amount - a.amount)
      .slice(0, 5)
      .map((t) => ({
        title: t.title,
        category: t.category,
        amount: t.amount,
        date: t.date.toISOString(),
      }));

    // ---- Build insights payload ----
    const insights = {
      weeklySpendingChangePct: weeklyChangePct,
      spendLast7,
      spendPrev7,
      topRisingCategories,
      projectedMonthSpend,
      spendMonthSoFar,
      anomalies,
    };

    // ---- 6) Groq: exactly 5 actionable tips (based ONLY on computed insights) ----
    const tips = await generate5TipsWithGroq(insights);

    return res.json({ insights, tips });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "server_error", details: String(err?.message ?? err) });
  }
});

async function generate5TipsWithGroq(insights) {
  const apiKey = process.env.GROQ_API_KEY;
  if (!apiKey) return ["Missing GROQ_API_KEY in backend .env"];

  const prompt = `
You are a financial coach.
You MUST output EXACTLY 5 bullet points.
Each bullet must be one sentence, actionable, and based ONLY on the JSON data below.
Do NOT invent numbers or categories not in the JSON.

JSON:
${JSON.stringify(insights, null, 2)}
`;

  const resp = await axios.post(
    "https://api.groq.com/openai/v1/chat/completions",
    {
      model: "llama-3.1-8b-instant",
      messages: [
        { role: "system", content: "Follow the user's instruction strictly." },
        { role: "user", content: prompt },
      ],
      temperature: 0.4,
    },
    {
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
    }
  );

  const text = resp.data?.choices?.[0]?.message?.content ?? "";
  const lines = text
    .split("\n")
    .map((l) => l.trim())
    .filter(Boolean);

  // keep only 5 bullets; sanitize if model adds extras
  const bullets = lines
    .map((l) => l.replace(/^[-*•]\s*/, ""))
    .filter((l) => l.length > 0)
    .slice(0, 5);

  // fallback if it didn't behave
  if (bullets.length !== 5) {
    return [
      "Review your top spending categories and set a hard cap for the highest one this week.",
      "If weekly spending is rising, pause discretionary purchases for 48 hours before buying.",
      "Set a mid-month checkpoint and compare your current pace to your end-of-month projection.",
      "Flag any anomaly transactions and decide if they were necessary or can be avoided next month.",
      "Move one small recurring expense to a cheaper alternative and save the difference automatically.",
    ];
  }

  return bullets;
}

export default router;