import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { config } from 'dotenv';
import { markdownToBlocks } from '@tryfabric/martian';
import { Client } from '@notionhq/client';


const __filename = fileURLToPath(import.meta.url);
const PROJECT_ROOT = path.dirname(__filename);
config({ path: path.join(PROJECT_ROOT, '.env') });

const args = process.argv.slice(2);
const getArg = (flag) => {
  const idx = args.indexOf(flag);
  return idx !== -1 ? args[idx + 1] : null;
};

const filePath = getArg('--file');
const databaseId = getArg('--db') || process.env.DATABASE_ID;
const title = getArg('--title');

if (!filePath || !databaseId) {
  console.error('Usage: tonotion --file <path> --db <databaseId> [--title <your-title>]');
  process.exit(1);
}

const notion = new Client({ auth: process.env.NOTION_TOKEN });

async function main() {
  try {
    // Markdown読み込み
    const absolutePath = path.resolve(filePath);
    const mdContent = fs.readFileSync(absolutePath, 'utf8');

    // Markdown → Notionブロック変換
    const blocks = markdownToBlocks(mdContent);

    // titleが指定されていればそれを使用し、なければファイル名をタイトルにする
    const pageTitle = title || path.basename(filePath, '.md');

    // 最初の100ブロックでページ作成
    const firstBatch = blocks.slice(0, 100);
    const page = await notion.pages.create({
      parent: { database_id: databaseId },
      properties: {
        Title: {
          title: [{ text: { content: pageTitle } }]
        },
        Status: {
          select: { name: 'Active' }
        },
      },
      children: firstBatch
    });

    // 残りを100個ずつappend
    let cursor = 100;
    while (cursor < blocks.length) {
      const chunk = blocks.slice(cursor, cursor + 100);
      await notion.blocks.children.append({
        block_id: page.id,
        children: chunk
      });
      cursor += 100;
    }

    console.log(`Page created: https://www.notion.so/${page.id.replace(/-/g, '')}`);
  } catch (error) {
    console.error('Error uploading to Notion:', error.body || error.message);
    process.exit(1);
  }
}

main();
