import { execFileSync } from "node:child_process";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import os from "node:os";
import path from "node:path";

const SECTION = "## 🌐 Global Memory";

function resolveWorkspaceDir(event: any): string | undefined {
  // command:new event has context.cfg, not context.workspaceDir
  const cfg = event.context?.cfg as any;
  const sessionKey: string = event.sessionKey ?? "";

  // sessionKey format: "agent:r2d2:main" → agentId = "r2d2"
  const agentId = sessionKey.split(":")[1];
  if (!agentId) return undefined;

  // Try to look up workspace from cfg.agents.list
  const agentList: any[] = cfg?.agents?.list ?? [];
  const agentCfg = agentList.find(
    (a: any) => (a.id ?? "").toLowerCase() === agentId.toLowerCase(),
  );
  if (agentCfg?.workspace) {
    return agentCfg.workspace.replace(/^~/, os.homedir());
  }

  // Fallback: ~/.openclaw/workspace-{agentId}
  return path.join(os.homedir(), ".openclaw", `workspace-${agentId}`);
}

function resolveAgentCategories(event: any, agentId: string): string[] | null {
  // Returns null = no filter (inject all), string[] = allowed categories for this agent
  const cfg = event.context?.cfg as any;
  const hookEntries = cfg?.hooks?.internal?.entries ?? {};
  const hookCfg = hookEntries["global-memory-inject"] ?? {};
  const agentCategories = hookCfg.agentCategories ?? {};
  const allowed = agentCategories[agentId];
  if (!Array.isArray(allowed) || allowed.length === 0) return null;
  return allowed as string[];
}

const handler = async (event: any) => {
  if (event.type !== "command" || event.action !== "new") return;

  const workspaceDir = resolveWorkspaceDir(event);
  if (!workspaceDir) return;

  const sessionKey: string = event.sessionKey ?? "";
  const agentId = sessionKey.split(":")[1] ?? "";

  const userMdPath = path.join(workspaceDir, "USER.md");
  if (!existsSync(userMdPath)) return;

  try {
    const raw = execFileSync(
      "mcporter",
      ["call", "globalmemory.list_memories"], // TODO: at 200+ memories, switch to search_memory with a session-derived query + maxItems cap
      { encoding: "utf-8", timeout: 15000 },
    );

    const parsed = JSON.parse(raw);
    let items: Array<{ memory: string; categories?: string[] }> =
      Array.isArray(parsed) ? parsed : (parsed.results ?? []);

    if (!items.length) return;

    // Apply per-agent category filter if configured
    const allowedCategories = resolveAgentCategories(event, agentId);
    if (allowedCategories !== null) {
      items = items.filter((item) =>
        (item.categories ?? []).some((c) => allowedCategories.includes(c)),
      );
      if (!items.length) return;
    }

    const sorted = [...items].sort((a, b) =>
      (a.categories?.[0] ?? "zzz").localeCompare(b.categories?.[0] ?? "zzz"),
    );

    const lines = sorted.map((item) => {
      const cats = item.categories ?? [];
      const tags = cats.length ? `[${cats.join(", ")}] ` : "";
      return `- ${tags}${item.memory}`;
    });

    const newSection = `${SECTION}\n\n> ⚡ Auto-updated on every /new — do not edit this section manually.\n\n${lines.join("\n")}`;

    const existing = readFileSync(userMdPath, "utf-8");
    const idx = existing.indexOf(SECTION);

    let updated: string;
    if (idx >= 0) {
      const next = existing.indexOf("\n## ", idx + 1);
      updated =
        next >= 0
          ? existing.slice(0, idx) + newSection + "\n" + existing.slice(next)
          : existing.slice(0, idx) + newSection + "\n";
    } else {
      updated = existing.trimEnd() + "\n\n" + newSection + "\n";
    }

    writeFileSync(userMdPath, updated, "utf-8");
  } catch (err) {
    console.warn("[global-memory-inject]", String(err));
  }
};

export default handler;
