from telethon import TelegramClient, events

import requests
import json
import os
from dotenv import load_dotenv

# load variables from .env (if present) into environment
load_dotenv()

# credentials must be set in env or in a .env file
api_id = int(os.getenv("TG_API_ID", "0"))
api_hash = os.getenv("TG_API_HASH", "")
slack_webhook_url = os.getenv("SLACK_WEBHOOK_URL", "")
telegram_chat_id = int(os.getenv("TG_CHAT_ID", -1))

if not api_id or not api_hash:
    raise RuntimeError("Telegram API credentials not found; set TG_API_ID and TG_API_HASH in your environment")

WATCH_CHATS = [
    -1001936325983,
    -1003839416460, 
]

KEYWORDS = [
    'XAU',
    'XAUUSD',
    'USDXAU',
    'XAU/USD',
    'USD/XAU'
]

def match_keywords(text: str):
    if not text:
        return []
    t = text.lower()
    return [kw for kw in KEYWORDS if kw.lower() in t]

client = TelegramClient("telegramkeywords", api_id, api_hash)

async def build_watch_peers():
    # Warm up entity cache so IDs/usernames can be resolved
    await client.get_dialogs()

    peers = []
    for chat in WATCH_CHATS:
        try:
            peer = await client.get_input_entity(chat)
            peers.append(peer)
        except Exception as e:
            print(f"[WARN] Could not resolve {chat!r}. Are you a member? Error: {e}")
    return peers

async def main():
    await client.start()
    print("Running keyword alerts userbot...")

    watch_peers = await build_watch_peers()
    if not watch_peers:
        raise RuntimeError(
            "No WATCH_CHATS could be resolved. Use @username, or join the chat first, or verify the ID."
        )

    @client.on(events.NewMessage(chats=watch_peers))
    async def handler(event):
        text = event.raw_text or ""
        hits = match_keywords(text.upper())
        if not hits:
            return

        chat = await event.get_chat()
        chat_name = (
            getattr(chat, "title", None)
            or getattr(chat, "username", None)
            or str(event.chat_id)
        )

        sender = await event.get_sender()
        sender_name = (
            getattr(sender, "username", None)
            or getattr(sender, "first_name", None)
            or ""
        )

        link = ""
        cid = str(event.chat_id)
        if cid.startswith("-100"):
            link = f"https://t.me/c/{cid[4:]}/{event.id}"

        # Build the message without any "\n" inside {...} expressions
        lines = [
            f"Keyword hit: {', '.join(hits)}",
            f"Chat: {chat_name}",
            f"From: {sender_name}",
        ]
        if link:
            lines.append(f"Link: {link}")
        lines.append("Message:")
        lines.append(text)

        alert = "\n".join(lines)
        await execute_telegram_message(alert)
        execute_slack_message(alert)

    async def execute_telegram_message(alert):
        peer = await client.get_input_entity(telegram_chat_id)
        await client.send_message(peer, alert)

    def execute_slack_message(alert):
        payload = {"text": alert}

        resp = requests.post(
            slack_webhook_url,
            data=json.dumps(payload),
            headers={"Content-Type": "application/json"},
            timeout=10,
        )

        resp.raise_for_status()

    await client.run_until_disconnected()

if __name__ == "__main__":
    client.loop.run_until_complete(main())