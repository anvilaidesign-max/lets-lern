import { handleAiGameTurn } from "../_shared/ai_game.ts";
import type { GameSession } from "../_shared/ai_game.ts";
import { errorResponse } from "../_shared/http.ts";
import { adminClient, aiClient, getUserId, incrementUsage, log } from "../_shared/supabase_deps.ts";

const COLUMNS = "id, user_id, topic_code, mode, messages, score";

Deno.serve(async (req) => {
  try {
    return await handleAiGameTurn(req, {
      getUserId,
      incrementUsage,
      ai: aiClient(),
      log,
      async getSession(id) {
        const { data, error } = await adminClient()
          .from("ai_game_sessions")
          .select(COLUMNS)
          .eq("id", id)
          .maybeSingle();
        if (error) throw new Error(`getSession failed: ${error.message}`);
        return data as GameSession | null;
      },
      async createSession(row) {
        const { data, error } = await adminClient()
          .from("ai_game_sessions")
          .insert(row)
          .select(COLUMNS)
          .single();
        if (error || !data) throw new Error(`createSession failed: ${error?.message}`);
        return data as GameSession;
      },
      async saveSession(id, patch) {
        const { error } = await adminClient().from("ai_game_sessions").update(patch).eq("id", id);
        if (error) throw new Error(`saveSession failed: ${error.message}`);
      },
    });
  } catch (error) {
    log("ai-game-turn crashed", error);
    return errorResponse(500, "server_error", "Something went wrong. Please try again.");
  }
});
