/**
 * FILE WORKER ĐỘC LẬP (1 FILE DUY NHẤT) CHO CLOUDFLARE WORKERS / PAGES FUNCTIONS
 * Bạn có thể copy toàn bộ file này dán thẳng vào mục "Edit Code" trên Cloudflare Workers Dashboard,
 * hoặc chạy lệnh CLI:
 *   npx wrangler deploy cloudflare/worker.js --name tdl-gacha-dragon-api --compatibility-date 2024-11-01
 */

const BASE_BOSS_HP = 18000;
const BASE_PARTICIPATION_GOLD = 1500;
const GOLD_PER_DAMAGE = 2;
const BOSS_DEFEAT_BONUS_GOLD = 8000;

function createDefaultBoss(level = 1) {
  const lv = Math.max(1, Number(level) || 1);
  const maxHp = BASE_BOSS_HP * lv;
  return {
    id: `abyss_world_dragon_${lv}`,
    name: "HẮC LONG ĐỊA TÂM",
    level: lv,
    max_hp: maxHp,
    hp: maxHp - 6310,
    participants: [
      { username: "Thợ Săn 1", damage: 0, attacks: 0, gold_earned: 0 },
      { username: "Thợ Săn 2", damage: 3420, attacks: 1, gold_earned: 8340 },
      { username: "Thợ Săn 3", damage: 2890, attacks: 1, gold_earned: 7280 }
    ],
    recent_logs: [
      "Thợ Săn 2 vừa gây 3.420 sát thương lên Hắc Long Địa Tâm (+8.340 Vàng)",
      "Thợ Săn 3 vừa gây 2.890 sát thương lên Hắc Long Địa Tâm (+7.280 Vàng)"
    ]
  };
}

const MEMORY_STORE = {
  users: {},
  boss: createDefaultBoss(1)
};

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization"
};

function jsonResponse(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      ...CORS_HEADERS
    }
  });
}

async function ensureD1Tables(env) {
  if (!env || !env.DB) return;
  await env.DB.prepare(
    `CREATE TABLE IF NOT EXISTS users (
      username TEXT PRIMARY KEY,
      password TEXT NOT NULL DEFAULT '123',
      save_json TEXT NOT NULL DEFAULT '{}',
      updated_at INTEGER NOT NULL DEFAULT 0
    )`
  ).run();
  await env.DB.prepare(
    `CREATE TABLE IF NOT EXISTS world_boss (
      id TEXT PRIMARY KEY,
      level INTEGER NOT NULL DEFAULT 1,
      max_hp INTEGER NOT NULL DEFAULT 18000,
      hp INTEGER NOT NULL DEFAULT 18000,
      participants_json TEXT NOT NULL DEFAULT '[]',
      logs_json TEXT NOT NULL DEFAULT '[]',
      updated_at INTEGER NOT NULL DEFAULT 0
    )`
  ).run();
}

async function getUserRecord(env, username) {
  if (env && env.DB) {
    await ensureD1Tables(env);
    const row = await env.DB.prepare("SELECT * FROM users WHERE username = ?").bind(username).first();
    if (!row) return null;
    return {
      username: row.username,
      password: row.password,
      save_data: JSON.parse(row.save_json || "{}")
    };
  }
  if (env && env.DRAGON_KV) {
    const raw = await env.DRAGON_KV.get(`user:${username}`);
    return raw ? JSON.parse(raw) : null;
  }
  return MEMORY_STORE.users[username] || null;
}

async function saveUserRecord(env, username, password, saveData) {
  const record = {
    username,
    password: password || "123",
    save_data: saveData || {},
    updated_at: Date.now()
  };
  if (env && env.DB) {
    await ensureD1Tables(env);
    await env.DB.prepare(
      `INSERT INTO users (username, password, save_json, updated_at)
       VALUES (?, ?, ?, ?)
       ON CONFLICT(username) DO UPDATE SET
         save_json = excluded.save_json,
         updated_at = excluded.updated_at`
    )
      .bind(username, record.password, JSON.stringify(record.save_data), record.updated_at)
      .run();
    return record;
  }
  if (env && env.DRAGON_KV) {
    await env.DRAGON_KV.put(`user:${username}`, JSON.stringify(record));
    return record;
  }
  MEMORY_STORE.users[username] = record;
  return record;
}

async function getBossState(env) {
  if (env && env.DB) {
    await ensureD1Tables(env);
    const row = await env.DB.prepare("SELECT * FROM world_boss WHERE id = 'current'").first();
    if (!row) {
      const initial = createDefaultBoss(1);
      await saveBossState(env, initial);
      return initial;
    }
    return {
      id: `abyss_world_dragon_${row.level}`,
      name: "HẮC LONG ĐỊA TÂM",
      level: Number(row.level || 1),
      max_hp: Number(row.max_hp || BASE_BOSS_HP),
      hp: Number(row.hp || 0),
      participants: JSON.parse(row.participants_json || "[]"),
      recent_logs: JSON.parse(row.logs_json || "[]")
    };
  }
  if (env && env.DRAGON_KV) {
    const raw = await env.DRAGON_KV.get("world_boss:current");
    if (!raw) {
      const initial = createDefaultBoss(1);
      await saveBossState(env, initial);
      return initial;
    }
    return JSON.parse(raw);
  }
  return MEMORY_STORE.boss;
}

