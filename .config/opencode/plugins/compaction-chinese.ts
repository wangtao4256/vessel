import type { Plugin } from "@opencode-ai/plugin"

export const CompactionChinesePlugin: Plugin = async (ctx) => {
  return {
    "experimental.session.compacting": async (input, output) => {
      output.context.push("重要：请使用中文输出总结内容。")
    },
  }
}
