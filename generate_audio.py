import os
from gtts import gTTS

os.makedirs('src/matlab/assets/audio', exist_ok=True)

# Hindi
hi_texts = {
    0: "स्तर शून्य. आंखें स्वस्थ हैं. किसी रेफरल की आवश्यकता नहीं है.",
    1: "स्तर एक. हल्का मधुमेह रेटिनोपैथी. कृपया नियमित जांच कराएं.",
    2: "स्तर दो. मध्यम रेटिनोपैथी. डॉक्टर से सलाह लें.",
    3: "स्तर तीन. गंभीर रेटिनोपैथी. तत्काल रेफ़रल की आवश्यकता है!",
    4: "स्तर चार. बहुत गंभीर स्थिति. कृपया तुरंत डॉक्टर को दिखाएं!"
}

# Bengali
bn_texts = {
    0: "লেভেল শূন্য. চোখ সুস্থ আছে. কোন রেফারেলের প্রয়োজন নেই.",
    1: "লেভেল এক. হালকা ডায়াবেটিক রেটিনোপ্যাথি. নিয়মিত চেকআপ করুন.",
    2: "লেভেল দুই. মাঝারি রেটিনোপ্যাথি. ডাক্তারের পরামর্শ নিন.",
    3: "লেভেল তিন. গুরুতর রেটিনোপ্যাথি. অবিলম্বে রেফারেল প্রয়োজন!",
    4: "লেভেল চার. খুব গুরুতর অবস্থা. অবিলম্বে ডাক্তার দেখান!"
}

# English
en_texts = {
    0: "Level zero. Eyes are healthy. No referral needed.",
    1: "Level one. Mild diabetic retinopathy. Please get regular checkups.",
    2: "Level two. Moderate retinopathy. Consult a doctor.",
    3: "Level three. Severe retinopathy. Urgent referral required!",
    4: "Level four. Proliferative retinopathy. Please see a doctor immediately!"
}

for lvl, text in hi_texts.items():
    tts = gTTS(text, lang='hi')
    tts.save(f'src/matlab/assets/audio/hi_level_{lvl}.mp3')

for lvl, text in bn_texts.items():
    tts = gTTS(text, lang='bn')
    tts.save(f'src/matlab/assets/audio/bn_level_{lvl}.mp3')

for lvl, text in en_texts.items():
    tts = gTTS(text, lang='en')
    tts.save(f'src/matlab/assets/audio/en_level_{lvl}.mp3')

print("Audio files generated successfully!")
