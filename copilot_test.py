import asyncio
from copilot import CopilotClient
import os


async def run_with_token():
    # Pass the token explicitly in the constructor.
    # Note: All configuration options in CopilotClient are keyword-only arguments.
    client = CopilotClient(github_token=os.environ["COPILOT_GITHUB_TOKEN"],
                           use_logged_in_user=False
                          )

    print("Starting client with explicit token...")
    await client.start()

    try:
        session = await client.create_session(model="auto")
        response = await session.send_and_wait(
            {"prompt": "Say hello from a script using a token!"}
        )
        print("\nResponse:", response.data.content)
    finally:
        await client.stop()


if __name__ == "__main__":
    asyncio.run(run_with_token())