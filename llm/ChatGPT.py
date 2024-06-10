import openai
import os


class ChatGPT():
    def __init__(self, base_url=os.getenv("OPENAI_API_BASE_URL"), model_path = os.getenv("OPENAI_API_MODEL"), api_key = os.getenv('OPENAI_API_KEY')):
        self.api_key = api_key
        self.api_base = base_url
        self.llm = openai.OpenAI(api_key=self.api_key, base_url=self.api_base)
        self.model_path = model_path

    def chat(self, message):
        response = self.llm.chat.completions.create(
            model=self.model_path,
            messages=[
                {"role": "user", "content": message}
            ]
        )
        return response.choices[0].message.content

    # def openai_inference(sys_prompt, user_prompt):
    #     completion = client.chat.completions.create(
    #     model=os.getenv("OPENAI_API_MODEL"),
    #     messages=[
    #         {"role": "system", "content": sys_prompt},
    #         {"role": "user", "content": user_prompt}
    #     ]
    #     )

    #     return completion.choices[0].message.content