async function saveBossState(env, boss) {
  if (env && env.DB) {
    await ensureD1Tables(env);
    await env.DB.prepare(
      `INSERT INTO world_boss (id, level, max_hp, hp, participants_json, logs_json, updated_at)
       VALUES ('current', ?, ?, ?, ?, ?, ?)
       ON CONFLICT(id) DO UPDATE SET
         level = excluded.level,
         max_hp = excluded.max_hp,
         hp = excluded.hp,
         participants_json = excluded.participants_json,
         logs_json = excluded.logs_json,
         updated_at = excluded.updated_at`
    )
      .bind(
        boss.level,
        boss.max_hp,
        boss.hp,
        JSON.stringify(boss.participants || []),
        JSON.stringify(boss.recent_logs || []),
        Date.now()
      )
      .run();
    return;
  }
  if (env && env.DRAGON_KV) {
    await env.DRAGON_KV.put("world_boss:current", JSON.stringify(boss));
    return;
  }
  MEMORY_STORE.boss = boss;
}

export async function handleApiRequest(request, env) {
  if (request.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
  }

  const url = new URL(request.url);
  const path = url.pathname.replace(/^\/api\/?/, "").replace(/\/$/, "");

  let body = {};
  if (request.method === "POST") {
    try {
      body = await request.json();
    } catch (_) {
      body = {};
    }
  }

  if (path === "login" && request.method === "POST") {
    const username = String(body.username || "Thợ Săn 1").trim();
    const password = String(body.password || "123").trim();
    const incomingSave = body.save_data || {};

    let user = await getUserRecord(env, username);
    let isNew = false;

    if (!user) {
      isNew = true;
      user = await saveUserRecord(env, username, password, incomingSave);
    } else if (user.password !== password && password !== "123") {
      return jsonResponse({ ok: false, message: "Mật khẩu không đúng!" }, 401);
    }

    const boss = await getBossState(env);
    if (!boss.participants.some((p) => p.username === username)) {
      if (boss.participants.length < 3) {
        boss.participants.push({ username, damage: 0, attacks: 0, gold_earned: 0 });
      } else {
        boss.participants[2] = { username, damage: 0, attacks: 0, gold_earned: 0 };
      }
      await saveBossState(env, boss);
    }

    return jsonResponse({
      ok: true,
      is_new: isNew,
      username: user.username,
      save_data: user.save_data,
      boss
    });
  }

  if (path === "save" && request.method === "POST") {
    const username = String(body.username || "Thợ Săn 1").trim();
    const saveData = body.save_data || {};
    const existing = await getUserRecord(env, username);
    await saveUserRecord(env, username, existing ? existing.password : "123", saveData);
    const boss = await getBossState(env);
    return jsonResponse({ ok: true, username, boss });
  }

  if (path === "boss" && request.method === "GET") {
    const boss = await getBossState(env);
    return jsonResponse({ ok: true, boss });
  }

  if (path === "boss/attack" && request.method === "POST") {
    const username = String(body.username || "Thợ Săn 1").trim();
    const damage = Math.max(100, Number(body.damage || 500));
    const boss = await getBossState(env);

    let slot = boss.participants.find((p) => p.username === username);
    if (!slot) {
      if (boss.participants.length < 3) {
        slot = { username, damage: 0, attacks: 0, gold_earned: 0 };
        boss.participants.push(slot);
      } else {
        slot = boss.participants[2];
        slot.username = username;
      }
    }

    const actualDamage = Math.min(boss.hp, damage);
    const defeated = boss.hp - actualDamage <= 0;
    const goldReward = BASE_PARTICIPATION_GOLD + damage * GOLD_PER_DAMAGE + (defeated ? BOSS_DEFEAT_BONUS_GOLD : 0);

    slot.damage = Number(slot.damage || 0) + actualDamage;
    slot.attacks = Number(slot.attacks || 0) + 1;
    slot.gold_earned = Number(slot.gold_earned || 0) + goldReward;

    const totalDamage = boss.participants.reduce((sum, p) => sum + Number(p.damage || 0), 0);
    boss.hp = Math.max(0, boss.max_hp - totalDamage);
    boss.recent_logs.unshift(
      `${username} gây ${actualDamage} sát thương lên ${boss.name} (+${goldReward} Vàng${defeated ? " · HẠ GỤC BOSS!" : ""})`
    );
    boss.recent_logs = boss.recent_logs.slice(0, 8);

    await saveBossState(env, boss);

    if (body.save_data) {
      const existing = await getUserRecord(env, username);
      await saveUserRecord(env, username, existing ? existing.password : "123", body.save_data);
    }

    return jsonResponse({
      ok: true,
      damage: actualDamage,
      gold: goldReward,
      boss_defeated: defeated,
      boss
    });
  }

  if (path === "boss/next" && request.method === "POST") {
    const current = await getBossState(env);
    const nextLv = Number(current.level || 1) + 1;
    const nextBoss = createDefaultBoss(nextLv);
    nextBoss.hp = nextBoss.max_hp;
    nextBoss.participants = (current.participants || []).slice(0, 3).map((p) => ({
      username: p.username,
      damage: 0,
      attacks: 0,
      gold_earned: Number(p.gold_earned || 0)
    }));
    nextBoss.recent_logs = [
      `⚡ HẮC LONG ĐỊA TÂM CẤP ${nextLv} đã thức tỉnh với ${nextBoss.max_hp} HP! Tổ đội 3 người hãy hợp sức!`
    ];
    await saveBossState(env, nextBoss);
    return jsonResponse({ ok: true, boss: nextBoss });
  }

  const boss = await getBossState(env);
  return jsonResponse({
    ok: true,
    service: "TDL-gacha-Dragon Cloudflare Backend (D1 / KV / Edge Memory)",
    endpoints: ["POST /api/login", "POST /api/save", "GET /api/boss", "POST /api/boss/attack", "POST /api/boss/next"],
    boss
  });
}

export async function onRequest(context) {
  return handleApiRequest(context.request, context.env);
}

export default {
  async fetch(request, env) {
    return handleApiRequest(request, env);
  }
};
