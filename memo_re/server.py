from flask import Flask, request, jsonify
from transformers import pipeline
from IPython.display import Image
import openai

app = Flask(__name__)

# OpenAI API 키 설정
api_key = "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"

@app.route('/', methods=['POST'])
def generate_memory():
    text = request.form.get('text')
    
    # 이제 keyword를 사용하여 generate_memory 함수를 호출
    memory = generate_memory_from_openai(text)

    translate = memory_trans(memory)

    image_url = generate_image_from_memory(translate)

    # 이미지 URL과 메모리를 JSON 응답으로 반환
    response = {
        "memory": memory,
        "image_url": image_url
    }
    
    return jsonify(response)

def generate_memory_from_openai(keyword):
    prompt = f"넌 추억 생성기야. 내가 추억에 대한 키워드를 입력하면 내 추억에 대한 이야기를 말해줘야 돼. 키워드: {keyword}"

    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "넌 추억 생성기야. 내가 추억에 대한 키워드를 입력하면 내 추억에 대한 이야기를 말해줘야 돼.근데 키워드 각각의 이야기가 아니라 키워드가 전부 들어가는 이야기를 말해줘야 돼. 답변은 한번만 해주면 돼. 더 요구하지 마."},
            {"role": "user", "content": keyword}
        ],
        max_tokens=1000,  # 출력 최대 길이 설정.
        api_key=api_key
    )

    # API 응답에서 생성된 추억 추출
    generated_memory = response.choices[0].message["content"].strip()

    return generated_memory

def memory_trans(memory):  # 추억 번역기. 번역 안 하면, 이미지가 제대로 안 나옴.
    prompt = f"이 문장을 영어로 바꿔줘: {memory}"

    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "넌 번역기야 내가 넣는 문장을 영어로 바꿔줘."},
            {"role": "user", "content": memory}
        ],
        max_tokens=2000,  # 출력 최대 길이 설정.
        api_key=api_key
    )

    trans = response.choices[0].message["content"].strip()

    return trans

# 이미지 생성 함수를 정의
def generate_image_from_memory(trans):
    response = openai.Image.create(
        prompt=trans,  # memory를 사용
        api_key=api_key,
        n=1,
        size="1024x1024"
    )
    image_url = response['data'][0]['url']
    return image_url



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
