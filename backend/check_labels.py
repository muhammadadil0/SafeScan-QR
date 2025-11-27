from transformers import AutoModelForSequenceClassification, AutoTokenizer

model_name = "Eason918/malicious-url-detector"
model = AutoModelForSequenceClassification.from_pretrained(model_name)
print(f"ID2LABEL: {model.config.id2label}")
