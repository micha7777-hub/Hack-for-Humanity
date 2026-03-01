import dotenv from "dotenv";
dotenv.config();

import express from "express";
import cors from "cors";

import insightsRoutes from "./routes/insights.routes.js";

const app = express();
app.use(cors());
app.use(express.json());

// ✅ register
app.use("/api/insights", insightsRoutes);

app.get("/health", (req, res) => res.json({ ok: true }));

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => console.log(`Backend running on ${PORT}`));
